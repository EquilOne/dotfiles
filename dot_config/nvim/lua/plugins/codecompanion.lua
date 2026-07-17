return {
  "olimorris/codecompanion.nvim",
  version = false,
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "stevearc/dressing.nvim" },
  keys = {
    { "ga", "<cmd>'<,'>CodeCompanion<cr>", mode = "v", desc = "AI inline edit" },
    {
      "go",
      function()
        return require("codecompanion").operator()
      end,
      expr = true,
      mode = { "n", "x" },
      desc = "AI operator",
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
        http = {
          openrouter = function()
            return require("codecompanion.adapters").extend("openrouter", {
              env = {
                api_key = os.getenv("OPENROUTER_API_KEY"),
              },
              schema = {
                model = {
                  default = "qwen/qwen3-coder-30b-a3b-instruct",
                },
              },
            })
          end,
        },
      },
      interactions = {
        inline = {
          adapter = "openrouter",
        },
      },
    })
  end,
}
