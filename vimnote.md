
# Neovim Notes

## Surround Commands (vim-surround)

- `ysiw<key>` : Add `<key>` around the word
- `ds<key>` : Remove `<key>` surrounding a word
- `cs<key1><key2>` : Change `<key1>` to `<key2>`

## Text Selection

- `viw` : Select word
- `vi<key>` : Select content inside `<key>` (where `<key>` is a delimiter like `(`, `{`, `"`, etc.)
- `va<key>` : Select inclusive of `<key>`
- `S<key>` (in visual mode) : Surround selection with `<key>`

## Cursor Movement

- `<C-o>` : Jump to previous cursor position
- `<C-i>` : Jump to next cursor position
- `''` : Jump back to previous mark position

## Searching & Navigation

- `*` : Find next occurrence of the word under cursor
- `#` : Find previous occurrence of the word under cursor
- `g*` : Find next partial match of the word under cursor
- `g#` : Find previous partial match of the word under cursor
- `<C-g>` : Show buffer file path
- `<K>` : Show documentation for function/variable under cursor

## Folding

- `<za>` : Toggle fold
- `<zc>` : Close fold
- `<zo>` : Open fold
- `<zR>` : Open all folds
- `<zM>` : Close all folds

## Buffer & File Management

- `:bp` / `:bn` : Go to previous/next buffer
- `:bd` : Close current buffer
- `<C-^>` : Switch to last used buffer
- `gf` : Open file under cursor
- `<C-w>f` : Open file under cursor in a new split

## Windows & Splits

- `<C-w>v` : Split window vertically
- `<C-w>s` : Split window horizontally
- `<C-w>w` : Switch between windows
- `<C-w>c` : Close window
- `<C-w>o` : Close all other windows

## Terminal Mode (Neovim)

- `<C-\><C-n>` : Exit terminal mode
- `<C-w>n` : Open new terminal buffer

## Tabs

- `:tabnew` : Open a new tab
- `gt` : Next/Previous tab
- `:tabclose` : Close current tab
- `:tabonly` : Close all other tabs

## Miscellaneous

- `.` : Repeat last command
- `u` : Undo last change
- `<C-r>` : Redo
- `:%s/old/new/gc` : Replace `old` with `new` in the whole file with confirmation
- `gg=G` : Auto-indent entire file

These commands help boost productivity in Vim/Neovim!
