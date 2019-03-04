#!/usr/bin/env bash

###
# zsh configuration install script
###

# Import dependencies
source ./utils.sh

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Config files
SOURCE_FILES=(zshrc zshenv)
DEST_FILES=(.zshrc .zshenv)

DEST_DIR="$HOME" # The destination config directory of the program

# Creates the destination folder if it doesn't exists
if [ ! -e "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

# Symlink SOURCE_FILES into DEST_DIR with name DEST_FILES
for i in ${!SOURCE_FILES[@]};
do
    source=${SOURCE_FILES[$i]}
    dest=${DEST_FILES[$i]}

    SOURCE_PATH="$SOURCE_DIR/$source"

    if [ ! -f "$SOURCE_PATH" ]; then
        echo "$SOURCE_PATH is missing, skipping ..."
        continue
    fi

    DEST_PATH="$DEST_DIR/$dest"

    echo "Symlinking $SOURCE_PATH to $DEST_PATH ..."
    if [ -f "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
         rm "$DEST_PATH"
    fi

    ln -s "$SOURCE_PATH" "$DEST_PATH"

    echo "Done."
done
