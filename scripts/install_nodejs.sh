#!/bin/bash

source ./scripts/utils.sh

install_nodejs() {
    log "Installing Node Version Manager (NVM)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    log "Installing latest LTS version of Node.js..."
    nvm install --lts
    log "Node.js installation complete."
}

# Example usage: install_nodejs
