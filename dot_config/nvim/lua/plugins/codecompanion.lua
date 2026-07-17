return {
  "olimorris/codecompanion.nvim",
  version = false,
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "stevearc/dressing.nvim" },
  keys = {
    { "ga", "<cmd>'<,'>CodeCompanion<cr>", mode = "v", desc = "CodeCompanion inline edit" },
    {
      "go",
      function()
        return require("codecompanion").operator()
      end,
      expr = true,
      mode = { "n", "x" },
      desc = "CodeCompanion operator",
    },
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        acp = {
          opencode = function()
            return require("codecompanion.adapters").extend("opencode", {
              defaults = {
                timeout = 30000,
              },
            })
          end,
        },
      },
      interactions = {
        inline = {
          adapter = "opencode",
        },
      },
    })
  end,
}
