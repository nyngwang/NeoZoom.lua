NeoZoom.lua
---


### Breaking Changes

- 2022/10/05:
  - I just updated the example setup(`keymap.set(...)` part) in README.md,
if you encounter any error try copy-paste it again. See #33 for more details.
- ~2022/10/05:
  - Using floating window instead of vim-tab to simulate "zoom-in".

---

> Wait, What? But I want to use the old one!

The old one can be found on branch `neo-zoom-original`!

---

advantages:
1. code down to 60 lines
2. no state, so no overhead (compared to the original version, see branches)
3. just one command left, `NeoZoomToggle`


```lua

use {
  'nyngwang/NeoZoom.lua',
  -- branch = 'neo-zoom-original', -- UNCOMMENT THIS, if you prefer the old one
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

Change `<CR>` to whatever shortcut you like~


### DEMO

will be uploaded
