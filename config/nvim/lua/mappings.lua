-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<LocalLeader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<LocalLeader>j', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<LocalLeader>k', vim.diagnostic.goto_next)
vim.keymap.set('n', '<LocalLeader>q', vim.diagnostic.setloclist)

local signs = { Error = " ", Warn = " ", Hint = " 󱕅", Info = " 󰅏" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
