local opts = {} -- picker options
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
local theme = themes.get_ivy(opts)
local setup = {
  defaults = {},
  pickers = {
    find_files = { theme = "ivy" },
    buffers = { theme = "ivy" },
    grep_string = { theme = "ivy" },
    live_grep = { theme = "ivy" },
    lsp_references = {
      theme = "ivy",
      path_display = { "tail" }
    },
    diagnostics = { theme = "ivy" },
    git_branches = { theme = "ivy" },
    git_status = { theme = "ivy" },
    git_commits = { theme = "ivy" },
    git_bcommits = { theme = "ivy" },
    git_stash = { theme = "ivy" },
    jumplist = { theme = "ivy" },
    spell_suggest = { theme = "ivy" },
    marks = { theme = "ivy" },
  },
  extensions = {
   frequency = {
      auto_validate = false,
      matcher = "fuzzy",
      path_display = { "filename_first" }
    },
    media_files = {
      filetypes = {"png", "jpg", "jpeg", "pdf"},
    }
  }
}
require('telescope').setup(setup)
require('telescope').load_extension('nerdy')
require('telescope').load_extension('frecency')
require('telescope').load_extension('media_files')
