return {
  -- { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  -- 'nyoom-engineering/oxocarbon.nvim',
  'rose-pine/neovim',
  name = 'rose-pine',
  config = function()
    vim.cmd 'colorscheme rose-pine'
  end,
  -- 'rebelot/kanagawa.nvim',
}
