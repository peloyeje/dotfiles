#!/bin/bash

# Sets up all configuration files

set -e

for program in $(ls $(pwd))
do
    if [ ! -d $program ]; then
        continue
    fi
    # Check if program has install script
    if [ -f "$program/install.sh" ] && [ -x "$program/install.sh" ]; then
        echo "> Start $program install script ..."
        "$program/install.sh"
        echo "> Done."
    fi
done
