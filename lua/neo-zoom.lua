local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------

local M = {}

-- when to check the map is valid (i.e. the parent doesn't get closed on child-exist)
M.parent_info_from_buf = {}

local function pin_to_80_percent_height()
  local scrolloff = 7
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
  end
end

local function restore_cursor_on(cur_pos, last_buf)
  if (vim.api.nvim_get_current_buf() == last_buf) then
    vim.api.nvim_win_set_cursor(0, cur_pos)
  end
end

local function close_tab_properly()
  if (vim.fn.tabpagenr('$') ~= vim.api.nvim_tabpage_get_number(0)) then
    vim.cmd('tabc')
    vim.cmd('tabp')
  else
    vim.cmd('tabc')
  end
end

function M.maximize_current_split()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local cur_buf = vim.api.nvim_get_current_buf()
  -- if on zoom-in, zoom-out
  if M.parent_info_from_buf[cur_buf] ~= nil then
    -- should close the tab on zoom-out: should check that there is no other splits
    vim.cmd('tabc')
    -- restore the cursor
    local win_p, buf_p, cur_p = M.parent_info_from_buf[cur_buf]
    -- TODO: didn't consider the case that the win_p doesn't exist anymore
    vim.api.nvim_set_current_win(win_p)
    -- TODO: how to prevent one to change the zoom-in buffer to one another. Or allow them to do so
    vim.api.nvim_set_current_buf(cur_buf)
    restore_cursor_on(cur_p, buf_p)
    -- TODO: should change statusline color here
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_var('non_float_total', 0)
  vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")
  vim.api.nvim_set_current_win(cur_win)
  if (vim.api.nvim_get_var('non_float_total') == 1) then
    return
  end
  -- register current state into parent_info_from_buf
  M.parent_info_from_buf[cur_buf] = {
    vim.api.nvim_get_current_win(),
    vim.api.nvim_get_current_buf(),
    vim.api.nvim_win_get_cursor(0)
  }
  vim.cmd('tab split')
  pin_to_80_percent_height()
  -- TODO: should change statusline color here
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.maximize_current_split()
  ]]
end

setup_vim_commands()

return M
