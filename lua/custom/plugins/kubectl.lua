return {
  {
    'ramilito/kubectl.nvim',
    -- use a release tag to download pre-built binaries
    version = 'v2.40.5',
    -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'make build',
    -- OR if you use nix, build from source with:
    -- build = 'nix run .#build-plugin',
    dependencies = 'saghen/blink.download',
    config = function()
      require('kubectl').setup()
    end,
    keys = {
      { '<leader>k', '<cmd>lua require("kubectl").toggle()<cr>' },
      { '<C-k>', '<Plug>(kubectl.kill)', ft = 'k8s_*' },
      { '6', '<Plug>(kubectl.view_crds)', ft = 'k8s_*' },
      { '7', '<Plug>(kubectl.view_nodes)', ft = 'k8s_*' },
      { '8', '<Plug>(kubectl.view_overview)', ft = 'k8s_*' },
      { '9', '<Plug>(kubectl.view_statefulsets)', ft = 'k8s_*' },
      { '<C-t>', '<Plug>(kubectl.view_top)', ft = 'k8s_*' },
    },
  },
}
