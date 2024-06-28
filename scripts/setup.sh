#!/bin/bash

# Default configurations
web_server_choice=""
db_server_choice=""
php_version_choice="8.1" # Default PHP version
additional_php_extensions=()
install_dir="/usr/local/bin"
log_file="setup.log"

# Function to check the success of the last command and exit on failure
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed to install. Exiting."
        echo "$(date): Error: $1 failed to install." >> $log_file
        exit 1
    else
        echo "$(date): $1 installed successfully." >> $log_file
    fi
}

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q $1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --web-server)
            web_server_choice="$2"
            shift
            shift
            ;;
        --db-server)
            db_server_choice="$2"
            shift
            shift
            ;;
        --php-version)
            php_version_choice="$2"
            shift
            shift
            ;;
        --php-extensions)
            IFS=',' read -ra additional_php_extensions <<< "$2"
            shift
            shift
            ;;
        --install-dir)
            install_dir="$2"
            shift
            shift
            ;;
        --log-file)
            log_file="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Log start time
echo "$(date): Setup script started." > $log_file

# Verify operating system
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script is designed for Ubuntu/Debian Linux distributions."
    echo "$(date): Unsupported OS detected. Exiting." >> $log_file
    exit 1
fi

# Update package lists
sudo apt update
check_success "Package lists update"

# Choose web server
if [ -z "$web_server_choice" ]; then
    echo "Choose your preferred web server:"
    echo "1. Nginx"
    echo "2. Apache2"
    read -p "Enter your choice (1 or 2): " web_choice
else
    web_choice=$web_server_choice
fi

case $web_choice in
    1) 
        if is_installed nginx; then
            echo "Nginx is already installed. Skipping."
            echo "$(date): Nginx is already installed. Skipping." >> $log_file
        else
            sudo apt install -y nginx
            check_success "Nginx installation"
        fi
        web_server="Nginx"
        ;;
    2) 
        if is_installed apache2; then
            echo "Apache2 is already installed. Skipping."
            echo "$(date): Apache2 is already installed. Skipping." >> $log_file
        else
            sudo apt install -y apache2
            check_success "Apache2 installation"
        fi
        web_server="Apache2"
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        echo "$(date): Invalid web server choice." >> $log_file
        exit 1
        ;;
esac

# Choose database server
if [ -z "$db_server_choice" ]; then
    echo "Choose your preferred database server:"
    echo "1. MySQL"
    echo "2. MariaDB"
    read -p "Enter your choice (1 or 2): " db_choice
else
    db_choice=$db_server_choice
fi

case $db_choice in
    1)
        if is_installed mysql-server; then
            echo "MySQL is already installed. Skipping."
            echo "$(date): MySQL is already installed. Skipping." >> $log_file
        else
            sudo apt install -y mysql-server
            check_success "MySQL installation"
            # Run MySQL secure installation
            sudo mysql_secure_installation
        fi
        db_server="MySQL"
        ;;
    2)
        if is_installed mariadb-server; then
            echo "MariaDB is already installed. Skipping."
            echo "$(date): MariaDB is already installed. Skipping." >> $log_file
        else
            sudo apt install -y mariadb-server
            check_success "MariaDB installation"
            # Run MariaDB secure installation
            sudo mysql_secure_installation
        fi
        db_server="MariaDB"
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        echo "$(date): Invalid database server choice." >> $log_file
        exit 1
        ;;
esac

# PHP Version Selection
if [ -z "$php_version_choice" ]; then
    echo "Choose PHP version (default is 8.1):"
    echo "1. PHP 7.4"
    echo "2. PHP 8.0"
    echo "3. PHP 8.1"
    echo "4. PHP 8.2"
    read -p "Enter your choice (1, 2, 3 or 4): " php_choice
else
    php_choice=$php_version_choice
fi

case $php_choice in
    1 | "7.4")
        php_version="7.4"
        ;;
    2 | "8.0")
        php_version="8.0"
        ;;
    3 | "8.1")
        php_version="8.1"
        ;;
    4 | "8.2")
        php_version="8.2"
        ;;
    *)
        echo "Invalid choice. Please enter 1, 2, 3 or 4."
        echo "$(date): Invalid PHP version choice." >> $log_file
        exit 1
        ;;
esac

# Add PHP PPA after choosing PHP version
sudo add-apt-repository ppa:ondrej/php -y
check_success "Adding PHP PPA"

# Update package lists again after adding PPA
sudo apt update
check_success "Package lists update after adding PHP PPA"

# Install PHP and extensions
php_extensions="php$php_version php$php_version-cli php$php_version-fpm"

# Add default PHP extensions
default_php_extensions=("php$php_version-mysql" "php$php_version-pgsql" "php$php_version-sqlite3" "php$php_version-curl" "php$php_version-gd" "php$php_version-mbstring" "php$php_version-xml" "php$php_version-zip" "php$php_version-intl")
for ext in "${default_php_extensions[@]}"; do
    php_extensions="$php_extensions $ext"
done

# Add additional PHP extensions from command line arguments
for ext in "${additional_php_extensions[@]}"; do
    php_extensions="$php_extensions php$php_version-$ext"
done

sudo apt install -y $php_extensions
check_success "PHP and extensions installation"


# Install other essential tools
essential_tools=("git" "curl" "unzip")
for tool in "${essential_tools[@]}"; do
    if is_installed $tool; then
        echo "$tool is already installed. Skipping."
        echo "$(date): $tool is already installed. Skipping." >> $log_file
    else
        sudo apt install -y $tool
        check_success "$tool installation"
    fi
done

# Install Node.js and NPM (using Node Version Manager for flexibility)
if ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    check_success "NVM installation"
else
    echo "NVM is already installed. Skipping."
    echo "$(date): NVM is already installed. Skipping." >> $log_file
fi

# Declare NVM_DIR variable
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# Load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts  # Install the latest LTS version of Node.js
check_success "Node.js installation"

# Install Yarn (using NPM)
npm install -g yarn
check_success "Yarn installation"

# Install Composer (global installation)
curl -sS https://getcomposer.org/installer -o composer-setup.php
check_success "Composer setup download"
sudo php composer-setup.php --install-dir=$install_dir --filename=composer
check_success "Composer installation"

# Output the success message with information
echo "Setup Complete:"
echo "Web Server: ${web_server}"
echo "Database Server: ${db_server}"
echo "PHP Version: $(php -v | head -n 1)"
echo "Node.js Version: $(node -v)"
echo "NPM Version: $(npm -v)"
echo "Yarn Version: $(yarn -v)"
echo "Composer Version: $(composer -V)"

# Log the completion time
echo "$(date): Setup script completed successfully." >> $log_file
