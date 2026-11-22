local errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
  if level and level >= vim.log.levels.ERROR then
    errors[#errors + 1] = message
  end
  notify(message, level, opts)
end

local function smoke()
  assert(vim.v.errmsg == '', vim.v.errmsg)
  assert(#errors == 0, table.concat(errors, '\n'))

  for name, plugin in pairs(require('lazy.core.config').plugins) do
    assert(plugin._.installed, 'Lazy did not install ' .. name)
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), ('%s %s failed: %s'):format(name, task.name, task:output()))
    end
  end

  assert(vim.g.colors_name == 'rose-pine', 'Rose Pine did not load')
  assert(vim.lsp.is_enabled 'lua_ls', 'Lua LSP was not enabled')
  assert(type(require('telescope').extensions.fzf.native_fzf_sorter) == 'function', 'Telescope native sorter did not load')

  local treesitter = require 'nvim-treesitter'
  assert(
    vim.wait(120000, function()
      local parsers = treesitter.get_installed 'parsers'
      return vim.list_contains(parsers, 'markdown') and vim.list_contains(parsers, 'markdown_inline')
    end, 100),
    'Tree-sitter did not install the Markdown parsers'
  )

  vim.cmd.edit(vim.fn.tempname() .. '.md')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# Smoke test', '', '**Markdown**' })
  assert(vim.bo.filetype == 'markdown', 'Markdown filetype was not detected')
  assert(vim.fn.exists ':RenderMarkdown' == 2, 'RenderMarkdown did not load')
  local parser = vim.treesitter.get_parser(0)
  assert(parser and not parser:parse()[1]:root():has_error(), 'Tree-sitter could not parse Markdown')

  vim.g.mkdp_open_ip = '127.0.0.1'
  vim.g.mkdp_browserfunc = 'SmokePreviewUrl'
  vim.cmd [[
    function! SmokePreviewUrl(url)
      let g:smoke_preview_url = a:url
    endfunction
  ]]
  vim.cmd.MarkdownPreview()
  assert(
    vim.wait(10000, function()
      return vim.g.smoke_preview_url ~= nil
    end),
    'MarkdownPreview did not start its local server'
  )
  -- The preview server calls back into Neovim while handling the HTTP request.
  local response
  local curl = { 'curl', '--fail', '--silent', '--show-error', '--max-time', '5', '--noproxy', '127.0.0.1', vim.g.smoke_preview_url }
  vim.system(curl, { text = true }, function(result)
    response = result
  end)
  assert(
    vim.wait(10000, function()
      return response ~= nil
    end),
    'MarkdownPreview HTTP check timed out'
  )
  vim.cmd.MarkdownPreviewStop()
  assert(response.code == 0, response.stderr)
  assert(response.stdout:lower():find('<html', 1, true), 'MarkdownPreview did not serve an HTML page')
  assert(#errors == 0, table.concat(errors, '\n'))
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = vim.schedule_wrap(function()
    local ok, err = xpcall(smoke, debug.traceback)
    if not ok then
      vim.api.nvim_err_writeln(err)
      vim.cmd.cquit()
    end
    print 'Neovim smoke tests passed'
    vim.cmd 'qa!'
  end),
})
