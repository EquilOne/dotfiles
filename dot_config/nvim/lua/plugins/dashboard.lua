return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    table.insert(opts.dashboard.preset.keys, 8, {
      icon = " ",
      key = "o",
      desc = "Obsidian Vault",
      action = ":lua Snacks.picker.files({ cwd = vim.fn.expand('~/Documents/ObsidianVault/') })",
    })
  end,
}
