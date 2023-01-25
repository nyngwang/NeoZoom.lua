local U = require('neo-zoom.myutils')
local M = {}
---------------------------------------------------------------------------------------------------
local width_ratio = 0.66
local height_ratio = 0.9
local top_ratio = 0.03
local left_ratio = 0.32
local border = 'double'
local scrolloff_on_enter = 13
local exclude = { 'lspinfo', 'mason', 'lazy', 'fzf' }
local zoom_book = {}


---------------------------------------------------------------------------------------------------
function M.setup(opt)
  if not opt then opt = {} end

  M.width_ratio = opt.width_ratio or width_ratio
  M.height_ratio = opt.height_ratio or height_ratio
  M.top_ratio = opt.top_ratio or top_ratio
  M.left_ratio = opt.left_ratio or left_ratio
  M.border = opt.border or border
  M.scrolloff_on_enter = opt.scrolloff_on_enter or scrolloff_on_enter
  M.exclude = U.table_add_values(exclude, type(opt.exclude_filetypes) == 'table' and opt.exclude_filetypes or {})
  M.exclude = U.table_add_values(M.exclude, type(opt.exclude_buftypes) == 'table' and opt.exclude_buftypes or {})

  -- mappings: zoom_win -> original_win
  zoom_book = {}
end


function M.did_zoom(tabpage)
  if not tabpage then tabpage = 0 end
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for z, w in pairs(zoom_book) do
    if vim.api.nvim_win_get_tabpage(w) == cur_tab then
      return true, z
    end
  end

  return false
end


function M.neo_zoom(opt)
  opt = vim.tbl_deep_extend('force', {}, M, opt or {})

  local did_zoom, z = M.did_zoom()
  if did_zoom then -- can always zoom-out regardless of its content.
    -- try close the floating window.
    if vim.api.nvim_win_is_valid(z) then
      vim.api.nvim_win_close(z, true)

      -- try zoom out.
      if vim.api.nvim_win_is_valid(zoom_book[z]) then
        vim.api.nvim_set_current_win(zoom_book[z])
      end
    end

    if z then zoom_book[z] = nil end
    return
  end

  -- deal with case: might zoom.

  if U.table_contains(opt.exclude, vim.bo.filetype)
    or U.table_contains(opt.exclude, vim.bo.buftype) then
    return
  end


  -- deal with case: should zoom.
  local buf_on_zoom = vim.api.nvim_win_get_buf(0)
  local win_on_zoom = vim.api.nvim_get_current_win()
  local editor = vim.api.nvim_list_uis()[1]
  local float_top = math.ceil(editor.height * opt.top_ratio + 0.5)
  local float_left = math.ceil(editor.width * opt.left_ratio + 0.5)

  zoom_book[
    vim.api.nvim_open_win(0, true, {
      relative = 'editor',
      row = float_top,
      col = float_left,
      height = math.ceil(editor.height * opt.height_ratio + 0.5),
      width = math.ceil(editor.width * opt.width_ratio + 0.5),
      focusable = true,
      zindex = 5,
      border = opt.border,
    })
  ] = win_on_zoom

  vim.api.nvim_set_current_buf(buf_on_zoom)
  U.add_scrolloff(opt.scrolloff_on_enter)
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
end
setup_vim_commands()


return M
