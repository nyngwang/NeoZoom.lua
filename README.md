NeoZoom.lua
---

### DEMO

https://user-images.githubusercontent.com/24765272/148058457-b8c9acd5-e294-458b-80f9-ecbebb36b383.mov

### Intro.

Are you still using `<C-W>o` to maximize a window split and **DESTROY THE OTHER ONES** under the same tab **😵**? You should try NeoZoom.lua!

You can think of NeoZoom.lua as enhanced `:tab split` , with these differences:

1. `:tab split` won't restore your cursor position after you close the tab, while NeoZoom.lua will do.
2. `:tab split` won't pin your current cursorline to 80% of height, while NeoZoom.lua will do to prevent you become a turtle 🐢.
3. `:tab split` creates a new tab *on any circumstance*, while NeoZoom.lua `tabclose` one with a single window.

So NeoZoom.lua is more user friendly, you only need one key to zoom-in/out.

Some more details:

1. It zoom-in on any tab with more than one windows, and zoom-out on any tab with only one window. The last window in the last tab won't be close.
2. NeoZoom.lua is very lightweight. It's almost impossible to have any conflict with those favorite plugins that you already installed.
3. Floating window on cursor-hover (e.g. showing LSP Diagnostics message on cursor-hover) increases the number of windows, while this is taken into account.
4. If you're using [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua):
   1. You can open it after zoom-in.
   2. You can have it open before zoom-in. It will also be restored on zoom-out.

### Features

- Cursor pos. is restored, after zoom-in
- Very Light-weight (27 lines, excluding non-logics)
- No dependencies, but you had better know nothing about tabs.
- (For advance users) Floating window on cursor-hover (e.g. to show LSP line Diagnostics message) indeed increases window count, this case is covered by NeoZoom.lua :)

### installation

#### Packer.nvim

```
use {
  'nyngwang/NeoZoom.lua'
}
```

### Usage

Change `<CR>` to whatever shortcut you like~

Recommended, I will keep track of this one to make sure it always works after any possible breaking change
```
-- if you use `<CR>` as toggle, then you should handle when to fallback yourself so it won't intercept the plain-old `<CR>`.
vim.api.nvim_set_keymap('n', '<CR>', "&ft != 'qf' ? '<cmd>NeoZoomToggle<CR>' : '<CR>'", { noremap=true, silent=true, nowait=true })
```

Simple one, __If you never use quickfix list, pick this one__
```
vim.api.nvim_set_keymap('n', '<CR>', '<cmd>NeoZoomToggle<CR>', { noremap=true, silent=true, nowait=true })
```

### TODO list

- [x] a better README.md
  - [x] add a DEMO
  - [x] add packer.nvim installation guide
  - [x] customizable shortcut
- [ ] config setup tutorial, must be simple and useful
  - [x] have to use `setup` function instead of the ugly `_G.` something
  - [ ] add a exclusion list for those strange `buf/filetype`





