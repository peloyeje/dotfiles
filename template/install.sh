#!/usr/bin/env zsh

###
# PROGRAM configuration install script
###

# Exit immediately if a command exits with a non-zero status
set -e

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Software-specific variables
typeset -A CONFIG_FILES

DEST_DIR="$HOME" # The destination config directory of the program
CONFIG_FILES[SOURCE]=DEST_PATH # One line per config file

# Creates the destination folder if it doesn't exists
if [ ! -e "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

# Symlink files in CONFIG_FILES array into the DEST_DIR
for source dest in ${(kv)CONFIG_FILES};
do
    SOURCE_PATH="$SOURCE_DIR/$source"

    if [ ! -f "$SOURCE_PATH" ]; then
        echo "$SOURCE_PATH is missing, skipping ..."
        continue
    else
        DEST_PATH="$DEST_DIR/$dest"
    fi

    echo "Symlinking $SOURCE_PATH to $DEST_PATH ..."
    if [ -f "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
         rm "$DEST_PATH"
    fi
    ln -s "$SOURCE_PATH" "$DEST_PATH"
    echo "Done."
done
