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
    }
    vim.keymap.set('n', '<CR>', function ()
      vim.cmd('NeoZoomToggle')
    end, NOREF_NOERR_TRUNC)
  end
}
```

Change `<CR>` to whatever shortcut you like~


### DEMO

will be uploaded
