```markdown
# Usage Guide

Welcome to **LinuxDevKickstart**! This guide will help you get started with using the scripts in this repository to set up your development environment on a Linux (Ubuntu/Debian) system.

## Prerequisites

Before you begin, ensure you have the following:

- A Linux (Ubuntu/Debian) system.
- Sudo privileges to install software packages and modify system settings.
- An internet connection to download packages and dependencies.

## Cloning the Repository

First, clone the repository to your local machine:

```sh
git clone https://github.com/yourusername/LinuxDevKickstart.git
cd LinuxDevKickstart
```

## Running the Setup Script

The main script, `setup.sh`, will guide you through the setup process. Make the script executable and then run it:

```sh
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Follow the prompts to choose your preferred web server, database server, PHP version, and any additional PHP extensions.

## Command-Line Arguments

You can also customize the setup process using command-line arguments. Here are the available options:

- `--web-server` : Specify the web server to install (nginx or apache2).
- `--db-server` : Specify the database server to install (mysql or mariadb).
- `--php-version` : Specify the PHP version to install (default is 8.1).
- `--php-extensions` : Specify additional PHP extensions to install, separated by commas (e.g., curl,gd,mbstring).
- `--install-dir` : Specify the directory for installing global packages (default is `/usr/local/bin`).
- `--log-file` : Specify a file to log the setup process (default is `setup.log`).

### Example Usage

```sh
./scripts/setup.sh --web-server nginx --db-server mysql --php-version 8.2 --php-extensions curl,gd,mbstring --install-dir /usr/local/bin --log-file setup.log
```

## Script Breakdown

### Web Server Installation

The `install_web_server.sh` script handles the installation of your chosen web server.

#### Available Options

- **Nginx**: A high-performance web server.
- **Apache2**: A widely-used web server.

### Database Server Installation

The `install_db_server.sh` script handles the installation and initial configuration of your chosen database server.

#### Available Options

- **MySQL**: A popular relational database management system.
- **MariaDB**: An enhanced, drop-in replacement for MySQL.

### PHP Installation

The `install_php.sh` script installs the specified PHP version along with the desired extensions.

#### Default PHP Version

- **8.1** (default)
- **8.2** (optional)

### Node.js Installation

The `install_nodejs.sh` script installs Node.js using Node Version Manager (NVM).

### Yarn Installation

The `install_yarn.sh` script installs Yarn globally using NPM.

### Composer Installation

The `install_composer.sh` script installs Composer globally for PHP dependency management.

## Customization

You can customize the scripts to suit your specific needs. Each script is modular and can be easily modified to add more features or change existing behavior.

## Logging

All actions performed by the scripts are logged. You can specify a custom log file using the `--log-file` option.

## Contributing

If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request. Contributions are always welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.

## Contact

For any questions or support, please contact [your email/username].

Happy coding with **LinuxDevKickstart**!
```

This `usage_guide.md` provides detailed instructions on how to use the scripts, including command-line options, example usage, and information on each script's purpose. You can customize it further to match the specific details of your project and usage scenarios.