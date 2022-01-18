local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}

M.parent_info_from_win = {} -- use window to search parent info {win,buf,curs,tab}

local function migration_parent_info(from_win, to_win)
  M.parent_info_from_win[to_win] = M.parent_info_from_win[from_win]
  M.parent_info_from_win[from_win] = nil
end

function M.neo_vsplit()
  local right_win = vim.api.nvim_get_current_win()
  vim.cmd('vsplit')
  local left_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd l')
  if right_win == left_win then print('FUCKING IMPOSSIBLE'); return end
  migration_parent_info(right_win, left_win)
end

function M.neo_split()
  local bottom_win = vim.api.nvim_get_current_win()
  vim.cmd('split')
  local top_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd j')
  if bottom_win == top_win then print('FUCKING IMPOSSIBLE'); return end
  migration_parent_info(bottom_win, top_win)
end
---------------------------------------------------------------------------------------------------
local function pin_to_80_percent_height()
  local scrolloff = 7
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
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

local function is_a_parent(win_test)
  for k, v in pairs(M.parent_info_from_win) do
    if (win_test == v[1]) then
      return {true, k}
    end
  end
  return {false}
end

local function is_a_child(tab_test)
  for k, v in pairs(M.parent_info_from_win) do
    if (tab_test == v[4]) then
      return {true, k}
    end
  end
  return {false}
end

function M.maximize_current_split()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  -- if the current win is parent then follow the link.
  if is_a_parent(cur_win)[1] then
    vim.api.nvim_set_current_win(is_a_parent(cur_win)[2])
    return
  end
  -- if the current tab is a child, close it no matter how many splits there are
  local cur_tab = vim.api.nvim_get_current_tabpage()
  if is_a_child(cur_tab)[1] then
    -- as a scratch pad: the other splits discarded
    local buf_closed = vim.api.nvim_get_current_buf()
    local cur_closed = vim.api.nvim_win_get_cursor(0)
    vim.cmd('tabc')
    -- restore to the state one wants to zoom-in
    local win_p, buf_p, cur_p = unpack(M.parent_info_from_win[is_a_child(cur_tab)[2]])
    -- TODO: didn't consider the case that the win_p doesn't exist anymore
    vim.api.nvim_set_current_win(win_p)
    vim.api.nvim_set_current_buf(buf_p)

    -- update cursor-pos **only** on buffer-match.
    if (buf_p == buf_closed) then
      vim.api.nvim_win_set_cursor(win_p, cur_closed)
    else
      vim.api.nvim_win_set_cursor(win_p, cur_p)
    end
    pin_to_80_percent_height()
    -- un-register current cur_win
    M.parent_info_from_win[cur_win] = nil
    -- TODO: should change statusline color here
    return
  end

  -- might have chance to zoom-in
  vim.api.nvim_set_var('non_float_total', 0)
  vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")
  vim.api.nvim_set_current_win(cur_win)
  if (vim.api.nvim_get_var('non_float_total') == 1) then
    return
  end
  -- register current state into parent_info_from_buf
  vim.cmd('tab split')
  local old_win = cur_win
  M.parent_info_from_win[vim.api.nvim_get_current_win()] = {
    old_win,
    vim.api.nvim_get_current_buf(),
    vim.api.nvim_win_get_cursor(0),
    vim.api.nvim_get_current_tabpage()
  }
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
