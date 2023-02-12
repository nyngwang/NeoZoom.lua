local U = require('neo-zoom.utils')
local M = {}
vim.api.nvim_create_augroup('NeoZoom.lua', { clear = true })
---------------------------------------------------------------------------------------------------
M._presets_delegate = {}
local _in_execution = false
local _exit_view = nil
local zoom_book = {}


local function create_autocmds()
  vim.api.nvim_create_autocmd({ 'WinLeave', }, {
    group = 'NeoZoom.lua',
    pattern = '*',
    callback = function ()
      if
        not M.did_zoom()[1]
        or vim.api.nvim_get_current_win() ~= M.did_zoom()[2]
      then return end
      _exit_view = vim.fn.winsaveview()
    end
  })
  vim.api.nvim_create_autocmd({ 'WinEnter', }, {
    group = 'NeoZoom.lua',
    pattern = '*',
    callback = function ()
      if
        _in_execution
        or not M.disable_by_cursor
        or not M.did_zoom()[1]
        or vim.api.nvim_get_current_win() == M.did_zoom()[2]
        or vim.api.nvim_win_get_config(0).relative ~= ''
      then return end
      M.neo_zoom()
    end
  })
end
---------------------------------------------------------------------------------------------------
function M.setup(opts)
  if not opts then opts = {} end

  M.top_ratio = opts.top_ratio or 0.03
  if opts.left_ratio == "nil" then
    M.left_ratio = nil
  else
    M.left_ratio = opts.left_ratio or 0.32
  end
  M.height_ratio = opts.height_ratio or 0.9
  M.width_ratio = opts.width_ratio or 0.66
  M.border = opts.border or 'double'
  M.width = opts.width or nil

  M.disable_by_cursor = opts.disable_by_cursor
    if M.disable_by_cursor == nil then M.disable_by_cursor = true end
  M.exclude = U.table_add_values({ 'lspinfo', 'mason', 'lazy', 'fzf' }, type(opts.exclude_filetypes) == 'table' and opts.exclude_filetypes or {})
  M.exclude = U.table_add_values(M.exclude, type(opts.exclude_buftypes) == 'table' and opts.exclude_buftypes or {})
  M.popup = opts.popup or { enabled = true, exclude_filetypes = {}, exclude_buftypes = {} }
    if type(M.popup) ~= 'table' then M.popup = {} end
    if type(M.popup.enabled) ~= 'boolean' then M.popup.enabled = true end
    if type(M.popup.exclude_filetypes) ~= 'table' then M.popup.exclude_filetypes = {} end
    if type(M.popup.exclude_buftypes) ~= 'table' then M.popup.exclude_buftypes = {} end
  M.presets = opts.presets or {}
    -- TODO: need to refactor.
    if type(M.presets) ~= 'table' then M.presets = {} end
    setmetatable(M._presets_delegate, {
      __index = function (_, ft)
        for _, preset in pairs(M.presets) do
          if type(preset) ~= 'table'
            or type(preset.config) ~= 'table'
            or type(preset.filetypes) ~= 'table'
          then goto continue end
          for _, _ft in pairs(preset.filetypes) do
            if type(_ft) == 'string'
              and ft == _ft or string.match(ft, _ft) then
              preset.config.top_ratio = preset.config.top_ratio or M.top_ratio
              preset.config.left_ratio = preset.config.left_ratio or M.left_ratio
              preset.config.height_ratio = preset.config.height_ratio or M.height_ratio
              preset.config.width_ratio = preset.config.width_ratio or M.width_ratio
              preset.config.border = preset.config.border or M.border
              return preset
            end
          end
          ::continue::
        end
        -- use default
        return {
          config = {
            top_ratio = M.top_ratio,
            left_ratio = M.left_ratio,
            height_ratio = M.height_ratio,
            width_ratio = M.width_ratio,
            width = M.width,
            border = M.border,
          }
        }
      end
    })
  M.callbacks = opts.callbacks or {}

  zoom_book = {} -- mappings: zoom_win -> original_win
  create_autocmds()
end


function M.did_zoom(tabpage)
  if not tabpage then tabpage = 0 end
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for z, _ in pairs(zoom_book) do
    if
      vim.api.nvim_win_is_valid(z)
      and vim.api.nvim_win_get_tabpage(z) == cur_tab
    then
      return { true, z }
    end
  end

  return { false, nil }
end


function M.neo_zoom(opt)
  _in_execution = true
  opt = vim.tbl_deep_extend('force', {}, M, opt or {})

  -- always zoom-out regardless the type of its content.
  if M.did_zoom()[1] then
    local z = M.did_zoom()[2]

    -- try go back first.
    if vim.api.nvim_win_is_valid(zoom_book[z]) then
      vim.api.nvim_win_set_buf(zoom_book[z], vim.api.nvim_win_get_buf(z))
      vim.api.nvim_set_current_win(zoom_book[z])
      vim.fn.winrestview(_exit_view)
    end

    vim.api.nvim_win_close(z, true)
    zoom_book[z] = nil
    _in_execution = false
    return
  end

  -- deal with case: might zoom.
  if U.table_contains(M.exclude, vim.bo.filetype)
    or U.table_contains(M.exclude, vim.bo.buftype) then
    return
  end

  -- deal with case: should zoom.
  local view = vim.fn.winsaveview()
  local buf_on_zoom = vim.api.nvim_win_get_buf(0)
  local win_on_zoom = vim.api.nvim_get_current_win()
  local editor = vim.api.nvim_list_uis()[1]
  local preset = M._presets_delegate[vim.bo.filetype]
  local float_top = math.ceil(editor.height * preset.config.top_ratio + 0.5)
  local float_height = math.ceil(editor.height * preset.config.height_ratio + 0.5)
  -- take fixed width first. If not provided, we will use the ratio
  local float_width = preset.config.width
  if float_width == nil then
    float_width = math.ceil(editor.width * preset.config.width_ratio + 0.5)
  end
  -- center the window if float_left is set to nil
  local float_left = math.ceil((editor.width - float_width) / 2)
  if preset.config.left_ratio ~= nil then
    float_left = math.ceil(editor.width * preset.config.left_ratio + 0.5)
  end
  local border = preset.config.border

  zoom_book[
    vim.api.nvim_open_win(0, true, {
      -- fixed.
      relative = 'editor',
      focusable = true,
      zindex = 5,
      -- variables.
      row = float_top,
      col = float_left,
      height = float_height,
      width = float_width,
      border = border,
    })
  ] = win_on_zoom
  vim.api.nvim_set_current_buf(buf_on_zoom)

  U.run_callbacks(M.callbacks) -- callbacks for all cases.
  U.run_callbacks(preset.callbacks) -- callbacks for specific filetypes.

  if M.popup.enabled
    and not U.table_contains(M.popup.exclude_filetypes, vim.bo.filetype)
    and not U.table_contains(M.popup.exclude_buftypes, vim.bo.buftype)
  then
    vim.api.nvim_set_current_win(win_on_zoom)
    vim.cmd('enew')
    vim.bo.bufhidden = 'delete'
    vim.cmd('wincmd p')
  end

  vim.fn.winrestview(view)
  _in_execution = false
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoZoomToggle lua require'neo-zoom'.neo_zoom()
  ]]
end
setup_vim_commands()


return M
