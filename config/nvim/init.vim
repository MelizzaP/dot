syntax on
filetype off

" ========= Plugins =============
call plug#begin('~/.vim/plugz')
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'jiangmiao/auto-pairs'
  Plug 'mattn/emmet-vim'
  Plug 'tomtom/tcomment_vim'
  Plug 'ap/vim-css-color'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-fugitive'
  Plug 'prettier/vim-prettier'
  Plug 'tpope/vim-ragtag'
  Plug 'mhinz/vim-startify'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-dadbod'
  Plug 'rizzatti/dash.vim'
  Plug 'mhinz/vim-mix-format'
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'sainnhe/everforest'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.3' }
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make'}
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'elixir-editors/vim-elixir'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'onsails/lspkind-nvim'
  Plug 'craigmac/vim-mermaid'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'pwntester/octo.nvim'
  Plug 'mhinz/vim-signify'
  Plug 'epwalsh/obsidian.nvim'
  Plug 'github/copilot'
call plug#end()

" ========= GENERAL SETTINGS =============
set backspace=indent,eol,start
set conceallevel=2
set clipboard=unnamed
set dir=/tmp//
set foldcolumn=0
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable " disable folding on startup
set foldlevelstart=20
set hidden
set hlsearch
set incsearch
set ignorecase
set nrformats=octal
set number
set previewheight=15
set runtimepath^=~/.vim runtimepath+=~/.vim/after
set scrolloff=5
set showmatch
set smartcase
set textwidth=0 nosmartindent tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set wrap
set laststatus=2

" ========= COLORS & HIGHLIGHTS =============
let g:everforest_background = 'soft'
let g:everforest_better_performance = 1

colorscheme everforest
hi Normal ctermbg=NONE guibg=NONE
hi NormalNC ctermbg=NONE guibg=NONE
hi EndOfBuffer ctermbg=NONE guibg=NONE
hi ExtraWhitespace ctermbg=Black guibg=Black
hi Folded cterm=italic ctermfg=Black ctermbg=Cyan
hi LineLengthError ctermbg=Black

hi CursorLine cterm=NONE ctermbg=Black
hi cursorcolumn cterm=NONE ctermbg=Black
hi! link TermCursor Cursor
hi TermCursorNC ctermbg=Cyan ctermfg=White

au BufRead,BufNewFile {*.md,*.mkd,*.markdown}           set ft=markdown
au BufNewFile,BufRead *.js                              set ft=javascript
au BufNewFile,BufRead *.ts                              set ft=typescript
au BufNewFile,BufRead *.jsx                             set filetype=javascriptreact
au BufNewFile,BufRead *.tsx                             set filetype=typescriptreact
au BufRead,BufNewFile {*.jar,*.war,*.ear,*.sar,*.rar}   set ft=zip
au BufNewFile,BufRead {*.ex,*.exs}                      set ft=elixir
au BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md Prettier
au BufNewFile,BufRead {*.txt,*.md}                      setlocal spell spelllang=en_us
au BufRead,InsertLeave * match ExtraWhitespace /\s\+$/
au BufRead,InsertEnter,InsertLeave * 2match LineLengthError /\%121v.*/
au ColorScheme * hi ExtraWhitespace ctermbg=Magenta
au ColorScheme * hi LineLengthError ctermbg=20
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au VimEnter * hi CursorLine cterm=NONE ctermbg=Black

augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
  au WinLeave * setlocal nocursorline nocursorcolumn
augroup END

" ========= MAPPINGS =============
" ******* Normal Mode **********
nn s <CMD>Telescope find_files<CR>
nn T <CMD>Telescope<CR>
nn H <CMD>Telescope buffers<CR>
nn <Tab> :bnext<CR>
nn <S-Tab> :bprev<CR>
nn <BS> <C-W><C-W>


map <silent> <LocalLeader>ws :%s/\s\+$//e<CR>
map <silent> <LocalLeader>hws :highlight clear ExtraWhitespace<CR>
map <silent> <LocalLeader>cc :TComment<CR>
nn <silent> [b :bprevious<CR>
nn <silent> ]b :bnext<CR>
nn <silent> [B :bfirst<CR>
nn <silent> ]B :blast<CR>
nn <silent> XX :bd<CR>
nn <silent> [t :tabprevious<CR>
nn <silent> ]t :tabnext<CR>
nn <silent> [T :tabfirst<CR>
nn <silent> ]T :tablast<CR>

"      Insert Mode
imap <C-L> <SPACE>=><SPACE>
imap <C-S> \|><SPACE>
imap <Tab> <c-x><c-o>

imap <silent><script><expr> <C-k> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
tnoremap <Esc> <C-\><C-n>

"      Command Line
let g:netrw_banner = 0

let g:startify_session_autoload=1

let g:AckAllFiles = 0
let html_use_css=1
let html_number_lines=0
let html_no_pre=1

let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1

let g:no_html_toolbar = 'yes'

let g:prettier#autoformat = 0
let g:prettier#config#parser = 'babylon'

let g:autoclose_on = 1

let maplocalleader="\<Space>"

let g:signify_number_highlight = 1
let g:signify_sign_add               = ''
let g:signify_sign_delete            = ''
let g:signify_sign_delete_first_line = ''
let g:signify_sign_change            = ''
let g:signify_sign_change_delete     = ''

let g:mix_format_on_save = 1

imap <C-L> <SPACE>=><SPACE>
imap <C--> \|><SPACE>
map <LocalLeader>cc :TComment<CR>
"ws -- white space: removes all trailing whitespace from a file
map <silent> <LocalLeader>ws :%s/\s\+$//<CR>

autocmd BufNewFile,BufRead {*.txt,*.md} setlocal spell spelllang=en_us

" Highlight trailing whitespace
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufRead,InsertLeave * match ExtraWhitespace /\s\+$/

" Enable PowerLine
let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1


" Disable Markdown folding
let g:vim_markdown_folding_disabled=1

" Disable lang exts
let g:loaded_perl_provider = 0
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0

" Snippets
imap <expr> <C-g>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-g>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Allow local settings overrides with ~/.vimrc.local
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

lua require('ls')
lua require('cmp_config')
lua require('obsidian_config')
lua require('octo_config')
lua require('treesitter_config')
