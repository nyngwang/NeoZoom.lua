local U = require('neo-zoom.utils')
local A = require('neo-zoom.utils.autocmd')
local M = {}
vim.api.nvim_create_augroup('NeoZoom.lua', { clear = true })
M.key_neo_zoom_float_check = 'is_neo_zoom_float'
---------------------------------------------------------------------------------------------------
local _setup_is_called = false
local merged_config = {}
local merged_config_delegate = {}


local function build_merged_config()
  setmetatable(merged_config_delegate, {
    __index = function (_, ft)
      if type(merged_config[ft]) == 'table'
      then return merged_config[ft] end

      for _, preset in pairs(M.presets) do
        -- skip incomplete config.
        if type(preset) ~= 'table'
          or type(preset.filetypes) ~= 'table'
          or (type(preset.winopts) ~= 'table' and type(preset.callbacks) ~= 'table')
        then goto continue end

        for _, pattern_ft in pairs(preset.filetypes) do
          if type(pattern_ft) == 'string'
            and (ft == pattern_ft or string.match(ft, pattern_ft))
          then
            merged_config[ft] = vim.deepcopy(vim.tbl_deep_extend('force',
              { winopts = M.winopts }, preset))
            return merged_config[ft]
          end
        end
        ::continue::
      end
      -- fallback.
      merged_config[ft] = vim.deepcopy(vim.tbl_deep_extend('force',
        {}, { winopts = M.winopts, callbacks = {} }))
      return merged_config[ft]
    end
  })
end


local function update_internals()
  M.zoom_book = {} -- mappings: zoom_win -> original_win
  _setup_is_called = true
  build_merged_config()
end
---------------------------------------------------------------------------------------------------
function M.setup(opts)
  if not opts then opts = {} end

  M.winopts = opts.winopts or {
    offset = {
      -- top = 1,
      left = 0.5,
      width = 170,
      height = 0.85,
    },
    border = 'double',
  }
    if type(M.winopts) ~= 'table' then M.winopts = {} end
    if type(M.winopts.offset) ~= 'table' then M.winopts.offset = {} end
      if type(M.winopts.offset.width) ~= 'number' then M.winopts.offset.width = 170 end
      if type(M.winopts.offset.height) ~= 'number' then M.winopts.offset.height = 0.85 end
      -- center as default.
      if type(M.winopts.offset.top) ~= 'number' then M.winopts.offset.top = nil end
      if type(M.winopts.offset.left) ~= 'number' then M.winopts.offset.left = nil end
    if M.winopts.border == 'thicc' then M.winopts.border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' } end
    if type(M.winopts.border) ~= 'string' and type(M.winopts.border) ~= 'table' then
      M.winopts.border = 'double'
    end
  M.exclude_filetypes = U.table_add_values({ 'lspinfo', 'mason', 'lazy', 'fzf' },
    type(opts.exclude_filetypes) == 'table' and opts.exclude_filetypes or {})
  M.exclude_buftypes = U.table_add_values({},
    type(opts.exclude_buftypes) == 'table' and opts.exclude_buftypes or {})
  M.popup = opts.popup or { enabled = true, exclude_filetypes = {}, exclude_buftypes = {} }
    if type(M.popup) ~= 'table' then M.popup = {} end
    if type(M.popup.enabled) ~= 'boolean' then M.popup.enabled = true end
    if type(M.popup.exclude_filetypes) ~= 'table' then M.popup.exclude_filetypes = {} end
    if type(M.popup.exclude_buftypes) ~= 'table' then M.popup.exclude_buftypes = {} end
  M.presets = opts.presets or {}
    if type(M.presets) ~= 'table' then M.presets = {} end
  M.callbacks = opts.callbacks or {}
    if type(M.callbacks) ~= 'table' then M.callbacks = {} end
    U.table_add_values(M.callbacks, require('neo-zoom.presets.callbacks'))


  update_internals()
  A.create_autocmds()
end


function M.did_zoom(tabpage, bufpath)
  if not tabpage then tabpage = 0 end
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for z, e in pairs(M.zoom_book) do
    if
      vim.api.nvim_win_is_valid(z)
      and vim.api.nvim_win_get_tabpage(z) == cur_tab
      and (
        -- match all buffer.
        (not bufpath and vim.api.nvim_win_is_valid(e))
        or
        -- match the specified buffer.
        (bufpath and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(z)) == vim.fn.fnamemodify(bufpath, ':p'))
      )
    then
      -- only returns valid z.
      return { true, z }
    end
  end

  return { false, nil }
