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
    if v[1] == win_test then
      return true end
  end
  return false
end

local function is_a_child(win_test)
  return M.parent_info_from_win[win_test] ~= nil
end

local function prefer_non_noname_buf(win_p)
  for k, v in pairs(M.parent_info_from_win) do
    if v[1] == win_p
      and #vim.api.nvim_buf_get_name(v[2]) > 0 -- prefer non-`[No Name]`
      then return k end
  end
  -- all children `[No Name]`, then go for it.
  for k, v in pairs(M.parent_info_from_win) do
    if v[1] == win_p
      then return k end
  end
end

local function clone_parent_info_to(from_win, to_win)
  if M.parent_info_from_win[from_win] == nil then -- no need to clone
    return
  end
  M.parent_info_from_win[to_win] = M.parent_info_from_win[from_win]
end

local function pin_to_80_percent_height()
  local scrolloff = 7
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
  else
    vim.cmd('normal!' .. (cur_line-1) .. 'k' .. (cur_line-1) .. 'j')
  end
end

local function close_win_and_floats(cur_win)
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative == 'win' and win_config.win == cur_win then -- close these floats first.
      vim.api.nvim_win_close(win, false)
    end
  end
  vim.cmd('wincmd q')
end
---------------------------------------------------------------------------------------------------
function M.neo_zoom()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local cur_tab = vim.api.nvim_get_current_tabpage()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(0)
  local cur_cur = vim.api.nvim_win_get_cursor(0)

  for k, v in pairs(M.parent_info_from_win) do
    if not vim.api.nvim_win_is_valid(v[1]) then -- **parent repear**
      consume(k) end
  end
  for k, v in pairs(M.parent_info_from_win) do
    if not vim.api.nvim_win_is_valid(k) then -- **children repear**
      consume(k) end
  end

  if is_a_child(cur_win) then -- should close the current win and do some restore
    local win_p = M.parent_info_from_win[cur_win][1]

    -- close_win_and_floats(cur_win)

    vim.api.nvim_set_current_win(win_p)
    if vim.api.nvim_win_get_buf(0) == cur_buf then -- restore cursor
      vim.api.nvim_win_set_cursor(0, cur_cur)
    end

    -- TODO: should disable the zoom-in statusline color here
  elseif is_a_parent(cur_win) then -- goto any child on the closest following tabs.
    local win_c = prefer_non_noname_buf(cur_win)
    vim.api.nvim_set_current_win(win_c)
    if vim.api.nvim_win_get_buf(0) == cur_buf then -- restore cursor
      vim.api.nvim_win_set_cursor(0, cur_cur)
    end
  else -- if the current win is neither parent nor child.
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

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
    command! NeoVSplit lua require'neo-zoom'.neo_vsplit()
    command! NeoSplit lua require'neo-zoom'.neo_split()
  ]]
end

setup_vim_commands()

return M
