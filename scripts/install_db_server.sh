#!/bin/bash

source ./scripts/utils.sh

install_db_server() {
    local db_choice=$1

    case $db_choice in
        1)
            log "Installing MySQL..."
            sudo apt install -y mysql-server
            log "Securing MySQL installation..."
            sudo mysql_secure_installation
            ;;
        2)
            log "Installing MariaDB..."
            sudo apt install -y mariadb-server
            log "Securing MariaDB installation..."
            sudo mysql_secure_installation
            ;;
        *)
            error "Invalid choice. Please enter 1 or 2."
            exit 1
            ;;
    esac
    log "Database server installation complete."
}

# Example usage: install_db_server 1
