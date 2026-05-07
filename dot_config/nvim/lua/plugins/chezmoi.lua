return {
  "xvzc/chezmoi.nvim",
  opts = {
    edit = {
      watch = true,
      force = true,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { vim.env.HOME .. "/.local/share/chezmoi/*" },
      callback = function()
        require("chezmoi.commands.__edit").watch()
      end,
    })
  end,
}
