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
  local MAX = 999
  local win_closest = nil
  local tab_n_of_closest_win = MAX
  for k, v in pairs(M.parent_info_from_win) do
    if (win_test == v[1]) then
      local tab_n = vim.api.nvim_tabpage_get_number(v[4])
      if tab_n_of_closest_win > tab_n then
        tab_n_of_closest_win = tab_n
        win_closest = k
      end
    end
  end
  if tab_n_of_closest_win == MAX then return {false}
  else return {true, win_closest} end
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

local function pin_to_80_percent_height()
  local scrolloff = 7
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
  end
end
---------------------------------------------------------------------------------------------------
function M.neo_zoom()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  local cur_tab = vim.api.nvim_get_current_tabpage()

  if is_a_child(cur_win) then -- should close the current win and do some restore
    local win_p = consume(cur_win)
    local buf_closed = vim.api.nvim_get_current_buf()
    local cur_closed = vim.api.nvim_win_get_cursor(0)

    -- TODO: can use NeoNoName to "close" split
    vim.cmd('wincmd q')

    if not vim.api.nvim_win_is_valid(win_p) then -- restore your mom
      return
    end
    -- restore info
    vim.api.nvim_set_current_win(win_p)
    vim.api.nvim_set_current_buf(buf_closed)
    vim.api.nvim_win_set_cursor(win_p, cur_closed)

    -- TODO: should disable the zoom-in statusline color here
  elseif is_a_parent(cur_win)[1] then -- go the the first child on the closest following tabs.
    local child_win_closest = is_a_parent(cur_win)[2]
    -- restore info
    local _, buf_c, cur_c = unpack(M.parent_info_from_win[child_win_closest])
    vim.api.nvim_set_current_win(child_win_closest)
    vim.api.nvim_set_current_buf(buf_c)
    vim.api.nvim_win_set_cursor(child_win_closest, cur_c)
  else -- if the current win is not a 
    vim.cmd('tab split')
    local old_win = cur_win
    cur_win = vim.api.nvim_get_current_win()
    M.parent_info_from_win[cur_win] = {
      old_win,
      vim.api.nvim_get_current_buf(),
      vim.api.nvim_win_get_cursor(0),
      vim.api.nvim_get_current_tabpage()
    }
    -- TODO: should enable the zoom-in statusline color here
  end
  pin_to_80_percent_height()
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
    command! NeoVSplit lua require'neo-zoom'.neo_vsplit()
    command! NeoSplit lua require'neo-zoom'.neo_split()
  ]]
end

setup_vim_commands()

return M
