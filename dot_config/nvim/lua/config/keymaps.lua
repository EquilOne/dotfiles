-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remap clipboard behavior
-- Use 'yy' to yank (copy) to the system clipboard
vim.keymap.set("n", "yy", '"+yy', { desc = "Yank current line to system clipboard" })

-- Use 'y' motion to yank (copy) to the system clipboard
vim.keymap.set("n", "y", '"+y', { desc = "Yank to system clipboard (motion)" })
vim.keymap.set("v", "y", '"+y', { desc = "Yank to system clipboard (visual)" })

-- Use 'p' to paste from the system clipboard
vim.keymap.set("n", "p", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set("n", "P", '"+P', { desc = "Paste from system clipboard before cursor" })
vim.keymap.set("v", "p", '"+p', { desc = "Paste from system clipboard (visual)" })
