NeoZoom.lua
---

### DEMO

https://user-images.githubusercontent.com/24765272/148058457-b8c9acd5-e294-458b-80f9-ecbebb36b383.mov

### Intro.

Press `<CR>` to __zoom-in__ the naughty current window in a new tab, and undo so by pressing it again :)

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

#### Packer.nvim

__WARNING: I haven't figured out how to let you customize the shortcut :/, you can only use `<CR>` for now.__

```
use {
  'nyngwang/NeoZoom.lua'
}
```

### Usage: Shortcuts & Defaults

The default keymap of NeoZoom is `<CR>`. You can modify it with:

```
_G.__NEO_ZOOM_KEY = '<CR>'   -- Pick your lucky key.
```

If you rarely open many tabs / you don't know that (Neo)Vim has something called __tab__,
then you're good to go :)

### TODO list

- [ ] a better README.md
  - [ ] add a DEMO
  - [ ] add packer.nvim installation guide
  - [ ] add packer.nvim installation guide
- [ ] have to use `setup` function instead of the ugly `_G.` something





