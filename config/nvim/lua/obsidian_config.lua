require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Documents/melissanotes",
    },
  },
  daily_notes = {
    folder = "notes/dailies",
    date_format = "%Y-%m-%d",
    default_tags = { "daily-notes" },
    template = nil
  }
})
