local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}
local NORMAL_EXIT = false
local WIN_ON_ENTER = nil
local FLOAT_WIN = nil

---------------------------------------------------------------------------------------------------

local function _in_table(table, t)
  for _, v in ipairs(table) do
    if v == t then
      return true
    end
  end
  return false
end

local function _add_table(table, ts)
  for _, v in ipairs(ts) do
    table[#table + 1] = v
  end
end

---------------------------------------------------------------------------------------------------
function M.setup(opt)
  if opt == nil then
    opt = {}
  end
  
  M.width_ratio = opt.width_ratio ~= nil and opt.width_ratio or 0.66
  M.height_ratio = opt.height_ratio ~= nil and opt.height_ratio or 0.9
  M.top_ratio = opt.top_ratio ~= nil and opt.top_ratio or 0.03
  M.left_ratio = opt.left_ratio ~= nil and opt.left_ratio or 0.32
  M.border = opt.border ~= nil and opt.border or 'double'
  M.filetype_exclude = opt.filetype_exclude ~= nil and
    _add_table(opt.filetype_exclude, { 'fzf', 'qf', 'dashboard' }) or { 'fzf', 'qf', 'dashboard' }
end

function M.neo_zoom()
  if (
      (vim.bo.buftype == 'terminal'
        and vim.api.nvim_win_get_config(0).relative == '')
      or _in_table(M.filetype_exclude, vim.bo.filetype)
    ) then
    return
  end
  local uis = vim.api.nvim_list_uis()[1]
  local editor_width = uis.width
  local editor_height = uis.height
  local float_top = math.ceil(editor_height * M.top_ratio + 0.5)
  local float_left = math.ceil(editor_width * M.left_ratio + 0.5)
  local cur_cur = vim.api.nvim_win_get_cursor(0)
  local cur_buf = vim.api.nvim_win_get_buf(0)

  if vim.api.nvim_win_get_config(0).relative ~= '' then
    NORMAL_EXIT = true
    vim.cmd('q')
    vim.api.nvim_set_current_win(WIN_ON_ENTER)
    if cur_buf == vim.api.nvim_win_get_buf(WIN_ON_ENTER) then
      vim.api.nvim_win_set_cursor(0, cur_cur)
    end
    WIN_ON_ENTER = nil
    FLOAT_WIN = nil
    NORMAL_EXIT = false
    return
  end

  WIN_ON_ENTER = vim.api.nvim_get_current_win()

  FLOAT_WIN = vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    row = float_top,
    col = float_left,
    height = math.ceil(editor_height * M.height_ratio + 0.5),
    width = math.ceil(editor_width * M.width_ratio + 0.5),
    focusable = true,
    zindex = 5,
    border = M.border,
  })
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
  vim.api.nvim_create_autocmd({ 'WinEnter' }, {
    pattern = '*',
    callback = function ()
      if -- jump out of zoom-in win
        vim.api.nvim_win_get_config(0).relative == '' -- not on zoom-in window
        and (FLOAT_WIN ~= nil and not NORMAL_EXIT) -- zoom-in win exists
        then
        vim.api.nvim_win_set_buf(WIN_ON_ENTER, vim.api.nvim_win_get_buf(FLOAT_WIN))
        vim.api.nvim_set_current_win(FLOAT_WIN)
        vim.cmd('q')
        FLOAT_WIN = nil
        WIN_ON_ENTER = nil
        NORMAL_EXIT = false
      end
    end
  })
end

setup_vim_commands()

return M
