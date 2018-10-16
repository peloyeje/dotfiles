#!/usr/bin/env zsh

###
# Vim configuration install script
###

# Exit immediately if a command exits with a non-zero status
set -e

# Base variables
SOURCE_DIR=$( cd "$( dirname "$0" )" && pwd )

# Software-specific variables
typeset -A CONFIG_FILES

DEST_DIR="$HOME" # The destination config directory of the program
CONFIG_FILES[vimrc]=.vimrc # One line per config file

# Creates the destination folder if it doesn't exists
if [ ! -e "$SOURCE_DIR" ]; then
    mkdir -p "$SOURCE_DIR"
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

# Setup Plug plugin manager (https://github.com/junegunn/vim-plug)
echo "Set up vim plugins ..."
mkdir -p "$HOME"/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "Done."
