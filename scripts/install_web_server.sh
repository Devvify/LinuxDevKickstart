#!/bin/bash

source ./scripts/utils.sh

install_web_server() {
    local web_choice=$1

    case $web_choice in
        1) 
            log "Installing Nginx..."
            sudo apt install -y nginx
            ;;
        2) 
            log "Installing Apache2..."
            sudo apt install -y apache2
            ;;
        *)
            error "Invalid choice. Please enter 1 or 2."
            exit 1
            ;;
    esac
    log "Web server installation complete."
}

# Example usage: install_web_server 1