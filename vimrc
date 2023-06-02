syntax on
filetype off

" ========= Plugins =============
call plug#begin('~/.vim/plugz')
  Plug 'airblade/vim-gitgutter'
  Plug 'vim-airline/vim-airline'
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
  Plug 'sainnhe/everforest'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make'}
  Plug 'vim-airline/vim-airline-themes'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'elixir-editors/vim-elixir'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
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
let g:everforest_background = 'soft'
let g:everforest_better_performance = 1

colorscheme everforest
hi Normal ctermbg=NONE
hi NormalNC ctermbg=NONE
hi EndOfBuffer ctermbg=NONE
hi ExtraWhitespace ctermbg=Yellow
hi Folded cterm=italic ctermfg=Black ctermbg=Red
hi LineLengthError ctermbg=Red
hi CursorLine cterm=NONE ctermbg=Black
hi cursorcolumn cterm=NONE ctermbg=Black

au BufRead,BufNewFile {*.md,*.mkd,*.markdown}           set ft=markdown
au BufNewFile,BufRead {*.js,*.jsx}                      set ft=javascript
au BufNewFile,BufRead {*ts,*.tsx}                       set ft=typescript
au BufRead,BufNewFile {*.jar,*.war,*.ear,*.sar,*.rar}   set ft=zip
au BufNewFile,BufRead {*.ex,*.exs}                      set ft=elixir
au BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md Prettier
au BufNewFile,BufRead {*.txt,*.md}                      setlocal spell spelllang=en_us
au BufRead,InsertLeave * match ExtraWhitespace /\s\+$/
au BufRead,InsertEnter,InsertLeave * 2match LineLengthError /\%121v.*/
au ColorScheme * hi ExtraWhitespace ctermbg=red guibg=red
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
nn s <CMD>Telescope git_files<CR>
nn <LocalLeader>gs <CMD>Telescope grep_string<CR>
nn <LocalLeader>bb <CMD>Telescope buffers<CR>
nn <LocalLeader>s <CMD>Telescope lsp_definitions<CR>
nn <LocalLeader>td <CMD>Telescope lsp_type_definitions<CR>
nn <LocalLeader>im <CMD>Telescope lsp_implementations<CR>
nn <LocalLeader>r <CMD>Telescope lsp_references<CR>
nn <S-Tab> <C-W><C-W>
nn <LocalLeader>t <CMD>Telescope<CR>


map <silent> <LocalLeader>ws :%s/\s\+$//e<CR>
map <silent> <LocalLeader>hws :highlight clear ExtraWhitespace<CR>
map <silent> <LocalLeader>cc :TComment<CR>

"      Insert Mode
imap <C-L> <SPACE>=><SPACE>
imap <C-S> \|><SPACE>
imap <C-F> <Plug>(emoji-start-complete)
imap <Tab> <c-x><c-o>

"      Command Line

" gitgutter
let g:gitgutter_sign_added = emoji#for('seedling')
let g:gitgutter_sign_modified = emoji#for('construction')
let g:gitgutter_sign_removed = emoji#for('axe')
let g:gitgutter_sign_modified_removed = emoji#for('children_crossing')
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

let g:emoji_complete_overwrite_standard_keymaps = 0
let maplocalleader="\<Space>"
imap <C-L> <SPACE>=><SPACE>
imap <C-G> \|><SPACE>
imap <C-F> <Plug>(emoji-start-complete)
map <LocalLeader>ee :%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>
map <LocalLeader>cc :TComment<CR>
nmap <C-k> <Plug>(ale_previous_wrap)
nmap <C-j> <Plug>(ale_next_wrap)
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


" Allow local settings overrides with ~/.vimrc.local
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" LUA (LSP Stuff)
lua << EOF
-- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
  snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<Tab>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.elixirls.setup{
  cmd = { "/Users/mp/.config/elixir-ls/release/language_server.sh" },
  dialyzerEnabled = false,
  fetchDeps = false,
    capabilities = capabilities
}
lspconfig.tsserver.setup{
    capabilities = capabilities
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<LocalLeader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<C-j>', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<C-k>', vim.diagnostic.goto_next)
vim.keymap.set('n', '<LocalLeader>q', vim.diagnostic.setloclist)


local signs = { Error = "💀", Warn = "💥", Hint = "✨", Info = "ℹ️" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
EOF
