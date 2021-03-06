#!/usr/bin/env bash

###
# Brew configuration install script
###

# Exit immediately if a command exits with a non-zero status
set -e

# Import dependencies
source ./utils.sh

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Make sure brew is installed first
if [ ! -x "$(command -v brew)" ]; then
    log "[brew]" 'Installing brew ...' >&2
    if [ -x "$(command -v ruby)" ]; then
        "$(command -v ruby)" -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        log "[brew]" "Ruby is not installed; aborting"
        exit 1
    fi
fi

# Set up brew
$(command -v brew) update
$(command -v brew) tap homebrew/cask
$(command -v brew) tap homebrew/cask-fonts

# Install CLI packages
$(command -v brew) install -f $(cat $SOURCE_DIR/packages.txt) 2>&1

# Install casks
$(command -v brew) cask install -f $(cat $SOURCE_DIR/casks.txt) 2>&1

# Cleanup
$(command -v brew) doctor
$(command -v brew) update
$(command -v brew) cleanup
$(command -v brew) cask cleanup
