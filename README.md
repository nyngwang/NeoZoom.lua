<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="100" />

NeoZoom.lua
---

NeoZoom.lua aims to help you focus and maybe protect your left-rotated neck.


### DEMO

https://user-images.githubusercontent.com/24765272/213261410-d40eb109-75fe-4daa-b8fe-228b7a90c03b.mov


### How it works

The idea is simple: toggle your current window into a floating one, so you can:

1. Focus on one of your windows without mess-up any of your tabpages(=window layouts).
2. Pre-define a list of special window layout and assign the a list of `filetype`s for each.
   This way, you don't have to define many different keymaps for different window layouts.

(The original idea of this project can be found at branch `neo-zoom-original`)


### Features

- Only one function `neo_zoom()`.
  - `setup.winopts` will be picked up if no match against `setup.presets[i].filetypes`.
  - `setup.presets[n]` will be picked up, otherwise.
  - `setup.callbacks` are always called, regardless of `setup.presets[i].filetypes`.
- Some APIs to help you do customization:
  - `M.did_zoom(tabpage=0)` by passing a number `tabpage`, you can check for whether there is zoom-in window on the given `tabpage`.


### `keymap.set` Example

note: if you're using `lazy.nvim` then simply replace `requires` with `dependencies`.

```lua
use {
  'nyngwang/NeoZoom.lua',
  config = function ()
    require('neo-zoom').setup {
      winopts = {
        offset = {
          -- NOTE: you can omit `top` and/or `left` to center the floating window.
          -- top = 0,
          -- left = 0.17,
          width = 150,
          height = 0.85,
        },
        -- NOTE: check :help nvim_open_win() for possible border values.
        -- border = 'double',
      },
      -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
      exclude_buftypes = { 'terminal' },
      presets = {
        {
          filetypes = { 'dapui_.*', 'dap-repl' },
          config = {
            top = 0.25,
            left = 0.6,
            width = 0.4,
            height = 0.65,
          },
          callbacks = {
            function () vim.wo.wrap = true end,
          },
        },
      },
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


