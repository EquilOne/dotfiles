-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.mousescroll = "ver:1,hor:1"
vim.opt.textwidth = 0
vim.opt.colorcolumn = "+1"
vim.opt.formatoptions:remove("t")

vim.api.nvim_create_autocmd("FileType", {
  -- markdown excluded: wrapping handled by prettier + markdownlint-cli2 via vault config
  pattern = {
    "text",
    "rst",
    "tex",
    "asciidoc",
    "gitcommit",
    "mail",
    "org",
  },
  callback = function()
    vim.opt_local.formatoptions:append("t")
  end,
})
