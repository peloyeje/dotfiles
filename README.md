# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Getting started

Install `stow`

```shell
sudo apt update
sudo apt install -y stow
```

```shell
cd apps/
stow --ignore "\.(md|sh)" -Rvt ~ *
```