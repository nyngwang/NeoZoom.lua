local M = {}


local function detect_colon_q()
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    group = 'NeoZoom.lua',
    callback = function (args)
      if -- it's not closing the current win.
        vim.api.nvim_get_current_buf() ~= args.buf
        or not require('neo-zoom').is_neo_zoom_float()
      then return end

      local view = vim.fn.winsaveview()
      local buf_zoom = vim.api.nvim_get_current_buf()
      local win_enter = require('neo-zoom').zoom_book[vim.api.nvim_get_current_win()]
      vim.api.nvim_exec_autocmds('User', {
        pattern = 'NeoZoomClosed',
        data = {
          original_win = win_enter,
        }
      })

      require('neo-zoom').zoom_book[vim.api.nvim_get_current_win()] = nil
      -- this will be triggered right after `WinClosed`.
      vim.api.nvim_create_autocmd({ 'WinEnter' }, {
        group = 'NeoZoom.lua',
        once = true,
        callback = function ()
          if win_enter and vim.api.nvim_win_is_valid(win_enter) then
            vim.api.nvim_set_current_win(win_enter)
            vim.api.nvim_set_current_buf(buf_zoom)
            vim.fn.winrestview(view)
          end
        end
      })
    end
  })
end


function M.create_autocmds()
  detect_colon_q()
end


return M
