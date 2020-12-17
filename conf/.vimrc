noh
syntax on

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'chrisbra/colorizer'
Plugin 'tmhedberg/SimpylFold'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'sheerun/vim-polyglot'
Plugin 'junegunn/goyo.vim'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'lervag/vimtex'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'Valloric/YouCompleteMe'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

set clipboard=unnamed
set foldmethod=indent
set foldlevel=99
let python_highlight_all=1
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'

syntax on
nnoremap <space> za

"let g:ycm_autoclose_preview_window_after_completion=1
"map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

"python with virtualenv support

au BufNewFile,BufRead *.py 
    \ set tabstop=4
    \ | set softtabstop=4
    \ | set shiftwidth=4
    \ | set textwidth=79
    \ | set expandtab
    \ | set autoindent
    \ | set fileformat=unix

"persistent undo
set undofile
set undodir=~/.vim/undo
set undolevels=10000
set undoreload=10000

set spelllang=en_us,ru

set nocompatible
set showmode
set showcmd
set nu
set relativenumber
set expandtab
set noshiftround
set lazyredraw
set magic
set hlsearch
set incsearch
set ignorecase
set smartcase
set encoding=utf-8
set modelines=0
set formatoptions=tqn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set cmdheight=1
set laststatus=2
set matchpairs+=<:>
set scrolloff=8


" Colors
" Special
let wallpaper  = "None"
let background = "#111111"
let foreground = "#cccccc"
let cursor     = "#d23d3d"

" Colors
let color0  = "#222222"
let color1  = "#e84f4f"
let color2  = "#b7ce42"
let color3  = "#fea63c"
let color4  = "#66a9b9"
let color5  = "#b7416e"
let color6  = "#6d878d"
let color7  = "#cccccc"
let color8  = "#666666"
let color9  = "#e84f4f"
let color10 = "#b7ce42"
let color11 = "#fea63c"
let color12 = "#66a9b9"
let color13 = "#b7416e"
let color14 = "#6d878d"
let color15 = "#cccccc"

