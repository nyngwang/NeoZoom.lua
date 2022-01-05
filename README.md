NeoZoom.lua
---

### DEMO

https://user-images.githubusercontent.com/24765272/148058457-b8c9acd5-e294-458b-80f9-ecbebb36b383.mov

### Intro.

Are you still using `<C-W>o` to maximize a window split and **DESTROY THE OTHER ONES** under the same tab **😵**? You should try NeoZoom.lua!

You can think of NeoZoom.lua as enhanced `:tab split` , with these differences:

1. `:tab split` won't restore your cursor position after you close the tab, but NeoZoom.lua will do.
2. `:tab split` creates a new tab *on any circumstance*, while NeoZoom.lua closes those ones with a single window.

So NeoZoom.lua is more user friendly, you only need one key to zoom-in/out. Since it is so lightweight (<100 lines including README.md), so that's it :)

Some more details:

1. It zoom-in on any tab with more than one windows, and zoom-out on any tab with only one window. The last window in the last tab.
2. NeoZoom.lua is very lightweight. It's almost impossible to have any conflict with those favorite plugins of you already installed.
3. Floating window on cursor-hover (e.g. showing LSP Diagnostics message on cursor-hover) increases the number of windows, while this is taken into account.
4. If you're using [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua):
   1. You can open it after zoom-in.
   2. You can have it open before zoom-in. It will also be restored on zoom-out.

### Features

- Cursor pos. is restored, after zoom-in
- Very Light-weight (23 lines, including the comics in comment.)
- No dependencies, but you had better know nothing about tabs.
- (For advance users) Floating window on cursor-hover (e.g. to show LSP line Diagnostics message) indeed increases window count, this case is covered by NeoZoom.lua :)

### installation

#### Packer.nvim & Usage

```
use {
  'nyngwang/NeoZoom.lua'
}
-- Change '<CR>' to whatever shortcut you like :)
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





