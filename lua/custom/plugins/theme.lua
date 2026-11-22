local fallback = 'rose-pine'

local function read_omarchy_theme()
  for _, dir in ipairs {
    vim.fn.expand '~/.local/state/omarchy/current/theme',
    vim.fn.expand '~/.config/omarchy/current/theme',
  } do
    local ok, specs = pcall(dofile, dir .. '/neovim.lua')
    if ok and type(specs) == 'table' then
      local plugins = {}
      local colorscheme
      for _, spec in ipairs(specs) do
        -- Omarchy supplies plugin specs for lazy.nvim and a colorscheme choice for LazyVim.
        if type(spec) == 'table' and spec[1] == 'LazyVim/LazyVim' then
          colorscheme = type(spec.opts) == 'table' and spec.opts.colorscheme
        else
          plugins[#plugins + 1] = spec
        end
      end
      if type(colorscheme) == 'string' and colorscheme ~= '' then
        return plugins, colorscheme, dir
      end
    end
  end
  return {}
end

local function omarchy_background(dir)
  if vim.fn.executable 'omarchy' == 1 then
    local mode = vim.trim(vim.fn.system { 'omarchy', 'theme', 'color', '--file', dir .. '/colors.toml', 'mode' })
    if vim.v.shell_error == 0 and (mode == 'light' or mode == 'dark') then
      return mode
    end
  end
  return vim.fn.filereadable(dir .. '/light.mode') == 1 and 'light' or 'dark'
end

local plugins, colorscheme, theme_dir = read_omarchy_theme()
table.insert(plugins, 1, { 'rose-pine/neovim', name = fallback })

return {
  plugins = plugins,
  apply = function()
    if theme_dir then
      vim.o.background = omarchy_background(theme_dir)
      if pcall(vim.cmd.colorscheme, colorscheme) then
        return
      end
    end
    vim.o.background = 'dark'
    vim.cmd.colorscheme(fallback)
  end,
}
