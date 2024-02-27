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
  Plug 'junegunn/vim-emoji'
  Plug 'kyuhi/vim-emoji-complete'
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
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make'}
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
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'pwntester/octo.nvim'
  Plug 'mhinz/vim-signify'
call plug#end()

" ========= GENERAL SETTINGS =============
set backspace=indent,eol,start
set clipboard=unnamed
set completefunc=emoji#complete
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

" ========= COLORS & HIGHLIGHTS =============
let g:everforest_background = 'soft'
let g:everforest_better_performance = 1

colorscheme everforest
hi Normal ctermbg=NONE
hi NormalNC ctermbg=NONE
hi EndOfBuffer ctermbg=NONE
hi ExtraWhitespace ctermbg=Black
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
imap <C-F> <Plug>(emoji-start-complete)
imap <Tab> <c-x><c-o>

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

let g:emoji_complete_overwrite_standard_keymaps = 0
let maplocalleader="\<Space>"

let g:signify_number_highlight = 1
let g:signify_sign_add               = ''
let g:signify_sign_delete            = ''
let g:signify_sign_delete_first_line = ''
let g:signify_sign_change            = ''
let g:signify_sign_change_delete     = ''

let g:mix_format_on_save = 1

imap <C-L> <SPACE>=><SPACE>
imap <C-G> \|><SPACE>
imap <C-F> <Plug>(emoji-start-complete)
map <LocalLeader>ee :%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>
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


" Allow local settings overrides with ~/.vimrc.local
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" LUA (LSP Stuff)
lua << EOF
-- Set up nvim-cmp.
  local lspkind = require('lspkind')
  local cmp = require'cmp'

  cmp.setup({
  snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol',
        maxwidth = 50,
        ellipsis_char = '...',
      })
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
  dialyzerEnabled = true,
  fetchDeps = false,
  capabilities = capabilities
}
lspconfig.tsserver.setup{
    capabilities = capabilities
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<LocalLeader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<LocalLeader>j', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<LocalLeader>k', vim.diagnostic.goto_next)
vim.keymap.set('n', '<LocalLeader>q', vim.diagnostic.setloclist)


local signs = { Error = "󱚟", Warn = "󰅏", Hint = "󰞸", Info = "󱕅" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Tree Sitter Config
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    "typescript",
    "tsx",
    "elixir",
    "heex",
    "eex",
    "html",
    "javascript",
    "json",
    "scss",
    "mermaid",
    "erlang",
    "markdown",
    "css",
    "sql",
    "fsh",
    "graphql"
    },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true }
}

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
    vim.keymap.set('n', 'KK', vim.lsp.buf.signature_help, opts)
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

-- Octo Configuration
require"octo".setup({
  use_local_fs = false,                    -- use local files on right side of reviews
  enable_builtin = false,                  -- shows a list of builtin actions when no action is provided
  default_remote = {"upstream", "origin"}; -- order to try remotes
  ssh_aliases = {},                        -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`
  reaction_viewer_hint_icon = "";         -- marker for user reactions
  user_icon = " ";                        -- user icon
  timeline_marker = "";                   -- timeline marker
  timeline_indent = "2";                   -- timeline indentation
  right_bubble_delimiter = "";            -- bubble delimiter
  left_bubble_delimiter = "";             -- bubble delimiter
  github_hostname = "";                    -- GitHub Enterprise host
  snippet_context_lines = 4;               -- number or lines around commented lines
  gh_env = {},                             -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
  timeout = 5000,                          -- timeout for requests between the remote server
  ui = {
    use_signcolumn = true,                 -- show "modified" marks on the sign column
  },
  issues = {
    order_by = {                           -- criteria to sort results of `Octo issue list`
      field = "CREATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
      direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
    }
  },
  pull_requests = {
    order_by = {                           -- criteria to sort the results of `Octo pr list`
      field = "CREATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
      direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
    },
    always_select_remote_on_create = false -- always give prompt to select base remote repo when creating PRs
  },
  file_panel = {
    size = 10,                             -- changed files panel rows
    use_icons = true                       -- use web-devicons in file panel (if false, nvim-web-devicons does not need to be installed)
  },
  mappings = {
    issue = {
      close_issue = { lhs = "<space>ic", desc = "close issue" },
      reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
      list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
      reload = { lhs = "<C-r>", desc = "reload issue" },
      open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
      copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      create_label = { lhs = "<space>lc", desc = "create label" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    pull_request = {
      checkout_pr = { lhs = "<space>po", desc = "checkout PR" },
      merge_pr = { lhs = "<space>pm", desc = "merge commit PR" },
      squash_and_merge_pr = { lhs = "<space>psm", desc = "squash and merge PR" },
      list_commits = { lhs = "<space>pc", desc = "list PR commits" },
      list_changed_files = { lhs = "<space>pf", desc = "list PR changed files" },
      show_pr_diff = { lhs = "<space>pd", desc = "show PR diff" },
      add_reviewer = { lhs = "<space>va", desc = "add reviewer" },
      remove_reviewer = { lhs = "<space>vd", desc = "remove reviewer request" },
      close_issue = { lhs = "<space>ic", desc = "close PR" },
      reopen_issue = { lhs = "<space>io", desc = "reopen PR" },
      list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
      reload = { lhs = "<C-r>", desc = "reload PR" },
      open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
      copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
      goto_file = { lhs = "gf", desc = "go to file" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      create_label = { lhs = "<space>lc", desc = "create label" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    review_thread = {
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      add_suggestion = { lhs = "<space>sa", desc = "add suggestion" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    submit_win = {
      approve_review = { lhs = "<C-a>", desc = "approve review" },
      comment_review = { lhs = "<C-m>", desc = "comment review" },
      request_changes = { lhs = "<C-r>", desc = "request changes review" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
    },
    review_diff = {
      add_review_comment = { lhs = "<space>ca", desc = "add a new review comment" },
      add_review_suggestion = { lhs = "<space>sa", desc = "add a new review suggestion" },
      focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
      toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
      next_thread = { lhs = "]t", desc = "move to next thread" },
      prev_thread = { lhs = "[t", desc = "move to previous thread" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
      goto_file = { lhs = "gf", desc = "go to file" },
    },
    file_panel = {
      next_entry = { lhs = "j", desc = "move to next changed file" },
      prev_entry = { lhs = "k", desc = "move to previous changed file" },
      select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
      refresh_files = { lhs = "R", desc = "refresh changed files panel" },
      focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
      toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
    }
  }
})
EOF
