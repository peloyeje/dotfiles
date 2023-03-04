#!/usr/bin/env zsh

HERE="$(cd "$(dirname "$0")" && pwd)"

source "$HERE/../../scripts/common.sh"

# Install program
sudo apt install vim

# Setup Plug plugin manager (https://github.com/junegunn/vim-plug)
log "Set up vim plugins ..."
mkdir -p "$HOME"/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim