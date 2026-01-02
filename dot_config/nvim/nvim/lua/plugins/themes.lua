return {
  -- Configure Rose Pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "moon",
      styles = {
        transparency = true,
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- Set Rose Pine as the default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
  },
  -- Disable unused themes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}