end


function M.is_neo_zoom_float()
  local ok, is_neo_zoom_float = pcall(vim.api.nvim_win_get_var, 0, M.key_neo_zoom_float_check)
  return ok and is_neo_zoom_float
end


function M.neo_zoom(opts)
  if not _setup_is_called then
    error('NeoZoom.lua: Plugin has NOT been initialized. Please call `require("neo-zoom").setup({...})` first!')
  end
  -- always zoom-out regardless the type of its content.
  if -- it's headless mode.
    (opts and M.did_zoom(0, opts.bufpath)[1])
    or -- it's general mode.
    (not opts and M.did_zoom()[1])
  then
    local win_zoom = M.did_zoom(0, opts and opts.bufpath)[2]

    -- phrase1: go back to the zoom win first.
    if vim.api.nvim_get_current_win() ~= win_zoom then
      vim.api.nvim_set_current_win(win_zoom)
      return
    end

    -- phrase2: close the zoom win.

    -- close the zoom win immediately so that cur_win == zoom_win  on `WinClosed`.
    local buf_z = vim.api.nvim_win_get_buf(win_zoom)
    local view_z = vim.fn.winsaveview()
    vim.api.nvim_win_close(win_zoom, true)

    if M.zoom_book[win_zoom] and vim.api.nvim_win_is_valid(M.zoom_book[win_zoom]) then
      vim.api.nvim_set_current_win(M.zoom_book[win_zoom])
      vim.api.nvim_set_current_buf(buf_z)
      vim.fn.winrestview(view_z)
    end

    M.zoom_book[win_zoom or 0] = nil
    return
  end

  if not opts.bufpath then
    -- deal with case: might zoom.
    if U.table_contains(M.exclude_filetypes, vim.bo.filetype)
      or U.table_contains(M.exclude_buftypes, vim.bo.buftype) then
      return
    end
  end

  -- deal with case: should zoom.
  local view = vim.fn.winsaveview()
  local buf_on_zoom = vim.api.nvim_win_get_buf(0)
  local win_on_zoom = vim.api.nvim_get_current_win()
  local editor = vim.api.nvim_list_uis()[1]
  local winopts = opts.winopts or merged_config_delegate[vim.bo.filetype].winopts
  local offset = winopts.offset

  local win_zoom = vim.api.nvim_open_win(0, true, {
    -- fixed.
    relative = 'editor',
    focusable = true,
    zindex = 5,
    -- variables.
    ---- center the floating window by default.
    row = U.ratio_to_integer(U.with_fallback(offset.top, U.get_side_ratio(offset.height, editor.height)), editor.height),
    col = 1 + U.ratio_to_integer(U.with_fallback(offset.left, U.get_side_ratio(offset.width, editor.width)), editor.width),
    ---- `1` has special meaning for `height`, `width`.
    height = U.ratio_to_integer(offset.height, editor.height, true),
    width = U.ratio_to_integer(offset.width, editor.width, true),
    border = winopts.border or { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
  })
  if opts.bufpath then
    M.zoom_book[win_zoom] = -1
  else
    M.zoom_book[win_zoom] = win_on_zoom
  end

  vim.api.nvim_win_set_var(win_zoom, M.key_neo_zoom_float_check, true)
  if opts.bufpath then
    vim.cmd('e ' .. opts.bufpath)
  else
    vim.api.nvim_set_current_buf(buf_on_zoom)
    vim.fn.winrestview(view)
  end

  U.run_callbacks(M.callbacks) -- callbacks for all cases.
  U.run_callbacks(merged_config_delegate[vim.bo.filetype].callbacks) -- callbacks for specific filetypes.

  if not opts.bufpath
    and M.popup.enabled
    and vim.api.nvim_win_is_valid(win_on_zoom)
    and not U.table_contains(M.popup.exclude_filetypes, vim.bo.filetype)
    and not U.table_contains(M.popup.exclude_buftypes, vim.bo.buftype)
  then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bh = 'delete'
    vim.api.nvim_win_set_buf(win_on_zoom, buf)
  end
end


local function setup_vim_commands()
  vim.api.nvim_create_user_command('NeoZoomToggle', M.neo_zoom, {})
end
setup_vim_commands()


return M
