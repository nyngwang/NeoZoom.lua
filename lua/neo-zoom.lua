local M = {}
M.WIN_ON_ENTER = nil
M.FLOAT_WIN = nil

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

local function pin_to_scrolloff()
  local scrolloff = M.scrolloff_on_zoom
  local cur_line = vim.fn.line('.')
  vim.cmd('normal! zt')
  if (cur_line > scrolloff) then
    vim.cmd('normal! ' .. scrolloff .. 'k' .. scrolloff .. 'j')
  else
    vim.cmd('normal! ' .. (cur_line-1) .. 'k' .. (cur_line-1) .. 'j')
  end
end

---------------------------------------------------------------------------------------------------
function M.setup(opt)
  if opt == nil then opt = {} end
  M.width_ratio = opt.width_ratio ~= nil and opt.width_ratio or 0.66
  M.height_ratio = opt.height_ratio ~= nil and opt.height_ratio or 0.9
  M.top_ratio = opt.top_ratio ~= nil and opt.top_ratio or 0.03
  M.left_ratio = opt.left_ratio ~= nil and opt.left_ratio or 0.32
  M.border = opt.border ~= nil and opt.border or 'double'
  M.exclude_filetype = opt.exclude_filetype ~= nil and
    _add_table(opt.exclude_filetype, { 'fzf', 'qf', 'dashboard' }) or { 'fzf', 'qf', 'dashboard' }
  M.scrolloff_on_zoom = opt.scrolloff_on_zoom ~= nil and opt.scrolloff_on_zoom or 13
end

function M.neo_zoom()
  if (
      (vim.bo.buftype == 'terminal'
        and vim.api.nvim_win_get_config(0).relative == '')
      or _in_table(M.exclude_filetype, vim.bo.filetype)
    ) then
    return
  end
  local uis = vim.api.nvim_list_uis()[1]
  local editor_width = uis.width
  local editor_height = uis.height
  local float_top = math.ceil(editor_height * M.top_ratio + 0.5)
  local float_left = math.ceil(editor_width * M.left_ratio + 0.5)
  local cur_buf = vim.api.nvim_win_get_buf(0)

  if M.FLOAT_WIN ~= nil
    and vim.api.nvim_win_is_valid(M.FLOAT_WIN) then
    vim.api.nvim_set_current_win(M.FLOAT_WIN)
    local cur_cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd('q')
    vim.api.nvim_set_current_win(M.WIN_ON_ENTER)
    vim.api.nvim_win_set_cursor(0, cur_cur)
    
    M.WIN_ON_ENTER = nil
    M.FLOAT_WIN = nil
    return
  end

  M.WIN_ON_ENTER = vim.api.nvim_get_current_win()

  M.FLOAT_WIN = vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    row = float_top,
    col = float_left,
    height = math.ceil(editor_height * M.height_ratio + 0.5),
    width = math.ceil(editor_width * M.width_ratio + 0.5),
    focusable = true,
    zindex = 5,
    border = M.border,
  })

  vim.api.nvim_set_current_buf(cur_buf)

  pin_to_scrolloff()
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
end

setup_vim_commands()

return M
