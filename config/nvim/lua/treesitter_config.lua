-- nvim-treesitter 1.0+ uses Neovim's built-in treesitter APIs
-- Parsers are installed via :TSInstall <lang>

-- Enable treesitter-based highlighting for all supported filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Enable treesitter-based indentation
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
