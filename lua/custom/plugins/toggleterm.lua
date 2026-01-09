return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>'),
}
