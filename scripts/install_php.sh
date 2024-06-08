#!/bin/bash

source ./scripts/utils.sh

install_php() {
    local php_version=$1
    shift
    local php_extensions=$@

    log "Adding PHP repository..."
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update

    log "Installing PHP ${php_version}..."
    sudo apt install -y php${php_version} php${php_version}-cli php${php_version}-fpm

    if [ -n "$php_extensions" ]; then
        log "Installing PHP extensions: ${php_extensions}..."
        sudo apt install -y ${php_extensions}
    fi

    log "PHP installation complete."
}

# Example usage: install_php 8.1 php8.1-mysql php8.1-curl php8.1-gd
