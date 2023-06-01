<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="100" />

NeoZoom.lua
---

NeoZoom.lua aims to help you focus and maybe protect your left-rotated neck.


### DEMO

https://user-images.githubusercontent.com/24765272/236957570-deb3f414-2dd5-4c8c-adc4-0784edba751b.mov


### How it works

The idea is simple: toggle your current window into a floating one, so you can:

1. Focus on one of your windows without mess-up any of your tabpages(=window layouts).
2. Pre-define a window layout for each list of `filetype`s. Now you can use the same
   keymap to have a customized window layout depending on the `filetype` of the current buffer.

(The original idea of this project can be found at branch `neo-zoom-original`)


### Features

- Only one function `neo_zoom()`.
  - `setup.winopts` will be picked up if no match against `setup.presets[i].filetypes`.
  - `setup.presets[n]` will be picked up, otherwise.
  - `setup.callbacks` are always called, regardless of `setup.presets[i].filetypes`.
- Some APIs to help you do customization:
  - `M.did_zoom(tabpage=0)` by passing a number `tabpage`, you can check for whether there is zoom-in window on the given `tabpage`.


### Setup

<details>
<summary>Click to expand </summary>
<br>

> NOTE: remove `use` if you're using `lazy.nvim`.

```lua
use {
  'nyngwang/NeoZoom.lua',
  config = function ()
    require('neo-zoom').setup {
      popup = { enabled = true }, -- this is the default.
      -- NOTE: Add popup-effect (replace the window on-zoom with a `[No Name]`).
      -- EXPLAIN: This improves the performance, and you won't see two
      --          identical buffers got updated at the same time.
      -- popup = {
      --   enabled = true,
      --   exclude_filetypes = {},
      --   exclude_buftypes = {},
      -- },
      exclude_buftypes = { 'terminal' },
      -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
      winopts = {
        offset = {
          -- NOTE: omit `top`/`left` to center the floating window vertically/horizontally.
          -- top = 0,
          -- left = 0.17,
          width = 150,
          height = 0.85,
        },
        -- NOTE: check :help nvim_open_win() for possible border values.
        border = 'thicc', -- this is a preset, try it :)
      },
      presets = {
        {
          -- NOTE: regex pattern can be used here!
          filetypes = { 'dapui_.*', 'dap-repl' },
          winopts = {
            offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.25 },
          },
        },
        {
          filetypes = { 'markdown' },
          callbacks = {
            function () vim.wo.wrap = true end,
          },
        },
      },
    }
    vim.keymap.set('n', '<CR>', function () vim.cmd('NeoZoomToggle') end, { silent = true, nowait = true })
  end
}
```

</details>


### Bonus: transparent bg when unfocus

Thanks for the support from the upstream, i.e. https://github.com/neovim/neovim/issues/23542 :) 

https://user-images.githubusercontent.com/24765272/236956036-7de2cd97-bb25-4bff-93c1-91dd12618463.mov

<details>
<summary>Click to expand</summary>
<br>

```lua
vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  callback = function ()
    local zoom_book = require('neo-zoom').zoom_book

    if require('neo-zoom').is_neo_zoom_float()
    then for z, _ in pairs(zoom_book) do vim.wo[z].winbl = 0 end
    else for z, _ in pairs(zoom_book) do vim.wo[z].winbl = 20 end
    end
  end
})
```

</details>
