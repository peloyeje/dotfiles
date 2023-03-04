Install Tmux
Install gpakosz tmux conf

```shell
cd stow/
stow -nRv --ignore *.mdt ~ *
```

## Vim

Here's the basic configuration I use as a Vim learner. No hidden gems but a good starting point :-)

#### Usage

1. Run the `install.sh` script
2. Open vim
3. Run `:PlugInstall`
4. Enjoy !

#### Plugins

- Layout
    * [molokai](https://github.com/tomasr/molokai) : color scheme
    * [vim-airline](https://github.com/vim-airline/vim-airline) : light status bar (display mode and other useful info)
- Plugins
    * [jedi-vim](https://github.com/davidhalter/jedi-vim) : autocompletion library
    * [NERDTree](https://github.com/scrooloose/nerdtree) : file system explorer in vim

#### Credits

Many thanks to [@ericdaat](@ericdaat) and [@YohanGrember](@YohanGrember) for their useful tips and config snippets.
