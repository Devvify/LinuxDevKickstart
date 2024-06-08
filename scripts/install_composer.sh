#!/bin/bash

source ./scripts/utils.sh

install_composer() {
    log "Installing Composer..."
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
    log "Composer installation complete."
}

# Example usage: install_composer
