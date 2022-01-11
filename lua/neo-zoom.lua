local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------

local M = {}

local function pin_to_80_percent_height()
  local old_scrolloff = vim.opt.scrolloff
  vim.opt.scrolloff = 7
  vim.cmd("exe 'normal! zt'")
  vim.opt.scrolloff = old_scrolloff
end

function M.maximize_current_split()
  if (vim.bo.filetype == 'qf'
    or vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal') then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_var('non_float_total', 0)
  vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")
  vim.api.nvim_set_current_win(cur_win)
  if (vim.api.nvim_get_var('non_float_total') == 1) then
    if (vim.fn.tabpagenr('$') == 1) then
      vim.cmd('tab split')
      pin_to_80_percent_height()
      return
    end
    local last_cursor = vim.api.nvim_win_get_cursor(0)
    local cur_buf = vim.api.nvim_get_current_buf()
    if (vim.fn.tabpagenr('$') ~= vim.api.nvim_tabpage_get_number(0)) then
      vim.cmd('tabc')
      vim.cmd('tabp')
    else
      vim.cmd('tabc')
    end
    if (vim.api.nvim_get_current_buf() == cur_buf) then
      vim.api.nvim_win_set_cursor(0, last_cursor)
    end
    pin_to_80_percent_height()
  else
    vim.cmd('tab split')
    pin_to_80_percent_height()
  end
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.maximize_current_split()
  ]]
end

setup_vim_commands()

return M
