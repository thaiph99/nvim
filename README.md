# nvimnative

A native Neovim configuration built on the built-in `vim.pack` package manager
(Neovim **0.12+**), with **no framework** (no NvChad, no lazy.nvim). It mirrors
the features and keymaps of my previous NvChad config.

## Install on a new machine

```sh
git clone <this-repo> ~/.config/nvimnative
NVIM_APPNAME=nvimnative nvim          # first launch clones all plugins
```

Then, inside Neovim, install the LSP servers and formatters with the single
Mason command in [Tooling (Mason)](#tooling-mason), and run `:Copilot setup`
to authenticate Copilot. Make sure the system dependencies below are present
first.

### System dependencies

Install these on the host before launching (use your package manager —
`brew` / `apt` / `pacman` / `dnf`):

| Tool                 | Used by                                            |
| -------------------- | -------------------------------------------------- |
| **Neovim ≥ 0.12**    | `vim.pack`, native LSP                             |
| `git`                | `vim.pack` plugin clones                          |
| `gcc`/`make`         | telescope-fzf-native, Treesitter parsers          |
| `ripgrep` (`rg`)     | Telescope live grep                               |
| `fd`                 | Telescope find files (Debian: binary is `fdfind`) |
| `node` + `npm`       | Copilot, prettier, JS/TS LSP                      |
| `go`                 | gopls, gofumpt, goimports                         |
| JDK (Java 17+)       | jdtls (Java LSP/DAP)                              |
| `python3` + `pip`    | pyright, black, isort                            |
| `curl`, `unzip`      | Mason downloads                                   |

Example one-liners:

```sh
# macOS (Homebrew)
brew install neovim git ripgrep fd node go openjdk python

# Debian/Ubuntu (note: fd binary is 'fdfind' — symlink it to 'fd' for telescope)
sudo apt install -y git curl unzip build-essential ripgrep fd-find \
  nodejs npm golang-go default-jdk python3 python3-pip

# Arch
sudo pacman -S --needed neovim git curl unzip base-devel ripgrep fd \
  nodejs npm go jdk-openjdk python python-pip
```

### Tooling (Mason)

LSP servers and formatters are **not** auto-installed. After first launch, run
this once inside Neovim to install everything this config uses:

```vim
:MasonInstall lua-language-server pyright html-lsp css-lsp clangd gopls typescript-language-server jdtls stylua isort black goimports gofumpt shfmt prettierd prettier cmakelang markdownlint google-java-format clang-format codelldb java-debug-adapter java-test
```

(`:Mason` opens the interactive UI to manage/update them; `:checkhealth` flags
anything missing.) The DAP adapters `codelldb`, `java-debug-adapter` and
`java-test` also auto-install via `mason-nvim-dap` on first debug use, so they
are optional in the command above.

## Running it

This config lives in `~/.config/nvimnative`, so launch it with:

```sh
NVIM_APPNAME=nvimnative nvim
```

To make it your default, either set `NVIM_APPNAME=nvimnative` in your shell
profile, or move it to `~/.config/nvim`.

First launch clones ~34 plugins via `vim.pack`. A cold install can hit the
internal clone timeout — if some plugins look empty, just **restart Neovim**
(or run `:lua vim.pack.update()`) and it finishes the rest. Treesitter parsers
and DAP adapters install in the background on first use; LSP servers and
formatters come from Mason (see above).

## Layout

```
init.lua                 leader + module loading
lua/options.lua          editor options (was nvchad.options + custom)
lua/keymaps.lua          all keymaps (NvChad defaults + custom)
lua/autocmds.lua         autosave, formatoptions, clang-format, quickfix
lua/plugins/init.lua     vim.pack.add() plugin list + build hooks
lua/plugins/*.lua        per-plugin setup
```

## What replaced NvChad

| NvChad piece            | Native replacement            |
| ----------------------- | ----------------------------- |
| lazy.nvim               | `vim.pack` (built-in)         |
| base46 / chadracula     | `dracula.nvim`                |
| NvChad statusline       | native statusline (`%!` expr) |
| NvChad tabufline        | native tabline (buffer list)  |
| nvdash dashboard        | none (native empty buffer)    |
| NvChad mappings         | explicit `lua/keymaps.lua`    |
| NvChad completion       | `blink.cmp` (pinned v1.10.2)  |
| Comment.nvim            | native `gc`                   |
| vim-illuminate          | native `vim.lsp` document highlight |
| nvchad.configs.lspconfig| native `vim.lsp.config/enable`|

The statusline and tabline are plain Lua functions in `lua/plugins/ui.lua`
(`_G.__statusline` / `_G.__tabline`) wired up via `%!` expressions — no plugin.

## Managing plugins

- Add a plugin: add a `{ src = "https://github.com/..." }` line in
  `lua/plugins/init.lua`, restart. Plugins needing a compile step go in the
  `build_steps` table at the top of that file.
- Update all: `:lua vim.pack.update()`
- Remove: delete its spec, then `:lua vim.pack.del({ "name" })`.
- LSP servers / formatters / DAP adapters: `:Mason`.

## Key mappings (leader = `Space`)

### General

| Key            | Action                          |
| -------------- | ------------------------------- |
| `jk` (insert)  | Escape                          |
| `<Esc>`        | Clear search highlight          |
| `<C-s>`        | Save                            |
| `<C-c>`        | Copy whole file                 |
| `<leader>/`    | Toggle comment                  |
| `<leader>fm`   | Format buffer (conform)         |
| `<leader>n`    | Toggle line numbers             |
| `<leader>rn`   | Toggle relative numbers         |

### Windows / motions (Alt-based, as in the old config)

| Key                  | Action                |
| -------------------- | --------------------- |
| `<A-h/j/k/l>`        | Move between windows  |
| `<C-h/j/k/l>`        | Move between windows  |
| `<A-d>` / `<A-u>`    | Page down / up        |
| `<A-p>` / `<A-o>`    | Jump forward / back   |
| `<A-v>`              | Visual block          |
| `<A-g>`              | Show file path        |

### Buffers / files

| Key            | Action                          |
| -------------- | ------------------------------- |
| `<Tab>`        | Next buffer                     |
| `<S-Tab>`      | Previous buffer                 |
| `<leader>b`    | New buffer                      |
| `<leader>x`    | Close buffer and go back        |
| `<C-n>`        | Toggle file tree                |
| `<leader>e`    | Focus file tree                 |

### Telescope

| Key            | Action                                       |
| -------------- | -------------------------------------------- |
| `<leader>ff`   | Find files (visual: with selection)          |
| `<leader>fa`   | Find all files incl. hidden (visual: too)    |
| `<leader>fw`   | Live grep (visual: with selection)           |
| `<leader>fb`   | Buffers                                      |
| `<leader>fo`   | Recent files                                 |
| `<leader>fz`   | Fuzzy find in current buffer                 |
| `<leader>fh`   | Help tags                                    |
| `<leader>fr`   | Resume last picker                           |
| `<leader>ma`   | Marks                                        |
| `<leader>cm`   | Git commits                                  |
| `<leader>gt`   | Git status                                   |

### LSP (on attach)

| Key            | Action                          |
| -------------- | ------------------------------- |
| `gd`           | Definitions (Telescope)         |
| `gD`           | Type definitions (Telescope)    |
| `gr`           | References (Telescope)          |
| `gi`           | Implementations (Telescope)     |
| `K`            | Hover docs                      |
| `<leader>ra`   | Rename                          |
| `<leader>ca`   | Code action                     |
| `<leader>sh`   | Signature help                  |
| `<leader>dd`   | Line diagnostics float          |

### Quickfix / terminal

| Key            | Action                                       |
| -------------- | -------------------------------------------- |
| `<leader>qa`   | Add current line to quickfix                 |
| `dd` (in qf)   | Delete quickfix entry (`d` in visual)        |
| `<A-i>`        | Toggle floating terminal                     |
| `<A-q>` (term) | Escape terminal mode                         |

### DAP

| Key            | Action                |
| -------------- | --------------------- |
| `<leader>db`   | Toggle breakpoint     |
| `<leader>dc`   | Start / continue      |
| `<leader>di`   | Step into             |
| `<leader>do`   | Step over             |
| `<leader>dO`   | Step out              |
| `<leader>dt`   | Terminate             |
| `<leader>dr`   | Toggle REPL           |
| `<leader>du`   | Toggle DAP UI         |
| `<leader>dh`   | Hover variables       |
| `<leader>ds`   | Show scopes           |

### Copilot

| Key             | Action            |
| --------------- | ----------------- |
| `<A-l>` (insert)| Accept suggestion |
