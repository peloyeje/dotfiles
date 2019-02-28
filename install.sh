#!/usr/bin/env bash

# Run all configuration scripts

# Exit immediately if a command exits with a non-zero status
set -e

PROGRAMS=(
    osx
    brew
    zsh
    git
    vim
    tmux
    beets
    atom
)

for program in ${PROGRAMS[@]}
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
