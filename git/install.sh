#!/usr/bin/env bash

# Sets up git configuration into the user's home directory

CONFIG_FILE="$HOME"/.gitconfig
CURRENT_DIR=$(dirname "$(readlink -f "$0")")

set -e

echo "Set up git configuration into "$CONFIG_FILE" ..."
if [ -f "$CONFIG_FILE" ] || [ -L "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
fi
ln -s "$CURRENT_DIR"/gitconfig "$CONFIG_FILE"
echo "Done."

