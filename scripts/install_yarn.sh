#!/bin/bash

source ./scripts/utils.sh

install_yarn() {
    log "Installing Yarn..."
    npm install -g yarn
    log "Yarn installation complete."
}

# Example usage: install_yarn
