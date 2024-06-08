#!/bin/bash

log() {
    local message=$1
    echo "[INFO] $message"
}

error() {
    local message=$1
    echo "[ERROR] $message" >&2
}

# Add more utility functions as needed

# Example usage:
# log "This is an informational message."
# error "This is an error message."
