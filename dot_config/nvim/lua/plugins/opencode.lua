return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
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
      "<leader>ao",
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
    -- Scrolling (unchanged for easy access)
    {
      "<S-C-u>",
      function()
        require("opencode").command("messages_half_page_up")
      end,
      desc = "Scroll AI Up",
      mode = "n",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("messages_half_page_down")
      end,
      desc = "Scroll AI Down",
      mode = "n",
    },
  },
  config = function()
    local opencode_cmd = "opencode --port"

    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = "bottom", -- 'right', 'left', 'bottom', 'top', 'float'
        enter = false,
        on_win = function(win)
          -- Required: sets up opencode keymaps + cleanup in the terminal
          require("opencode.terminal").setup(win.win)
        end,
      },
    }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
        stop = function()
          require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close()
        end,
        toggle = function()
          require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    vim.o.autoread = true
  end,
}
