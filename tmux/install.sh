#!/usr/bin/env bash

# Sets up tmux configuration into the user's home directory

CONFIG_FILE="$HOME"/.tmux.conf
CURRENT_DIR=$(dirname "$(readlink -f "$0")")

set -e

echo "Set up tmux configuration into "$CONFIG_DIR" ..."
if [ -f "$CONFIG_FILE" ] || [ -L "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
fi
ln -s "$CURRENT_DIR"/tmux.conf "$CONFIG_FILE"
echo "Done."

