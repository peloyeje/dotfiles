#!/usr/bin/env bash

###
# PROGRAM configuration install script
###

# Exit immediately if a command exits with a non-zero status
set -e

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Make sure brew is installed first
if [ ! -x "$(command -v brew)" ]; then
    echo 'Installing brew ...' >&2
    if [ -x "$(command -v ruby)" ]; then
        $(command -v ruby) -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Ruby is not installed; aborting"
        exit 1
    fi
fi

# Set up brew
$(command -v brew) update
$(command -v brew) tap homebrew/cask

# Install packages
$(command -v brew) install -f $(cat packages.txt)

# Install casks
$(command -v brew) casks install -f $(cat casks.txt)

# Cleanup
$(command -v brew) doctor
$(command -v brew) update
$(command -v brew) cleanup
$(command -v brew) cask cleanup
