-- LSP configuration using vim.lsp.config API (Neovim 0.11+)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Expert: official Elixir language server
vim.lsp.config.expert = {
  cmd = { "expert", "--stdio=true" },
  filetypes = { "elixir", "eelixir", "heex" },
  capabilities = capabilities,
  root_dir = vim.fs.root(0, { "mix.exs", ".git" }) or vim.uv.os_homedir(),
}
vim.lsp.enable("expert")

-- TypeScript
vim.lsp.config.ts_ls = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  capabilities = capabilities,
  root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }) or vim.uv.os_homedir(),
}
vim.lsp.enable("ts_ls")

-- Python
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
  root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" }) or vim.uv.os_homedir(),
}
vim.lsp.enable("pyright")

vim.lsp.config.ruff = {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  capabilities = capabilities,
  root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" }) or vim.uv.os_homedir(),
}
vim.lsp.enable("ruff")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ex", "*.exs", "*.heex", "*.py" },
  callback = function()
    local has_formatter = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.server_capabilities.documentFormattingProvider then
        has_formatter = true
        break
      end
    end
    if has_formatter then
      vim.lsp.buf.format({ async = false, timeout_ms = 1500 })
    end
  end,
})

-- Buffer-local LSP mappings on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

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
