local M = {}


function M.fix_narrow_zoom_in_window()
  -- see issue #73.
  local offset_right = 5
  local rhs = vim.api.nvim_win_get_width(0) - vim.fn.wincol() - offset_right
  vim.cmd('normal! z' .. tostring(rhs) .. 'h')
end


return M
