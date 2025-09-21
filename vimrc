" ======================
" BASIC SETTINGS
" ======================
set number
set relativenumber
set encoding=utf-8
filetype plugin indent on
syntax enable
set cursorline
set nowrap
set foldmethod=indent
set foldlevel=99
set clipboard=unnamedplus
set tags=./tags,tags
set nomodeline
set noswapfile
set secure
set modelines=0
set showmode
set showcmd
set ruler
set title
set showmatch
set matchtime=2
" ======================
" IMPROVED SETTINGS
" ======================
set completeopt=menuone,noinsert,noselect
set shortmess+=c
set lazyredraw
set ttyfast
set autoread
au FocusGained,BufEnter * :silent! checktime

" Show invisible characters
set list
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»

" Smart search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Better indentation
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Backspace behavior
set backspace=indent,eol,start

" History and undo
set history=1000
set undolevels=1000
set undofile
set undodir=~/.vim/undodir

" Update time
set updatetime=300

" ======================
" PLUGINS (VIM-PLUG)
" ======================
call plug#begin('~/.vim/plugged')

" 🔧 Core Utilities
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'Chiel92/vim-autoformat'
Plug 'fisadev/vim-isort'
Plug 'preservim/nerdtree'
Plug 'vim-test/vim-test'
Plug 'tpope/vim-fugitive'
Plug 'github/copilot.vim'
Plug 'preservim/tagbar'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/goyo.vim'
Plug 'easymotion/vim-easymotion'
Plug 'vim-scripts/bash-support.vim'
Plug 'junegunn/limelight.vim'

" 🧠 Navigation & UX
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'

" 🎨 Interface & Themes
Plug 'tomasiser/vim-code-dark'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 🧠 Language Support
Plug 'sheerun/vim-polyglot'

" 🛠️ Tools & Utilities
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-obsession'
Plug 'mg979/vim-visual-multi'

" 📝 Linting & Formatting
Plug 'nvie/vim-flake8'
Plug 'vim-syntastic/syntastic'
Plug 'puremourning/vimspector'

call plug#end()

let g:python3_host_prog = '/home/wandors/.virtualvenv/bin/python3'
" ======================
" COLORSCHEME & UI
" ======================
set termguicolors
colorscheme codedark

highlight CursorLine cterm=none ctermbg=darkgray guibg=#3a3a3a

" Airline configuration
let g:airline_theme='dark'
let g:airline#extensions#mode#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 1

" ======================
" PLUGIN CONFIGURATION
" ======================

" Увімкнути плагін
let g:indent_blankline_enabled = v:true

" Показувати лінії тільки для відступів, а не для порожніх рядків
let g:indent_blankline_show_trailing_blankline_indent = v:false

" Не показувати лінії в буферах типу help, terminal, NERDTree тощо
let g:indent_blankline_filetype_exclude = ['help', 'terminal', 'dashboard', 'nerdtree']

" Не показувати лінії в певних типах вікон
let g:indent_blankline_buftype_exclude = ['terminal', 'nofile']

" Символ для лінії (можна змінити на │ або ┆)
let g:indent_blankline_char = '│'

" COC.nvim
let g:coc_global_extensions = [
    \ 'coc-pyright',
    \ 'coc-json',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-tsserver',
    \ 'coc-eslint',
    \ 'coc-prettier',
    \ 'coc-clangd'
    \ ]

" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" ALE configuration
let g:ale_linters = {
    \ 'python': ['flake8', 'pylint'],
    \ 'javascript': ['eslint'],
    \ 'typescript': ['eslint', 'tsserver']
    \ }

let g:ale_fixers = {
    \ 'python': ['black', 'isort'],
    \ 'javascript': ['prettier', 'eslint'],
    \ 'typescript': ['prettier', 'eslint']
    \ }

let g:ale_fix_on_save = 1

" Autoformat
let g:formatdef_black = '"black --quiet -"'
let g:formatters_python = ['black']

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeAutoDeleteBuffer=1

