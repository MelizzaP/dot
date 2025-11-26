-- Set up LSP using the new vim.lsp.config API (Neovim 0.11+)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers using vim.lsp.config
local elixirls_config = {
  cmd = { "/Users/mp/.lsps/elixir-ls/release/language_server.sh" },
  filetypes = { "elixir", "eelixir", "heex" },
  capabilities = capabilities,
  dialyzerEnabled = true,
  fetchDeps = false,
  root_dir = vim.fs.root(0, {"mix.exs", ".git"}) or vim.uv.os_homedir()
}

local nextls_config = {
    cmd = {"nextls", "--stdio"},
      init_options = {
        extensions = {
          credo = { enable = true }
        },
      experimental = {
        completions = {
          enable = true -- control if completions are enabled. defaults to false
        }
      }
    },
    capabilities = capabilities,
    root_dir = vim.fs.root(0, {"mix.exs", ".git"}) or vim.uv.os_homedir()
}

local lexical_config = {
  cmd = { "/Users/mp/.lsps/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
  filetypes = { "elixir", "eelixir", "heex" },
  capabilities = capabilities,
  fetchDeps = false,
  root_dir = vim.fs.root(0, {"mix.exs", ".git"}) or vim.uv.os_homedir()
}

-- Register custom lexical server
vim.lsp.config.lexical = {
  cmd = lexical_config.cmd,
  filetypes = lexical_config.filetypes,
  root_dir = lexical_config.root_dir,
  capabilities = lexical_config.capabilities,
  settings = lexical_config.settings,
}

-- Setup language servers
vim.lsp.enable('lexical')
-- vim.lsp.enable('elixirls') -- commented out as in original

-- TypeScript language server
vim.lsp.config.ts_ls = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  capabilities = capabilities,
  root_dir = vim.fs.root(0, {"package.json", "tsconfig.json", ".git"}) or vim.uv.os_homedir()
}
vim.lsp.enable('ts_ls')

-- Python language server
vim.lsp.config.pyright = {
  capabilities = capabilities,
  root_dir = vim.fs.root(0, {"pyproject.toml", "setup.py", ".git"}) or vim.uv.os_homedir()
}
vim.lsp.enable('pyright')

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
