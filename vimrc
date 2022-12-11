syntax enable

filetype off

call plug#begin('~/.vim/plugz')
  Plug 'airblade/vim-gitgutter'
  Plug 'vim-airline/vim-airline'
  Plug 'dense-analysis/ale'
  Plug 'jiangmiao/auto-pairs'
  Plug 'mattn/emmet-vim'
  Plug 'tomtom/tcomment_vim'
  Plug 'ap/vim-css-color'
  Plug 'junegunn/vim-emoji'
  Plug 'kyuhi/vim-emoji-complete'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-fugitive'
  Plug 'sheerun/vim-polyglot'
  Plug 'prettier/vim-prettier'
  Plug 'tpope/vim-ragtag'
  Plug 'mhinz/vim-startify'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-dadbod'
  Plug 'rizzatti/dash.vim'
  Plug 'mhinz/vim-mix-format'
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make'}
  Plug 'vim-airline/vim-airline-themes'
call plug#end()

"rNVim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" gitgutter
let g:gitgutter_sign_added = emoji#for('heavy_plus_sign')
let g:gitgutter_sign_modified = emoji#for('wrench')
let g:gitgutter_sign_removed = emoji#for('heavy_minus_sign')
let g:gitgutter_sign_modified_removed = emoji#for('scream')

let g:startify_session_autoload=1

highlight FoldColumn  gui=bold    guifg=grey65     guibg=Grey90
highlight Folded      gui=italic  guifg=Black      guibg=Grey90
highlight LineNr      gui=NONE    guifg=grey60     guibg=Grey90
set hlsearch
set nrformats=
set number
set showmatch
set incsearch
set background=light
set hidden
set previewheight=10
set backspace=indent,eol,start
set textwidth=0 nosmartindent tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set ruler
set wrap
set dir=/tmp//
set scrolloff=5
set foldmethod=syntax
set foldlevelstart=20
set foldcolumn=0
set ignorecase
set smartcase
set clipboard=unnamed
set rtp+=/usr/local/opt/fzf
set completefunc=emoji#complete

let g:AckAllFiles = 0
highlight ALEWarning ctermbg=165
highlight ALEWarning ctermbg=166

let html_use_css=1
let html_number_lines=0
let html_no_pre=1

" ALE Config
let g:ale_fix_on_save = 1
let g:ale_close_preview_on_insert = 1

let g:ale_sign_error = emoji#for('skull')
let g:ale_sign_warning = emoji#for('collision')

let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1

let g:no_html_toolbar = 'yes'

let g:prettier#autoformat = 0
let g:prettier#config#parser = 'babylon'
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md Prettier

let g:autoclose_on = 1
" au BufWinLeave * silent! mkview
" au BufWinEnter * silent! loadview

autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType tex setlocal textwidth=78
autocmd BufNewFile,BufRead *.txt setlocal textwidth=78

" Find files using Telescope command-line sugar.
nnoremap <LocalLeader>ff <CMD>Telescope find_files<CR>
nnoremap <LocalLeader>gg :Telescope live_grep<CR>
nnoremap <LocalLeader>bb :Telescope buffers<cr>
nnoremap <LocalLeader>fh :Telescope help_tags<cr>
nnoremap <LocalLeader>rr :source $HOME/.config/nvim/init.vim<CR>

let g:emoji_complete_overwrite_standard_keymaps = 0
let maplocalleader="\<Space>"
imap <C-L> <SPACE>=><SPACE>
imap <C-G> \|><SPACE>
imap <C-F> <Plug>(emoji-start-complete)
map <silent> <LocalLeader>ee :%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>
map <silent> <LocalLeader>cc :TComment<CR>
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

"ws -- white space: removes all trailing whitespace from a file
map <silent> <LocalLeader>ws :%s/\s\+$//<CR>

autocmd BufNewFile,BufRead {*.txt,*.md} setlocal spell spelllang=en_us

if &t_Co == 256
  colorscheme solarized
  set background=light
  hi Normal guibg=NONE ctermbg=NONE
endif

" Highlight trailing whitespace
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufRead,InsertLeave * match ExtraWhitespace /\s\+$/

" Set up highlight group & retain through colorscheme changes
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
map <silent> <LocalLeader>hws :highlight clear ExtraWhitespace<CR>

" Highlight too-long lines
autocmd BufRead,InsertEnter,InsertLeave * 2match LineLengthError /\%81v.*/
highlight LineLengthError ctermbg=5 guibg=white
autocmd ColorScheme * highlight LineLengthError ctermbg=20 guibg=white

"Set filetypes
au BufRead,BufNewFile {*.md,*.mkd,*.markdown}           set ft=markdown
au BufNewFile,BufRead {*.js,*ts,*.jsx,*tsx}             set filetype=javascript
au BufRead,BufNewFile *.jar,*.war,*.ear,*.sar,*.rar     set filetype=zip

"Map esc to hh
:imap hh <Esc>
" Map Tab to ctrlp
:imap <Tab><Tab> <c-p>

" Enable PowerLine
let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1


" VIM Split Enhancements
nnoremap <M-Right> <C-W>n
nnoremap <M-Left> <C-W>d
nnoremap <M-Down> <C-W>h
nnoremap <M-Up> <C-W>t

" Pane resizing
noremap <C-M-Left> :vertical resize -2<CR>
noremap <C-M-Right> :vertical resize +2<CR>
noremap <C-M-Up> :resize +1<CR>
noremap <C-M-Down> :resize -1<CR>

" Disable Markdown folding
let g:vim_markdown_folding_disabled=1

" Cursor/Line Highlighting
autocmd VimEnter * hi CursorLine cterm=NONE ctermbg=7
autocmd VimEnter * hi CursorColumn cterm=NONE ctermbg=7

augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
  au WinLeave * setlocal nocursorline nocursorcolumn
augroup END

" Allow local settings overrides with ~/.vimrc.local
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

