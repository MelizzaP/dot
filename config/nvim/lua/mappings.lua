-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<LocalLeader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<LocalLeader>j', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<LocalLeader>k', vim.diagnostic.goto_next)
vim.keymap.set('n', '<LocalLeader>q', vim.diagnostic.setloclist)

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "󱕅",
    },
  },
})
