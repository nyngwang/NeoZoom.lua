local M = {}


local function detect_colon_q()
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    group = 'NeoZoom.lua',
    callback = function (args)
      if -- it's not closing the current win.
        vim.api.nvim_get_current_buf() ~= args.buf
        or not require('neo-zoom').did_zoom()[1]
        or vim.api.nvim_get_current_win() ~= require('neo-zoom').did_zoom()[2]
      then return end

      local view = vim.fn.winsaveview()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_set_current_win(require('neo-zoom').zoom_book[vim.api.nvim_get_current_win()])
      vim.api.nvim_set_current_buf(buf)
      vim.fn.winrestview(view)
      require('neo-zoom').zoom_book[vim.api.nvim_get_current_win()] = nil
    end
  })
end


function M.create_autocmds()
  detect_colon_q()
end


return M
