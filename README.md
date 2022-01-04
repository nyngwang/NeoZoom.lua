NeoZoom.lua
---

### DEMO

https://user-images.githubusercontent.com/24765272/148058457-b8c9acd5-e294-458b-80f9-ecbebb36b383.mov

### Intro.

Press `<CR>`(customizable) to __zoom-in__ the naughty current window in a new tab, and undo so by pressing it again :)

### Features

- Cursor pos. is restored, after zoom-in
- Fucking Light-weight (23 lines, including the comics in comment.)
- No dependencies, but you had better know nothing about tabs.
- (For advance users) Floating window on cursor-hover (e.g. to show LSP line Diagnostics message) indeed increases window count, this case is covered by NeoZoom.lua :)

---

### Requirements

- You rarely use tabs
- You like zoom-in-and-zoom-out

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

- [ ] a better README.md
  - [x] add a DEMO
  - [x] add packer.nvim installation guide
  - [x] customizable shortcut
- [x] have to use `setup` function instead of the ugly `_G.` something





