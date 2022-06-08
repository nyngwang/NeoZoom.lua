local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}
local WIN_ON_ENTER = nil


local function pin_to_80_percent_height()
  local scrolloff = 13
  local cur_line = vim.fn.line('.')
  vim.cmd("normal! zt")
  if (cur_line > scrolloff) then
    vim.cmd("normal! " .. scrolloff .. "k" .. scrolloff .. "j")
  else
    vim.cmd('normal!' .. (cur_line-1) .. 'k' .. (cur_line-1) .. 'j')
  end
end
---------------------------------------------------------------------------------------------------
function M.setup(opt)
  M.width_ratio = opt.width_ratio ~= nil and opt.width_ratio or 0.66
  M.height_ratio = opt.height_ratio ~= nil and opt.height_ratio or 0.9
  M.top_ratio = opt.top_ratio ~= nil and opt.top_ratio or 0.03
  M.left_ratio = opt.left_ratio ~= nil and opt.left_ratio or 0.32
  M.border = opt.border ~= nil and opt.border or 'double'
end

function M.neo_zoom()
  if (
    vim.bo.buftype == 'nofile'
    or vim.bo.filetype == 'fzf' -- for fzf-lua
    or vim.bo.filetype == 'qf' -- for NeoWell
    or (vim.bo.buftype == 'terminal'
      and vim.api.nvim_win_get_config(0).relative == '')
  ) then
    return
  end
  local uis = vim.api.nvim_list_uis()[1]
  local editor_width = uis.width
  local editor_height = uis.height
  local float_top = math.ceil(editor_height * M.top_ratio + 0.5)
  local float_left = math.ceil(editor_width * M.left_ratio + 0.5)

  if vim.api.nvim_win_get_config(0).relative ~= '' then
    local float_cur = vim.api.nvim_win_get_cursor(0)
    local float_buf = vim.api.nvim_win_get_buf(0)
    vim.cmd('q')
    vim.api.nvim_set_current_win(WIN_ON_ENTER)
    if float_buf == vim.api.nvim_win_get_buf(WIN_ON_ENTER) then
      vim.api.nvim_win_set_cursor(0, float_cur)
    end
    return
  end

  WIN_ON_ENTER = vim.api.nvim_get_current_win()

  vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    row = float_top,
    col = float_left,
    height = math.ceil(editor_height * M.height_ratio + 0.5),
    width = math.ceil(editor_width * M.width_ratio + 0.5),
    focusable = true,
    zindex = 5,
    border = M.border,
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
