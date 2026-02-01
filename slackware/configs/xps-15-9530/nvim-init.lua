-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- VSCode-like colorscheme
  { "Mofiqul/vscode.nvim" },

  -- Commenting
  { "numToStr/Comment.nvim", config = true },

  -- Move lines up/down
  { "matze/vim-move" },

  -- Indent with Tab/Shift-Tab in visual mode
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
})

-- Set colorscheme
vim.cmd("colorscheme vscode")

-- Line numbers
vim.opt.number = true

-- Paste mode: auto-detect paste (no need for :set paste)
vim.opt.paste = false
vim.api.nvim_set_keymap('i', '<C-v>', '<C-o>"+gP', { noremap = true, silent = true })

-- Comment/uncomment with Ctrl+/
vim.api.nvim_set_keymap('n', '<C-_>', 'gcc', { noremap = false })
vim.api.nvim_set_keymap('v', '<C-_>', 'gc', { noremap = false })

-- Move lines up/down with Ctrl+Shift+Arrow
vim.g.move_key_modifier = 'C-S'
vim.g.move_key_up = '<C-S-Up>'
vim.g.move_key_down = '<C-S-Down>'
vim.g.move_key_left = '<C-S-Left>'
vim.g.move_key_right = '<C-S-Right>'

-- Indent/Unindent with Tab/Shift-Tab in visual mode
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- Ctrl+Z for undo (redundant, but explicit)
vim.api.nvim_set_keymap('n', '<C-z>', 'u', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })

-- Ctrl+Y for redo
vim.api.nvim_set_keymap('n', '<C-y>', '<C-r>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-y>', '<C-o><C-r>', { noremap = true, silent = true })
