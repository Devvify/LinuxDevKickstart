
# LinuxDevKickstart

Welcome to **LinuxDevKickstart**! This repository contains a comprehensive script to quickly set up a development environment on a Linux (Ubuntu/Debian) system.

## Features

- **Web Server Setup**: Choose between Nginx and Apache2.
- **Database Server Setup**: Choose between MySQL and MariaDB.
- **PHP Setup**: Install PHP with default version 8.1, with an option to choose 8.2.
- **Node.js and NPM Setup**: Install using Node Version Manager (NVM) for flexibility.
- **Yarn and Composer**: Global installation for efficient package management.
- **Essential Tools**: Git, Curl, Unzip.
- **Customizable PHP Extensions**: Easily add additional PHP extensions as needed.
- **Robust Error Handling**: Ensures smooth installation with clear error messages and logging.

## Usage

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/yourusername/LinuxDevKickstart.git
    cd LinuxDevKickstart
    ```

2. **Run the Script**:
    ```sh
    ./setup.sh
    ```

3. **Follow the Prompts**:
    - Choose your preferred web server.
    - Choose your preferred database server.
    - Select PHP version (default is 8.1, option to choose 8.2).
    - Optionally add additional PHP extensions.

## Command-Line Arguments

You can also pass command-line arguments to customize the setup process:

```sh
./setup.sh --web-server nginx --db-server mysql --php-version 8.2 --php-extensions curl,gd --install-dir /usr/local/bin --log-file setup.log


## Usage/Examples

../setup.sh --web-server apache2 --db-server mariadb --php-version 8.1 --php-extensions mbstring,xml,zip --install-dir /usr/local/bin --log-file setup.log



## Contributing

Feel free to open issues and submit pull requests for improvements or bug fixes. Contributions are always welcome!

## License

[MIT](https://choosealicense.com/licenses/mit/)

This project is licensed under the MIT License. See the [LICENSE](https://choosealicense.com/licenses/mit/) file for details.