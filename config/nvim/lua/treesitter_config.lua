require('nvim-treesitter.configs').setup({
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
})
