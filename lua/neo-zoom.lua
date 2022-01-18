local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}

M.parent_info_from_win = {} -- use window to search parent info {win,buf,curs,tab}

local function consume(win)
  local data = M.parent_info_from_win[win]
  -- assume data exist on object free
  M.parent_info_from_win[win] = nil
  return unpack(data)
end

local function is_a_parent(win_test)
  for k, v in pairs(M.parent_info_from_win) do
    if (win_test == v[1]) then
      return {true, k}
    end
  end
  return {false}
end

local function is_a_child(win_test)
  return M.parent_info_from_win[win_test] ~= nil
end

local function clone_parent_info_to(from_win, to_win)
  if M.parent_info_from_win[from_win] == nil then -- no need to clone
    return
  end
  M.parent_info_from_win[to_win] = {
    M.parent_info_from_win[from_win][1],
    M.parent_info_from_win[from_win][2],
    M.parent_info_from_win[from_win][3],
    M.parent_info_from_win[from_win][4],
  }
end

function M.neo_vsplit()
  local right_win = vim.api.nvim_get_current_win()
  vim.cmd('vsplit')
  local left_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd l')
  if right_win == left_win then print('FUCKING IMPOSSIBLE'); return end
  clone_parent_info_to(right_win, left_win)
end

function M.neo_split()
  local bottom_win = vim.api.nvim_get_current_win()
  vim.cmd('split')
  local top_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd j')
  if bottom_win == top_win then print('FUCKING IMPOSSIBLE'); return end
  clone_parent_info_to(bottom_win, top_win)
end

local function close_tab_properly()
  if (vim.fn.tabpagenr('$') ~= vim.api.nvim_tabpage_get_number(0)) then
    vim.cmd('tabc')
    vim.cmd('tabp')
  else
    vim.cmd('tabc')
  end
end

local function pin_to_80_percent_height()
  local scrolloff = 7
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
  end
end

local function count_and_keep_current_win(cur_win)
  vim.api.nvim_set_var('non_float_total', 0)
  vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")
  vim.api.nvim_set_current_win(cur_win)
end
---------------------------------------------------------------------------------------------------
function M.maximize_current_split()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  -- if the current win is parent OR not parent still fuck that create a new tab for it
  -- final note: on (1)without NeoNoName, and if...istheonlysplit case, should un-register win

  if is_a_child(cur_win) then -- should close the current win and do some restore
    local win_p, buf_p, cur_p, tab_p = consume(cur_win)
    local buf_closed = vim.api.nvim_get_current_buf()
    local cur_closed = vim.api.nvim_win_get_cursor(0)

    -- TODO: detect NeoNoName here
    vim.cmd('wincmd q')

    -- TODO: still not consider the case that the win_p doesn't exist anymore
    -- restore info
    vim.api.nvim_set_current_win(win_p)
    vim.api.nvim_set_current_buf(buf_closed)
    vim.api.nvim_win_set_cursor(win_p, cur_closed)

    -- TODO: should disable the zoom-in statusline color here
  else -- if the current win is not a chlid
    vim.cmd('tab split')
    local old_win = cur_win
    cur_win = vim.api.nvim_get_current_win()
    M.parent_info_from_win[cur_win] = {
      old_win,
      vim.api.nvim_get_current_buf(),
      vim.api.nvim_win_get_cursor(0),
      vim.api.nvim_get_current_tabpage()
    }
  end
  pin_to_80_percent_height()
  -- TODO: should enable the zoom-in statusline color here
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.maximize_current_split()
    command! NeoVSplit lua require'neo-zoom'.neo_vsplit()
    command! NeoSplit lua require'neo-zoom'.neo_split()
  ]]
end

setup_vim_commands()

return M
