#!/usr/bin/env zsh

HERE="$(cd "$(dirname "$0")" && pwd)"

source "$HERE/../../scripts/common.sh"

# Install program
sudo apt install zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
