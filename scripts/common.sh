#!/usr/bin/env bash

set -euo pipefail

APPS_DIRNAME="apps"
APPS_DIRPATH="$(cd "$(dirname "$0")/../" && pwd)/${APPS_DIRNAME}"

function log {
    echo "[$(date)]: $*"
}

function current_stack_dir {
    echo $(cd "$(dirname "$0")" && pwd)
}

function current_stack_name {
    echo ${$(current_stack_dir)#$APPS_DIRPATH/}
}