local daily_notes_dir = os.getenv("OBSIDIAN_DAILY_DIR") or "Instinct Science/Daily Notes/"
local daily_notes_template = os.getenv("OBSIDIAN_DAILY_DIR") or "~/Documents/melissanotes/templates/dailies.md"
require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Documents/melissanotes",
    },
  },
  daily_notes = {
    folder = daily_notes_dir,
    date_format = "%Y-%m-%d",
    default_tags = { "daily-notes" },
    template = 'dailies.md'
  },
  -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
  -- URL it will be ignored but you can customize this behavior here.
  ---@param url string
  follow_url_func = function(url)
    -- Open the URL in the default web browser.
    vim.fn.jobstart({"open", url})  -- Mac OS
    -- vim.fn.jobstart({"xdg-open", url})  -- linux
    -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    -- vim.ui.open(url) -- need Neovim 0.10.0+
  end,
    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
  -- file it will be ignored but you can customize this behavior here.
  ---@param img string
  follow_img_func = function(img)
    vim.fn.jobstart { "qlmanage", "-p", img }  -- Mac OS quick look preview
    -- vim.fn.jobstart({"xdg-open", url})  -- linux
    -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
  end,
  templates = {
    folder = "templates",
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
    -- A map for custom variables, the key should be the variable and the value a function
    substitutions = {},
  },
 -- Optional, customize how note file names are generated given the ID, target directory, and title.
  ---@param spec { id: string, dir: obsidian.Path, title: string|? }
  ---@return string|obsidian.Path The full path to the new note.
  note_path_func = function(spec)
    -- This is equivalent to the default behavior.
    local path = spec.dir / spec.title
    return path:with_suffix(".md")
  end,
})
