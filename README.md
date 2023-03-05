# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Getting started

Install `stow`

```shell
sudo apt update
sudo apt install -y stow
```

Install programs by running the `install.sh` script of every app in `apps/`

```shell
cd scripts/
./install-all-apps.sh
```

Create the configuration symlinks

```shell
cd apps/
stow --ignore "\.(md|sh)" -Rvt ~ *
```

All good :rocket:
