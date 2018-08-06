#!/usr/bin/env bash

# Sets up vim configuration into the user's home directory

CONFIG_FILE="$HOME"/.vimrc
VIM_DIR=$(dirname "$(readlink -f "$0")")

set -e

# Symlink vim config in the home directory
echo "Set up vim configuration into "$HOME" ..."
if [ -f "$CONFIG_FILE" ] || [ -L "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
fi
ln -s "$VIM_DIR"/vimrc "$CONFIG_FILE"
echo "Done."

# Setup Plug plugin manager (https://github.com/junegunn/vim-plug)
echo "Set up vim plugins ..."
mkdir -p "$HOME"/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Done."

