NeoZoom.lua
---


### News: A Breaking Change(ABC)

TL;DR: Using floating window instead of vim-tab to simulate "zoom-in".

---

> Wait, What? But I want to use the old one!

The old one can be found on branch `neo-zoom-original`!

---

advantages:
1. code down to 60 lines
2. no state, so no overhead (compared to the original version, see branches)
3. just one command left, `NeoZoomToggle`


```lua
local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }

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
    vim.keymap.set('n', '<CR>', function ()
      vim.cmd('NeoZoomToggle')
    end, NOREF_NOERR_TRUNC)

    -- My setup (This requires NeoNoName.lua, and optionally NeoWell.lua)
    local cur_buf = nil
    local cur_cur = nil
    vim.keymap.set('n', '<CR>', function ()
      -- Pop-up Effect
      if vim.api.nvim_win_get_config(0).relative == '' then
        cur_buf = vim.fn.bufnr()
        cur_cur = vim.api.nvim_win_get_cursor(0)
        if vim.fn.bufname() ~= '' then
          vim.cmd('NeoNoName')
        end
        vim.cmd('NeoZoomToggle')
        vim.api.nvim_set_current_buf(cur_buf)
        vim.api.nvim_win_set_cursor(0, cur_cur)
        vim.cmd("normal! zt")
        vim.cmd("normal! 7k7j")
        return
      end
      vim.cmd('NeoZoomToggle')
      vim.api.nvim_set_current_buf(cur_buf)
      cur_buf = nil
      cur_cur = nil
      -- vim.cmd('NeoWellJump') -- you can safely remove this line.
    end, NOREF_NOERR_TRUNC)
  end
}
```

Change `<CR>` to whatever shortcut you like~


### DEMO

will be uploaded
