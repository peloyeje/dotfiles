" Plugins
call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
Plug 'davidhalter/jedi-vim'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'

call plug#end()

" Default master settings
set nocompatible                " Set nocompatible mode for vi
set encoding=utf-8
set fileencoding=utf-8
set nobomb                      " Remove BOM by default
set autoread                    " Automatic reload of modified files
set backspace=indent,eol,start

" Theme
colorscheme molokai
set background=dark

" Visual options
syntax on
set number
set ruler
set showcmd

" Search
set hlsearch                    " Highlights all search pattern matches
set incsearch
set ignorecase                  " Ignore Case
set smartcase                   " Unless we search for an uppercase

" Indenting
filetype plugin indent on
set autoindent
set expandtab                   " Tabs are spaces
set shiftwidth=4                " Use 4 spaces for indent
set softtabstop=4               " An indentation every 4 columns

" Formatting
set wrap                        " Wrap to new lines the lines exeed 80 chars

" Pasting
set pastetoggle=<F10>
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" Vim CLI behavior
set wildmenu
set wildmode=longest,full

" Moving in files
set mouse=a

" Highlights bad characters
set listchars=tab:\ \ ,trail:¤,extends:>,precedes:<,nbsp:¬
set list
match Error /\s\+$/             " Highlight trailing whitespaces

" Splits
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current

" Consistency
nmap U <C-r>                    " Remap undo the undo to maj U

" Functions
function! <SID>StripTrailingWhitespace()
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    %s///e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

" Map remove whitespace with F3
noremap <silent> <F3> :call <SID>StripTrailingWhitespace()<CR>

" Force Training - Disable use of Arrows
" In normal mode
nnoremap <Up> :echo "No arrows, use hjkl!!!" <CR>
nnoremap <Down> :echo "No arrows, use hjkl!!!" <CR>
nnoremap <Left> :echo "No arrows, use hjkl!!!" <CR>
nnoremap <Right> :echo "No arrows, use hjkl!!!" <CR>
" In insertion mode
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
" In visual mode
vnoremap <Up> :echo "No arrows, use hjkl!!!" <CR>
vnoremap <Down> :echo "No arrows, use hjkl!!!" <CR>
vnoremap <Left> :echo "No arrows, use hjkl!!!" <CR>
vnoremap <Right> :echo "No arrows, use hjkl!!!" <CR>

