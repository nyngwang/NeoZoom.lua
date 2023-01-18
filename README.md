NeoZoom.lua
---

NeoZoom.lua aims to help you focus and maybe protect your left-rotated neck.


### DEMO

https://user-images.githubusercontent.com/24765272/213261410-d40eb109-75fe-4daa-b8fe-228b7a90c03b.mov


### How it works

The idea is simple: toggle your current window into a floating one, so you can:

1. keep you original window layout **intact**.
2. keep your tabpage(s) **intact**.
    - if you know how to use tabpages then this is a good news.
    - if you don't know how to use tabpages... well, now you don't have to close out-of-use ones. So a good news too.
3. keep your neck **intact**. Oops, this is intended to be a joke.


This project now has experienced three iterations (:tada:),
you can find the original idea(first iter.) on branch `neo-zoom-original`,
which I won't fix any bug on that anymore.

### Features

- Only one command: `NeoZoomToggle`.
- Some APIs to help you do customization:
  - `M.neo_zoom(scrolloff=13)` by passing a custom number `scrolloff`, you can have different scrolloff on zoom.
  - `M.did_zoom(tabpage=0)` by passing a number `tabpage`, you can check for whether there is zoom-in window on `tabpage`.


### `keymap.set` Example

note: if you're using `lazy.nvim` then simply replace `requires` with `dependencies`.

```lua
use {
  'nyngwang/NeoZoom.lua',
  requires = { 'nyngwang/NeoNoName.lua' }, -- this is only required if you want the `keymap` below.
  config = function ()
    require('neo-zoom').setup {
      -- top_ratio = 0,
      -- left_ratio = 0.225,
      -- width_ratio = 0.775,
      -- height_ratio = 0.925,
      exclude_filetypes = { 'mason', 'lspinfo', 'qf' },
      exclude_buftypes = { 'terminal' },
    }
    vim.keymap.set('n', '<CR>', function ()
      local win_on_zoom = vim.api.nvim_get_current_win()
      local buf_on_zoom = vim.api.nvim_get_current_buf()
      vim.cmd('NeoZoomToggle')

      -- if did zoom then clean-up the window on zoom temporarily to create popup effect.
      if require('neo-zoom').did_zoom() then
        vim.api.nvim_set_current_win(win_on_zoom)
        vim.cmd('NeoNoName')
        vim.cmd('wincmd p')
      else
        vim.api.nvim_set_current_buf(buf_on_zoom)
      end
    end, { silent = true, nowait = true })
  end
}
```


