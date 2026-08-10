-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.mousescroll = "ver:1,hor:1"
vim.opt.textwidth = 0
vim.opt.colorcolumn = "+1"

-- Prose filetypes: opt-in hard wrap (LazyVim core re-adds 't' globally, but 't' only wraps at textwidth > 0)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "rst", "tex", "asciidoc", "gitcommit", "mail", "org" },
  callback = function()
    vim.opt_local.formatoptions:append("t")
    if vim.bo.textwidth == 0 then
      vim.opt_local.textwidth = 80
    end
  end,
})
-- Markdown is intentionally excluded: wrapping handled by prettier + markdownlint-cli2
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.formatoptions:remove("t")
  end,
})
