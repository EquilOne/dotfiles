return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    -- Ensure which-key is told about our new "ai" group
    {
      "folke/which-key.nvim",
      opts = {
        spec = {
          { "<leader>a", group = "ai", icon = "󰚩 " }, -- Custom AI icon and group name
        },
      },
    },
  },
  -- Define keys here for lazy-loading and Which-Key integration
  keys = {
    {
      "<leader>aa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask OpenCode",
      mode = { "n", "x" },
    },
    {
      "<leader>ax",
      function()
        require("opencode").select()
      end,
      desc = "OpenCode Actions",
      mode = { "n", "x" },
    },
    {
      "<leader>at",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle OpenCode",
      mode = { "n", "t" },
    },
    -- Operator binds (unchanged for easy access)
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Add range to OpenCode",
      expr = true,
      mode = { "n", "x" },
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Add line to OpenCode",
      expr = true,
      mode = "n",
    },
    -- Scrolling (unchanged for easy access)
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll AI Up",
      mode = "n",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll AI Down",
      mode = "n",
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true
  end,
}
