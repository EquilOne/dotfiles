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

-- Unbind  'Alt + h,j,k,l'
vim.keymap.del("n", "<A-j>", { silent = true })
vim.keymap.del("n", "<A-k>", { silent = true })
vim.keymap.del("v", "<A-j>", { silent = true })
vim.keymap.del("v", "<A-k>", { silent = true })

-- Use '<leader> + j' to join lines
vim.keymap.set("n", "<leader>j", "J", { desc = "Join Lines" })

-- Use 'Shift + j/k' to move lines down/up
vim.keymap.set("n", "<S-j>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
vim.keymap.set("n", "<S-k>", "<cmd>m .-2<cr>==", { desc = "Move Line Down" })

-- Visual mode: Move selected lines
vim.keymap.set("v", "<S-j>", ":m '>+1<cr>gv=gv", { desc = "Move Lines Down " })
vim.keymap.set("v", "<S-k>", ":m '<-2<cr>gv=gv", { desc = "Move Lines Up " })
