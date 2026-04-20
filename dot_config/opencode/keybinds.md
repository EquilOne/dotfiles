# OpenCode Keybinds

Leader key: `ctrl+x`

All `<leader>` binds require pressing `ctrl+x` first, then the key.

---

## App

| Keys | Action |
|------|--------|
| `<leader>q` | Quit |
| `<leader>e` | Open editor |
| `<leader>b` | Toggle sidebar |
| `<leader>s` | Status view |
| `ctrl+z` | Suspend to background |
| `ctrl+p` | Command list |

---

## Agents & Models

| Keys | Action |
|------|--------|
| `tab` | Cycle agents forward (chat → plan → build) |
| `shift+tab` | Cycle agents backward |
| `<leader>a` | Open agent list |
| `<leader>m` | Open model list |
| `f2` | Cycle recent models |
| `shift+f2` | Cycle recent models (reverse) |
| `ctrl+t` | Cycle model variants |

---

## Sessions

| Keys | Action |
|------|--------|
| `<leader>n` | New session |
| `<leader>l` | List sessions |
| `<leader>g` | Session timeline |
| `<leader>c` | Compact session context |
| `escape` | Interrupt running response |
| `<leader>right` | Cycle to next child session |
| `<leader>left` | Cycle to previous child session |
| `<leader>up` | Go to parent session |

---

## Message Navigation

| Keys | Action |
|------|--------|
| `ctrl+u` | Half page up |
| `ctrl+d` | Half page down |
| `ctrl+alt+u` | Full page up |
| `ctrl+f` | Full page down |
| `ctrl+alt+y` | Scroll line up |
| `ctrl+alt+e` | Scroll line down |
| `ctrl+g` / `home` | Jump to first message |
| `ctrl+alt+g` / `end` | Jump to last message |
| `<leader>y` | Copy message |
| `<leader>u` | Undo last message |
| `<leader>r` | Redo |
| `<leader>h` | Toggle conceal (hide tool output) |

---

## Input Editing

### Submission

| Keys | Action |
|------|--------|
| `return` | Submit |
| `shift+return` / `ctrl+return` / `alt+return` / `ctrl+j` | Insert newline |
| `ctrl+c` | Clear input |
| `ctrl+v` | Paste |

### Cursor Movement

| Keys | Action |
|------|--------|
| `left` / `right` | Move character left/right |
| `up` / `down` | Move line up/down (or history) |
| `alt+b` / `alt+left` / `ctrl+left` | Word backward |
| `alt+f` / `alt+right` / `ctrl+right` | Word forward |
| `ctrl+alt+a` | Line home (start of line) |
| `ctrl+e` | Line end |
| `alt+a` | Visual line home |
| `alt+e` | Visual line end |
| `home` | Buffer home (start of input) |
| `end` | Buffer end |

### Selection

| Keys | Action |
|------|--------|
| `shift+left` / `shift+right` | Select character |
| `shift+up` / `shift+down` | Select line |
| `alt+shift+b` / `alt+shift+left` | Select word backward |
| `alt+shift+f` / `alt+shift+right` | Select word forward |
| `ctrl+shift+a` | Select to line home |
| `ctrl+shift+e` | Select to line end |
| `alt+shift+a` | Select to visual line home |
| `alt+shift+e` | Select to visual line end |
| `shift+home` | Select to buffer home |
| `shift+end` | Select to buffer end |

### Deletion

| Keys | Action |
|------|--------|
| `backspace` / `shift+backspace` | Backspace |
| `delete` / `shift+delete` | Delete forward |
| `ctrl+w` / `ctrl+backspace` / `alt+backspace` | Delete word backward |
| `alt+d` / `alt+delete` / `ctrl+delete` | Delete word forward |
| `ctrl+k` | Delete to line end |
| `ctrl+u` | Delete to line start |
| `ctrl+shift+d` | Delete entire line |

### Undo/Redo (input)

| Keys | Action |
|------|--------|
| `ctrl+-` / `super+z` | Undo in input |
| `ctrl+.` / `super+shift+z` | Redo in input |

### History

| Keys | Action |
|------|--------|
| `up` | Previous prompt in history |
| `down` | Next prompt in history |
