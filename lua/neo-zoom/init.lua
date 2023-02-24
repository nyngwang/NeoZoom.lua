local U = require('neo-zoom.utils')
local A = require('neo-zoom.utils.autocmd')
local M = {}
vim.api.nvim_create_augroup('NeoZoom.lua', { clear = true })
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
          or type(preset.winopts) ~= 'table'
        then goto continue end

        for _, pattern_ft in pairs(preset.filetypes) do
          if type(pattern_ft) == 'string'
            and ft == pattern_ft or string.match(ft, pattern_ft)
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


  update_internals()
  A.create_autocmds()
end


function M.did_zoom(tabpage)
  if not tabpage then tabpage = 0 end
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for z, _ in pairs(M.zoom_book) do
    if
      vim.api.nvim_win_is_valid(z)
      and vim.api.nvim_win_get_tabpage(z) == cur_tab
    then
      -- only returns valid z.
      return { true, z }
    end
  end

  return { false, nil }
end


function M.neo_zoom()
  if not _setup_is_called then
    error('NeoZoom.lua: Plugin has NOT been initialized. Please call `require("neo-zoom").setup({...})` first!')
  end
  -- always zoom-out regardless the type of its content.
  if M.did_zoom()[1] then
    local z = M.did_zoom()[2]
    local view = vim.fn.winsaveview()

    -- phrase1: try go back to zoom win.
    if vim.api.nvim_get_current_win() ~= z then
      vim.api.nvim_set_current_win(z)
      return
    end

    -- phrase2: try go back to original win.
    if vim.api.nvim_win_is_valid(M.zoom_book[z]) then
      vim.api.nvim_set_current_win(M.zoom_book[z])
      vim.api.nvim_set_current_buf(vim.api.nvim_win_get_buf(z))
      vim.fn.winrestview(view)
    end

    vim.api.nvim_win_close(z, true)
    M.zoom_book[z] = nil
    return
  end

  -- deal with case: might zoom.
  if U.table_contains(M.exclude_filetypes, vim.bo.filetype)
    or U.table_contains(M.exclude_buftypes, vim.bo.buftype) then
    return
  end

  -- deal with case: should zoom.
  local view = vim.fn.winsaveview()
  local buf_on_zoom = vim.api.nvim_win_get_buf(0)
  local win_on_zoom = vim.api.nvim_get_current_win()
  local editor = vim.api.nvim_list_uis()[1]
  local winopts = merged_config_delegate[vim.bo.filetype].winopts
  local offset = winopts.offset

  local z = vim.api.nvim_open_win(0, true, {
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
    border = winopts.border,
  })
  M.zoom_book[z] = win_on_zoom
  vim.api.nvim_set_current_buf(buf_on_zoom)

  U.run_callbacks(M.callbacks) -- callbacks for all cases.
  U.run_callbacks(merged_config_delegate[vim.bo.filetype].callbacks) -- callbacks for specific filetypes.

  if M.popup.enabled
    and not U.table_contains(M.popup.exclude_filetypes, vim.bo.filetype)
    and not U.table_contains(M.popup.exclude_buftypes, vim.bo.buftype)
  then
    vim.api.nvim_set_current_win(win_on_zoom)
    vim.cmd('enew')
    vim.bo.bufhidden = 'delete'
    vim.api.nvim_set_current_win(z)
  end

  vim.fn.winrestview(view)
end


local function setup_vim_commands()
  vim.api.nvim_create_user_command('NeoZoomToggle', M.neo_zoom, {})
end
setup_vim_commands()


return M
