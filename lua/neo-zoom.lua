local value_in_table = require('myutils').value_in_table
local table_add_values = require('myutils').table_add_values
local add_scrolloff = require('myutils').add_scrolloff
local M = {}
---------------------------------------------------------------------------------------------------
local width_ratio = 0.66
local height_ratio = 0.9
local top_ratio = 0.03
local left_ratio = 0.32
local border = 'double'
local exclude = { 'fzf', 'qf' }
local _default_scrolloff = 13
-- mappings: zoom_win -> original_win
local zoom_book = {}


---------------------------------------------------------------------------------------------------
function M.setup(opt)
  if not opt then opt = {} end

  M.width_ratio = opt.width_ratio or width_ratio
  M.height_ratio = opt.height_ratio or height_ratio
  M.top_ratio = opt.top_ratio or top_ratio
  M.left_ratio = opt.left_ratio or left_ratio
  M.border = opt.border or border
  M.exclude = table_add_values(exclude, type(opt.exclude_filetypes) == 'table' or {})
  M.exclude = table_add_values(M.exclude, type(opt.exclude_buftypes) == 'table' or {})

  zoom_book = {}
end


function M.did_zoom(tabpage)
  if not tabpage then tabpage = 0 end
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for z, w in ipairs(zoom_book) do
    if vim.api.nvim_win_get_tabpage(w) == cur_tab then
      return true, z
    end
  end

  return false
end


function M.neo_zoom(scrolloff)
  if -- did zoom then should zoom out anyway regardless it's blabla type.
    M.did_zoom() then
    local z = M.did_zoom()[2]

    -- try close the floating window.
    if vim.api.nvim_win_is_valid(z) then
      vim.api.nvim_set_current_win(z)
      vim.cmd('q')

      -- try zoom out.
      if vim.api.nvim_win_is_valid(zoom_book[z]) then
        vim.api.nvim_set_current_win(zoom_book[z])
      end
    end

    zoom_book[z] = nil
    return
  end

  -- deal with case: did not zoom.

  if value_in_table(M.exclude, vim.bo.filetype)
    or value_in_table(M.exclude, vim.bo.buftype) then
    return
  end


  -- can zoom.
  if not scrolloff then
    scrolloff = _default_scrolloff
  end
  local buf_on_zoom = vim.api.nvim_win_get_buf(0)
  local win_on_zoom = vim.api.nvim_get_current_win()
  local editor = vim.api.nvim_list_uis()[1]
  local float_top = math.ceil(editor.height * M.top_ratio + 0.5)
  local float_left = math.ceil(editor.width * M.left_ratio + 0.5)

  zoom_book[
    vim.api.nvim_open_win(0, true, {
      relative = 'editor',
      row = float_top,
      col = float_left,
      height = math.ceil(editor.height * M.height_ratio + 0.5),
      width = math.ceil(editor.width * M.width_ratio + 0.5),
      focusable = true,
      zindex = 5,
      border = M.border,
    })
  ] = win_on_zoom

  vim.api.nvim_set_current_buf(buf_on_zoom)
  add_scrolloff(scrolloff)
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
end

setup_vim_commands()


return M
