require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Documents/melissanotes",
    },
  },
  daily_notes = {
    -- TODO: it would be nice to import this from a config file
    folder = "Instinct Science/Daily Notes/",
    date_format = "%Y-%m-%d",
    default_tags = { "daily-notes" },
    template = nil
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
})
