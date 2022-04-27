local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}

M.parent_info_from_win = {} -- use window to search parent info {win,buf,curs,tab}


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
---------------------------------------------------------------------------------------------------

function M.neo_zoom()
  if (vim.bo.buftype == 'nofile'
    or vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'qf') then
    return
  end
  local uis = vim.api.nvim_list_uis()[1]
  local editor_width = uis.width
  local editor_height = uis.height
  local float_top = math.ceil(editor_height * 0.03 - 0.5)
  local float_left = math.ceil(editor_width * 0.45 - 0.5)

  if vim.api.nvim_win_get_config(0).relative ~= '' then
    local cur_cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd('q')
    vim.api.nvim_win_set_cursor(0, cur_cur)
    pin_to_80_percent_height()
    return
  end

  vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    row = float_top,
    col = float_left,
    height = math.ceil(editor_height * 0.9 - 0.5),
    width = editor_width / 2,
    focusable = true,
    zindex = 5,
    border = 'double',
  })

  pin_to_80_percent_height()
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
end

setup_vim_commands()

return M
