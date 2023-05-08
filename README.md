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


<details>
<summary>Click to expand</summary>
<br>

```lua
require('neo-zoom').setup {
  -- ...
  callbacks = {
    function ()
      if vim.wo.winhl == '' then vim.wo.winhl = 'Normal:' end
    end,
    -- ...
  },
}

vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  callback = function ()
    local did_zoom = require('neo-zoom').did_zoom()
    if not did_zoom[1] then return end

    -- wait for upstream: https://github.com/neovim/neovim/issues/23542.
    if vim.api.nvim_get_current_win() == did_zoom[2]
    then vim.api.nvim_win_set_option(did_zoom[2], 'winbl', 0)
    else vim.api.nvim_win_set_option(did_zoom[2], 'winbl', 20) end
  end
})
```

</details>
