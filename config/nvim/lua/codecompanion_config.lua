-- TODO: change ctrl-c to esc to close chat
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "openai",
      keymaps = {
        close = {
          modes = { n = "<C-c>", i = "<C-x>" },
          opts = {},
        }
      }
    },
    inline = {
      adapter = "openai",
    },
  },
  display = {
    action_palette = {
      width = 50,
      height = 10,
      prompt = "Prompt ", -- Prompt used for interactive LLM calls
      provider = "telescope", -- default|telescope|mini_pick
      opts = {
        show_default_actions = true, -- Show the default actions in the action palette?
        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
      },
    },
  },
  prompt_library = {
    ["Dinosaur"] = {
      strategy = "chat",
      description = "Write documentation for me",
      opts = {
        index = 11,
        is_slash_cmd = false,
        auto_submit = false,
        short_name = "docs",
      },
      references = {
        {
          type = "file",
          path = {
            "doc/.vitepress/config.mjs",
            "lua/codecompanion/config.lua",
            "README.md",
          },
        },
      },
      prompts = {
        {
          role = "user",
          content = [[I'm a dinosaur, I like to use dinosaur language for variable names when coding.

            I ate eggs this morning and my tummy hurts.
          ]],
        },
      },
    },
  },
})

