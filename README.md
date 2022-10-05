NeoZoom.lua
---

### DEMO

https://user-images.githubusercontent.com/24765272/194027917-dedc162c-f017-4722-9468-c4ddddbedd57.mov


### Breaking Changes

- 2022/10/05:
  - I just updated the example setup(`keymap.set(...)` part) in README.md,
if you encounter any error try copy-paste it again. See #33 for more details.
- ~2022/10/05:
  - Using floating window instead of vim-tab to simulate "zoom-in".

---

The original idea of this project can be found on branch `neo-zoom-original`.
But I won't fix any bug on that anymore.

---

advantages:
1. Lightweight(< 100 lines): only increase 0.0001ms startup time.
2. Customizable UIs.
3. Only add one command: `NeoZoomToggle`.
4. Easy to work with your existing plugins:
- exposing `require('neo-zoom').FLOAT_WIN` a handle to the current floating window (you should check the validity yourself)
- exposing `require('neo-zoom').WIN_ON_ENTER` a handle to the window before zoom (you should check the validity yourself)

note: Change `<CR>` to whatever shortcut you like~

```lua

use {
  'nyngwang/NeoZoom.lua',
  requires = {
    'nyngwang/NeoNoName.lua' -- you will need this if you want to use the keymap sample below.
  },
  config = function ()
    require('neo-zoom').setup { -- use the defaults or UNCOMMENT and change any one to overwrite
      -- left_ratio = 0.2,
      -- top_ratio = 0.03,
      -- width_ratio = 0.67,
      -- height_ratio = 0.9,
      -- border = 'double',
      -- exclude_filetype = {
      --   'fzf', 'qf', 'dashboard'
      -- }
      -- scrolloff_on_zoom = 13, -- offset to the top-border.
    }
    local NOREF_NOERR_TRUNC = { silent = true, nowait = true }
    vim.keymap.set('n', '<CR>', require("neo-zoom").neo_zoom, NOREF_NOERR_TRUNC)

    -- My setup (This requires NeoNoName.lua, and optionally NeoWell.lua)
    local cur_buf = nil
    vim.keymap.set('n', '<CR>', function ()
      if require('neo-zoom').FLOAT_WIN ~= nil
        and vim.api.nvim_win_is_valid(require('neo-zoom').FLOAT_WIN) then
        vim.cmd('NeoZoomToggle')
        vim.api.nvim_set_current_buf(cur_buf)
        return
      end
      -- don't zoom-in on floating win.
      if vim.api.nvim_win_get_config(0).relative ~= '' then return end
      cur_buf = vim.api.nvim_get_current_buf()
      vim.cmd('NeoZoomToggle')
      vim.cmd('wincmd p')
      local try_get_no_name = require('neo-no-name').get_current_or_first_valid_listed_no_name_buf()
      if try_get_no_name ~= nil then
        vim.api.nvim_set_current_buf(try_get_no_name)
      else
        vim.cmd('NeoNoName')
      end
      vim.cmd('wincmd p')
      -- Post pop-up commands
      -- vim.cmd('NeoWellJump')
    end, NOREF_NOERR_TRUNC)
  end
}
```

