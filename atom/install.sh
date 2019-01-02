#!/usr/bin/env bash

###
# Atom configuration script
###

# Exit immediately if a command exits with a non-zero status
set -e

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Make sure brew is installed first
if [ ! -x "$(command -v apm)" ]; then
    echo 'Installing atom ...' >&2
    if [ -x "$(command -v brew)" ]; then
        $(command -v brew) cask install -f atom
    else
        echo "Atom is not installed; aborting"
        exit 1
    fi
fi

# Install packages
$(command -v apm) install $(cat $SOURCE_DIR/packages.txt) 2>&1
