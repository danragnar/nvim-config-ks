-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
    'ibhagwan/fzf-lua', -- optional
    'echasnovski/mini.pick', -- optional
  },
  -- vim.keymap.set('n', '<leader>gf', '<cmd>Neogit kind=floating<CR>'),
  vim.keymap.set('n', '<Leader>gf', function()
    require('neogit').open { cwd = vim.fn.expand '%:p:h' }
  end),
}
