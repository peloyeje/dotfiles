#!/usr/bin/env zsh

source common.sh

APPS=()

for dir in ${APPS_DIRPATH}/*; do
    install_script="${dir}/install.sh"
    echo $install_script

    if [[ -f $install_script && -x $install_script ]]; then
        . $install_script
    fi
done