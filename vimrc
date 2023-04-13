syntax on
filetype off

" ========= Plugins =============
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
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'elixir-editors/vim-elixir'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'onsails/lspkind-nvim'
  Plug 'craigmac/vim-mermaid'
call plug#end()

" ========= GENERAL SETTINGS =============
set backspace=indent,eol,start
set clipboard=unnamed
set completefunc=emoji#complete
set dir=/tmp//
set foldcolumn=0
set foldmethod=syntax
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

" ========= COLORS & HIGHLIGHTS =============
colorscheme solarized
hi Normal ctermbg=NONE
hi ExtraWhitespace ctermbg=Yellow
hi Folded cterm=italic ctermfg=Magenta ctermbg=DarkBlue

autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufRead,InsertLeave * match ExtraWhitespace /\s\+$/
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd VimEnter * hi CursorLine cterm=NONE ctermbg=Gray

" TODO STOPPED HERE
" Highlight too-long lines
autocmd BufRead,InsertEnter,InsertLeave * 2match LineLengthError /\%121v.*/
highlight LineLengthError ctermbg=5 guibg=white
autocmd ColorScheme * highlight LineLengthError ctermbg=20 guibg=white

" gitgutter
let g:gitgutter_sign_added = emoji#for('heavy_plus_sign')
let g:gitgutter_sign_modified = emoji#for('wrench')
let g:gitgutter_sign_removed = emoji#for('heavy_minus_sign')
let g:gitgutter_sign_modified_removed = emoji#for('scream')
let g:startify_session_autoload=1



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
nnoremap s <CMD>Telescope find_files<CR>
nnoremap <LocalLeader>gg :Telescope git_files<CR>
nnoremap <LocalLeader>bb :Telescope buffers<cr>
nnoremap <LocalLeader>fh :Telescope help_tags<cr>
nnoremap <LocalLeader>rr :source $HOME/.config/nvim/init.vim<CR>
nnoremap <LocalLeader>s :Telescope lsp_definitions<CR>
nnoremap <LocalLeader>td :Telescope lsp_type_definitions<CR>
nnoremap <LocalLeader>im :Telescope lsp_implementations<CR>
nnoremap <LocalLeader>r :Telescope lsp_references<CR>

let g:emoji_complete_overwrite_standard_keymaps = 0
let maplocalleader="\<Space>"
imap <C-L> <SPACE>=><SPACE>
imap <C-G> \|><SPACE>
imap <C-F> <Plug>(emoji-start-complete)
map <LocalLeader>ee :%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>
map <LocalLeader>cc :TComment<CR>
nmap <C-k> <Plug>(ale_previous_wrap)
nmap <C-j> <Plug>(ale_next_wrap)
map <silent> <LocalLeader>ws :%s/\s\+$//<CR>
map <silent> <LocalLeader>hws :highlight clear ExtraWhitespace<CR>

autocmd BufNewFile,BufRead {*.txt,*.md} setlocal spell spelllang=en_us


"Set filetypes
au BufRead,BufNewFile {*.md,*.mkd,*.markdown}           set ft=markdown
au BufNewFile,BufRead {*.js,*ts,*.jsx,*tsx}             set filetype=javascript
au BufRead,BufNewFile *.jar,*.war,*.ear,*.sar,*.rar     set filetype=zip

"Map esc to hh
:imap hh <Esc>
" Map Tab to ctrlp
" :imap <Tab><Tab> <c-p>

" Enable PowerLine
let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1

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

augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
  au WinLeave * setlocal nocursorline nocursorcolumn
augroup END

" Allow local settings overrides with ~/.vimrc.local
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" LUA (LSP Stuff)
lua << EOF
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local cmp = require("cmp")
  cmp.setup({
  snippet = {
    expand = function(args)
      -- For `vsnip` user.
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
  },
  formatting = {
    format = require("lspkind").cmp_format({
      with_text = true,
      menu = {
        nvim_lsp = "[LSP]",
      },
    }),
  },
  })

  require'lspconfig'.elixirls.setup{
    cmd = { "/Users/mp/.config/elixir-ls/release/language_server.sh" },
    on_attach = on_attach,
    dialyzerEnabled = false,
    fetchDeps = false
  }
  require'lspconfig'.tsserver.setup{
    on_attach = on_attach
  }

  -- only attaches mapping if LS attaches
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<tab>', vim.lsp.buf.completion, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  end
EOF
