local M = {}


local function detect_colon_q()
  local WinClosed_not_by_NeoZoom = false
  local saved_view = nil
  local saved_buf = nil
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    group = 'NeoZoom.lua',
    callback = function ()
      if not require('neo-zoom').did_zoom()[1]
        or vim.api.nvim_get_current_win() ~= require('neo-zoom').did_zoom()[2]
      then
        WinClosed_not_by_NeoZoom = false
        return
      end
      WinClosed_not_by_NeoZoom = true
      saved_view = vim.fn.winsaveview()
      saved_buf = vim.api.nvim_get_current_buf()
    end
  })
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = 'NeoZoom.lua',
    callback = function ()
      if not WinClosed_not_by_NeoZoom then return end
      WinClosed_not_by_NeoZoom = false

      -- it's [No Name].
      if vim.api.nvim_buf_is_loaded(0)
        and vim.api.nvim_buf_get_option(0, 'buflisted')
        and vim.api.nvim_buf_get_name(0) == ''
        and vim.api.nvim_buf_get_option(0, 'buftype') == ''
        and vim.api.nvim_buf_get_option(0, 'filetype') == ''
      then
        if vim.api.nvim_buf_is_valid(saved_buf) then
          vim.api.nvim_set_current_buf(saved_buf)
          vim.fn.winrestview(saved_view)
        end
      end
    end
  })
end


function M.create_autocmds()
  detect_colon_q()
end


return M
