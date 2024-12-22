# Oh my zsh
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

ZSH_THEME="risto"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="false"

plugins=(
    ubuntu
    git
    docker
    docker-compose
    kubectl
    sudo
    zsh-autosuggestions
    vi-mode
)

export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh
autoload zmv

# OS conf
export VISUAL=vim
export EDITOR="$VISUAL"

# Aliases
alias ls="ls -larth"
alias cleanpy="sudo find ./ -type f -name '*.pyc' -delete -print && find ./ -type d -name "__pycache__" -delete -print"

# Brew
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH

# XDG bin (taking precedence over homebrew)
export PATH=$HOME/.local/bin:$PATH

# Go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
    echo "pyenv loaded"
fi

# NVM
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
    echo "direnv loaded"
fi

# Terraform
export PATH=$PATH:$HOME/.tfenv/bin

# k8s
export KUBECONFIG="${HOME}/.kube/config"

if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
    echo "kubectl loaded"
fi

# Android SDK
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# Maven
export M2_HOME="/opt/apache-maven-3.8.6"
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xms256m -Xmx512m"
export PATH=$M2:$PATH

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc
compinit

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Github CLI
if command -v gh >/dev/null 2>&1; then
    source <(gh completion -s zsh)
    echo "gh loaded"
fi

# Local conf (not committed)
if [ -f "${HOME}/.zshrc.local" ]; then
    source "${HOME}/.zshrc.local"
    echo "local .zshrc loaded"
fi

