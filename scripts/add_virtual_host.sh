#!/bin/bash

# Function to check if Nginx is installed
nginx_installed() {
    if [ -x "$(command -v nginx)" ]; then
        return 0  # Nginx is installed
    else
        return 1  # Nginx is not installed
    fi
}

# Function to check if Apache2 is installed
apache_installed() {
    if [ -x "$(command -v apache2)" ]; then
        return 0  # Apache2 is installed
    else
        return 1  # Apache2 is not installed
    fi
}

# Function to detect installed PHP versions
detect_php_versions() {
    local php_versions=()
    if [ -x "$(command -v php)" ]; then
        default_php_version=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')
        php_versions+=("${default_php_version}")
    fi

    # Add additional logic to detect more PHP versions if needed

    echo "${php_versions[@]}"  # Output array elements
}


# Function to select PHP version
select_php_version() {
    php_versions=("$@")

    if [ ${#php_versions[@]} -eq 0 ]; then
        echo "No PHP versions detected. Please install PHP."
        exit 1
    elif [ ${#php_versions[@]} -eq 1 ]; then
        echo "Default PHP version detected: ${php_versions[0]}"
        selected_php_version=${php_versions[0]}
    else
        echo "Multiple PHP versions detected:"
        for ((i=0; i<${#php_versions[@]}; i++)); do
            echo "$(($i + 1)). ${php_versions[$i]}"
        done
        read -p "Enter your choice (1-${#php_versions[@]}): " php_version_choice
        if [[ $php_version_choice -ge 1 && $php_version_choice -le ${#php_versions[@]} ]]; then
            selected_php_version=${php_versions[$(($php_version_choice - 1))]}
        else
            echo "Invalid choice. Please enter a number between 1 and ${#php_versions[@]}."
            exit 1
        fi
    fi

    echo "${selected_php_version}"
}

# Function to add virtual host in Nginx
add_nginx_virtual_host() {
    echo "Adding virtual host in Nginx..."
    
    read -p "Enter server names separated by space (e.g., domain.com www.domain.com): " server_names
    first_server_name=$(echo $server_names | cut -d' ' -f1)

    # Ask for root directory or use default
    read -p "Enter root directory for the server (/var/www/${first_server_name}): " root_dir
    root_dir=${root_dir:-"/var/www/${first_server_name}"}

    # Create root directory if it does not exist
    sudo mkdir -p "${root_dir}"

    # Set ownership and permissions
    sudo chown -R www-data:www-data "${root_dir}"
    sudo chmod -R 755 "${root_dir}"

    # Ask if user wants to add SSL
    read -p "Do you want to add SSL configuration (yes/no)? " add_ssl
    case $add_ssl in
        [Yy][Ee][Ss])
            read -p "Enter path to SSL certificate file (.crt): " ssl_cert_file
            read -p "Enter path to SSL certificate key file (.key): " ssl_key_file
            ssl_configuration="
    # SSL configuration
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate ${ssl_cert_file};
    ssl_certificate_key ${ssl_key_file};
    include snippets/ssl-params.conf;

    # Redirect HTTP to HTTPS
    if (\$scheme != 'https') {
        return 301 https://\$host\$request_uri;
    }
    "
            ;;
        *)
            ssl_configuration=""
            ;;
    esac

    # Create Nginx configuration file
    cat <<EOF | sudo tee "/etc/nginx/sites-available/${first_server_name}"
server {
    listen 80;
    listen [::]:80;

    server_name ${server_names};
    root ${root_dir};
    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    ${ssl_configuration}

    # PHP configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${selected_php_version}-fpm.sock; # Adjust PHP version as needed
    }

    # Additional configurations as needed

    access_log /var/log/nginx/${first_server_name}_access.log;
    error_log /var/log/nginx/${first_server_name}_error.log;

    # Uncomment the following line to enable
    # include /etc/nginx/sites-enabled/${first_server_name};
}
EOF

    # Enable the site by creating a symbolic link
    sudo ln -s "/etc/nginx/sites-available/${first_server_name}" "/etc/nginx/sites-enabled/"
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Reload Nginx to apply changes
    sudo systemctl reload nginx
    
    echo "Virtual host for ${server_names} added successfully!"
}

# Function to add virtual host in Apache2
add_apache_virtual_host() {
    echo "Adding virtual host in Apache2..."
    
    read -p "Enter server names separated by space (e.g., domain.com www.domain.com): " server_names
    first_server_name=$(echo $server_names | cut -d' ' -f1)
    second_server_name=$(echo $server_names | cut -d' ' -f2)

    # Ask for root directory or use default
    read -p "Enter root directory for the server (/var/www/${first_server_name}): " root_dir
    root_dir=${root_dir:-"/var/www/${first_server_name}"}

    # Create root directory if it does not exist
    sudo mkdir -p "${root_dir}"

    # Set ownership and permissions
    sudo chown -R www-data:www-data "${root_dir}"
    sudo chmod -R 755 "${root_dir}"

    # Ask if user wants to add SSL
    read -p "Do you want to add SSL configuration (yes/no)? " add_ssl
    case $add_ssl in
        [Yy][Ee][Ss])
            read -p "Enter path to SSL certificate file (.crt): " ssl_cert_file
            read -p "Enter path to SSL certificate key file (.key): " ssl_key_file
            ssl_configuration="
    # SSL configuration
    SSLEngine on
    SSLCertificateFile ${ssl_cert_file}
    SSLCertificateKeyFile ${ssl_key_file}
    "
            redirect_configuration="
    # Redirect HTTP to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    "
            ;;
        *)
            ssl_configuration=""

            # Redirect HTTP to HTTPS if SSL is not enabled
            redirect_configuration="
    # Redirect HTTP to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    "
            ;;
    esac

    # Create Apache2 configuration file
    cat <<EOF | sudo tee "/etc/apache2/sites-available/${first_server_name}.conf"
<VirtualHost *:80>
    ServerAdmin webmaster@${first_server_name}
    ServerName ${first_server_name}
EOF

    if [ ! -z "$second_server_name" ]; then
        cat <<EOF | sudo tee -a "/etc/apache2/sites-available/${first_server_name}.conf"
    ServerAlias ${second_server_name}
EOF
    fi

    cat <<EOF | sudo tee -a "/etc/apache2/sites-available/${first_server_name}.conf"
    DocumentRoot ${root_dir}

    <Directory ${root_dir}>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ${ssl_configuration}
    ${redirect_configuration}

    ErrorLog \${APACHE_LOG_DIR}/${first_server_name}_error.log
    CustomLog \${APACHE_LOG_DIR}/${first_server_name}_access.log combined
</VirtualHost>
EOF

    # Enable the site by creating a symbolic link
    sudo a2ensite "${first_server_name}.conf"
    
    # Test Apache configuration
    sudo apache2ctl configtest
    
    # Reload Apache to apply changes
    sudo systemctl reload apache2
    
    echo "Virtual host for ${server_names} added successfully!"
}

# Main script logic
echo "Checking installed web servers..."

if nginx_installed && ! apache_installed; then
    add_nginx_virtual_host
    exit 0
fi

if apache_installed && ! nginx_installed; then
    add_apache_virtual_host
    exit 0
fi

if ! nginx_installed && ! apache_installed; then
    echo "Neither Nginx nor Apache2 is installed. Please install one of them first."
    exit 1
fi

# Determine PHP versions and select version if needed
mapfile -t php_versions < <(detect_php_versions)  # Store PHP versions in an array

if [ ${#php_versions[@]} -eq 0 ]; then
    echo "No PHP versions detected. Please install PHP."
    exit 1
elif [ ${#php_versions[@]} -eq 1 ]; then
    selected_php_version=${php_versions[0]}
    echo "Default PHP version detected: ${selected_php_version}"
else
    echo "Multiple PHP versions detected:"
    for ((i=0; i<${#php_versions[@]}; i++)); do
        echo "$(($i + 1)). ${php_versions[$i]}"
    done
    read -p "Enter your choice (1-${#php_versions[@]}): " php_version_choice
    if [[ $php_version_choice -ge 1 && $php_version_choice -le ${#php_versions[@]} ]]; then
        selected_php_version=${php_versions[$(($php_version_choice - 1))]}
    else
        echo "Invalid choice. Please enter a number between 1 and ${#php_versions[@]}."
        exit 1
    fi
fi

# If both Nginx and Apache2 are installed, ask user to choose
if nginx_installed && apache_installed; then
    echo "Both Nginx and Apache2 are installed."
    echo "Choose the web server to configure virtual host:"
    echo "1. Nginx"
    echo "2. Apache2"
    read -p "Enter your choice (1 or 2): " web_server_choice

    case $web_server_choice in
        1)
            add_nginx_virtual_host
            ;;
        2)
            add_apache_virtual_host
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            exit 1
            ;;
    esac
elif nginx_installed; then
    add_nginx_virtual_host
elif apache_installed; then
    add_apache_virtual_host
else
    echo "No supported web servers installed. Exiting."
    exit 1
fi
