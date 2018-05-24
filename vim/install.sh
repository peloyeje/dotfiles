#!/usr/bin/env bash

CONFIG_FILE="$HOME"/.vimrc

# Symlink vim config in the home directory
if [ -f $CONFIG_FILE ]; then
    rm $CONFIG_FILE
fi
ln -s "$(pwd)"/vimrc $CONFIG_FILE 

# Setup Plug plugin manager (https://github.com/junegunn/vim-plug)
mkdir -p "$HOME"/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


