#!/usr/bin/env zsh

HERE="$(cd "$(dirname "$0")" && pwd)"

source "$HERE/../../scripts/common.sh"

# Install progra
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

