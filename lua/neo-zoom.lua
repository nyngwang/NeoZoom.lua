local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------

local M = {}

function M.maximize_current_split()
  if (vim.bo.filetype == "qf") then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_var('non_float_total', 0)
  vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")
  vim.api.nvim_set_current_win(cur_win)
  if (vim.api.nvim_get_var('non_float_total') == 1) then
    if (vim.fn.tabpagenr('$') == 1) then
      return
    end
    local last_tab = vim.api.nvim_get_current_tabpage()
    vim.cmd("tabclose")
    vim.api.nvim_set_current_tabpage(last_tab)
  else
    local last_cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd('tabedit ' .. (vim.api.nvim_buf_get_name(0) == '' and '' or '%:p'))
    vim.api.nvim_win_set_cursor(0, last_cursor)
  end
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.maximize_current_split()
  ]]
end

setup_vim_commands()

return M
