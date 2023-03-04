#!/usr/bin/env zsh

HERE="$(cd "$(dirname "$0")" && pwd)"

source "$HERE/../../scripts/common.sh"

# Install program
sudo apt install tmux gawk perl sed

if [[ $TERM != "xterm-256color" ]]; then
    echo "TERM env var must be set to xterm-256color, please add 'export $TERM=xterm-256color' in your .zshrc"
    exit 1
fi

# Install tmux distribution from https://github.com/gpakosz/.tmux
if [[ ! -d "${HOME}/.tmux" ]]; then
    cd $HOME
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
fi