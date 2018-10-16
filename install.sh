#!/usr/bin/env zsh

# Run all configuration scripts

set -e

for program in $(ls $(pwd))
do
    if [ ! -d $program ] || [ "$program" = "template" ]; then
	# Skip value if it is the "template" folder or not a directory
        continue
    fi

    # Check if the "program" folder has an executable install script
    if [ -f "$program/install.sh" ] && [ -x "$program/install.sh" ]; then
        echo "> Start $program install script ..."
        "$program/install.sh"
        echo "> Done."
    fi
done
