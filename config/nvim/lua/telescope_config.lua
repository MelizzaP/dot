local opts = {} -- picker options
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
local theme = themes.get_ivy(opts)

require('telescope').setup{
  defaults = { },
  pickers = {
    find_files = {
      theme = "get_ivy,
    },
  },
  extensions = {}
}
