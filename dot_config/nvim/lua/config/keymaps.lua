-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Clipboard: yank/paste/delete go to the system clipboard ("+ register,
-- provided by wl-clipboard). Foot passes Super through as a modifier, so
-- the <D-*> maps give GUI-style Ctrl+C/X/V muscle memory in the terminal;
-- they are harmless in terminals that consume Super themselves.
vim.keymap.set({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "p", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set({ "n", "v" }, "d", '"+d', { desc = "Delete to system clipboard" })
vim.keymap.set("n", "P", '"+P', { desc = "Paste from system clipboard before cursor" })

-- Super-key universal clipboard maps (n/v/x modes)
vim.keymap.set({ "n", "v", "x" }, "<D-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v", "x" }, "<D-x>", '"+d', { desc = "Cut to system clipboard" })
vim.keymap.set({ "n", "v", "x" }, "<D-v>", '"+p', { desc = "Paste from system clipboard" })

-- Exit floating terminal with double tap ESC
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