" FZF configuration
let $FZF_DEFAULT_COMMAND = 'ag -g ""'
let g:fzf_layout = { 'down': '~40%' }

" GitGutter
let g:gitgutter_sign_added = '│'
let g:gitgutter_sign_modified = '│'
let g:gitgutter_sign_removed = '│'
let g:gitgutter_sign_removed_first_line = '│'
let g:gitgutter_sign_modified_removed = '│'

" ======================
" KEY MAPPINGS
" ======================
let mapleader = " "
" Автоматичне створення символічного посилання
function! SetupVimspector()
  if !filereadable('.vimspector.json')
    silent! execute '!ln -sf ~/.vim/vimspector/python.json .vimspector.json'
    echo "Created .vimspector.json symlink"
  endif
endfunction
" В .vimrc - вкажіть шлях до глобальних конфігів
let g:vimspector_base_dir = expand('~/.vim/vimspector/')
autocmd BufEnter *.py call SetupVimspector()
" File operations
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" Buffer navigation
nnoremap <silent> <C-h> :bprev<CR>
nnoremap <silent> <C-l> :bnext<CR>
nnoremap <silent> <C-q> :bd<CR>

" Window navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Plugin shortcuts
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <F5> :TagbarToggle<CR>
nnoremap <F6> :UndotreeToggle<CR>
nnoremap <F7> :FZF<CR>
nnoremap <F8> :Autoformat<CR>
nnoremap <F10> :w<CR>:!python3 %<CR>

" Quick .vimrc editing
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Clear search highlights
nnoremap <silent> <leader>n :nohlsearch<CR>


" ======================
" AUTOCMDS
" ======================
augroup vimrc
  autocmd!
  " Relative numbers only in active window
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber

  " Python specific settings
  autocmd FileType python setlocal shiftwidth=4 tabstop=4 expandtab
  autocmd FileType python nnoremap <buffer> <F8> :Autoformat<CR>

  " C/C++ formatting
  autocmd FileType c,cpp nnoremap <buffer> <F3> :%!clang-format<CR>

  " Auto close NERDTree if it's the last buffer
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

  " Remove trailing whitespace on save
  autocmd BufWritePre * %s/\s\+$//e
augroup END

" ======================
" FUNCTIONS
" ======================
" Toggle between number and relative number
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

nnoremap <F2> <cmd>call vimspector#Launch()<CR>``
nnoremap <F9> <cmd>call vimspector#ToggleBreakpoint()<CR>

" ======================
" CUSTOM COMMANDS
" ======================
command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" === УКРАЇНСЬКІ КОМЕНТАРІ ТА МАППІНГИ ===
let mapleader = " "         " Лідер - пробіл

" Швидке форматування Python
nnoremap <leader>af :Autoformat<CR>
nnoremap <leader>is :Isort<CR>

" ======================
" ENVIRONMENT SPECIFIC
" ======================
" Python virtual environment

" Create undodir if it doesn't exist
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

"Підсвічувати поточний рядок у меню автодоповнення
highlight PmenuSel ctermfg=White ctermbg=DarkBlue gui=bold
" ======================
" FINAL SETTINGS
" ======================

" Enable mouse support
set mouse=a

" Session management
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize


command! Time echo strftime("%H:%M:%S")
" Повний набір для відладки:
nnoremap <leader>ts :call vimspector#Stop()<CR>        " Stop - зупинити
nnoremap <leader>tr :call vimspector#Restart()<CR>     " Restart - перезапустити
nnoremap <leader>tn :call vimspector#StepOver()<CR>    " Next - наступний крок
nnoremap <leader>ti :call vimspector#StepInto()<CR>    " Into - увійти в функцію
nnoremap <leader>to :call vimspector#StepOut()<CR>     " Out - вийти з функції
" Wildmenu completion
set wildmenu
set wildmode=longest:full,full
" Просто видаляти при виході (обережно!)
autocmd VimLeave * if getcwd() != expand('~') && filereadable('.vimspector.json') | call delete('.vimspector.json') | endif" Persistent undo
set undofile

