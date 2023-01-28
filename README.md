NeoZoom.lua
---

NeoZoom.lua aims to help you focus and maybe protect your left-rotated neck.


### DEMO

https://user-images.githubusercontent.com/24765272/213261410-d40eb109-75fe-4daa-b8fe-228b7a90c03b.mov


### How it works

The idea is simple: toggle your current window into a floating one, so you can:

1. keep you window layout **intact** and just focus on the current one.
2. keep your neck **intact**, since you can always pass an `{opt}` on every call of `neo_zoom()`.

Btw, this is a bullet-proof project, which has experienced three iterations (:tada:),
you can find my original idea on branch `neo-zoom-original`(no bug on that anymore).


### Features

- Only one function `neo_zoom({opt})`, where `{opt}` is optional.
  - it will always pick what you have passed to `setup` if you omit `{opt}`, and command `NeoZoomToggle` is created for this.
  - You can always get a variation by passing the `{opt}` on every call to customize the top/left/height/width/etc options.
- Some APIs to help you do customization:
  - `M.did_zoom(tabpage=0)` by passing a number `tabpage`, you can check for whether there is zoom-in window on the given `tabpage`.


### `keymap.set` Example

note: if you're using `lazy.nvim` then simply replace `requires` with `dependencies`.

```lua
use {
  'nyngwang/NeoZoom.lua',
  config = function ()
    require('neo-zoom').setup {
      -- top_ratio = 0,
      -- left_ratio = 0.225,
      -- width_ratio = 0.775,
      -- height_ratio = 0.925,
      -- border = 'double',
      -- disable_by_cursor = true, -- zoom-out/unfocus when you click anywhere else.
      -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
      exclude_buftypes = { 'terminal' },
      -- popup = {
      --   -- NOTE: Add popup-effect (replace the window on-zoom with a `[No Name]`).
      --   -- This way you won't see two windows of the same buffer
      --   -- got updated at the same time.
      --   enabled = true,
      --   exclude_filetypes = {},
      --   exclude_buftypes = {},
      -- },
    }
    vim.keymap.set('n', '<CR>', function () vim.cmd('NeoZoomToggle') end, { silent = true, nowait = true })
  end
}
```


