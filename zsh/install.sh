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

# Make sure zsh is installed first
if [ ! -x "$(command -v zsh)" ]; then
    log "[zsh]" 'Installing zsh ...' >&2
    if [ -x "$(command -v brew)" ]; then
        "$(command -v brew)" install zsh
    else
        log "[zsh]" "brew is not installed; aborting"
        exit 1
    fi
fi

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
        log "[zsh]" "$SOURCE_PATH is missing, skipping ..."
        continue
    fi

    DEST_PATH="$DEST_DIR/$dest"

    log "[zsh]" "Symlinking $SOURCE_PATH to $DEST_PATH ..."
    if [ -f "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
         rm "$DEST_PATH"
    fi

    ln -s "$SOURCE_PATH" "$DEST_PATH"

    log "[zsh]" "Done."
done

# Install GNU utils and alter PATH to use them by default
UTILS=("coreutils" "findutils" "diffutils" "gnu-sed" "gnu-tar" "grep")

for util in  ${UTILS[@]}
do
    log "[zsh]" "Installing $util ..."
    # Install executable
    "$(command -v brew)" install $util
    # Setup PATH to use these binaries by default
    if [ -f "$HOME/.gnu.paths" ]; then
        grep -v "$util" "$HOME/.gnu.paths" > "$HOME/.gnu.paths.tmp"
        cat "$HOME/.gnu.paths.tmp" > "$HOME/.gnu.paths"
        rm "$HOME/.gnu.paths.tmp"
    fi
    echo -e "\n# $util\nexport PATH="/usr/local/opt/$util/libexec/gnubin:\$PATH"" >> "$HOME/.gnu.paths"
done
