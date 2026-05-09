# Repo File Inventory

Scope: every file under `macbook-m3/` plus `MIGRATION.md` at the repo root.
The `arch-xps/`, `arch-zen/`, `debian-zen/`, `do/`, `fedora/`, `lubuntu/`,
and `windows/` directories are intentionally excluded — they are outdated
and slated to be dropped.

## Cross-platform

Works as-is on both macOS and Linux without any per-OS branching.

- `MIGRATION.md` — repo-level documentation describing this migration.
- `macbook-m3/home/.bash-powerline.sh` — powerline prompt; branches internally on `uname` (Darwin / Linux / *) for the prompt symbol, plus conda env display. Pure bash + git, no OS-specific paths.
- `macbook-m3/home/.config/nvim/init.lua` — leader keys, options, Python filetype autocmd, window-nav keymaps, colorscheme. No OS-specific paths.
- `macbook-m3/home/.config/nvim/lua/config/lazy.lua` — `lazy.nvim` bootstrap; clones from GitHub, uses `vim.fn.stdpath("data")`.
- `macbook-m3/home/.config/nvim/lua/plugins/blink.lua` — `blink.cmp` completion plugin spec.
- `macbook-m3/home/.config/nvim/lua/plugins/colorscheme.lua` — `dracula.nvim` and `catppuccin/nvim` plugin specs.
- `macbook-m3/home/.config/nvim/lua/plugins/leetcode.lua` — `leetcode.nvim` plugin spec.
- `macbook-m3/home/.config/nvim/lua/plugins/lualine.lua` — `lualine.nvim` statusline config.
- `macbook-m3/home/.config/nvim/lua/plugins/telescope.lua` — `telescope.nvim` plugin spec.
- `macbook-m3/home/.config/nvim/lua/plugins/treesitter.lua` — `nvim-treesitter` plugin spec.
- `macbook-m3/home/.config/nvim/lua/plugins/twilight.lua` — `twilight.nvim` dimming plugin config.
- `macbook-m3/home/.config/nvim/lua/plugins/vim-tmux-navigator.lua` — `vim-tmux-navigator` keymaps.
- `macbook-m3/home/.config/nvim/lua/plugins/zenmode.lua` — `zen-mode.nvim` plugin config.

## macOS-only

Meaningful only on macOS, or tied to software you've said you only use on
macOS (kitty is your Mac terminal; the Linux target is a headless VPS).

- `macbook-m3/home/.config/kitty/kitty.conf` — kitty terminal config; explicitly sets `shell /opt/homebrew/bin/bash --login` and is only deployed where kitty runs (your MacBook). No use on the headless VPS.
- `macbook-m3/home/.config/kitty/current-theme.conf` — Catppuccin-Mocha kitty colors, included from `kitty.conf`. Same scope as above.

## Linux-only

(No files in this category yet — flagged per request.)

## Conditional

Mostly shared but each needs a small per-OS difference. Notes describe
what would have to change for the Linux VPS template.

- `macbook-m3/home/.bash_profile` — bash login profile deployed to `~`.
  - **Differences needed:**
    - `eval "$(/opt/homebrew/bin/brew shellenv)"` → either `/home/linuxbrew/.linuxbrew/bin/brew` (if brew is used on Linux) or skip the brew block entirely on a non-brew Linux host.
    - `alias ls='ls --color'` → fine on Linux (GNU coreutils); on macOS this only works if GNU `ls` from brew is on PATH, otherwise BSD `ls` wants `-G`. Worth verifying.
    - `export PATH="$PATH:/Users/adrienbarbot/.lmstudio/bin"` — LM Studio is Mac-only here; drop on Linux.
    - The `# >>> mamba initialize >>>` block hard-codes `MAMBA_EXE='/opt/homebrew/bin/micromamba'` and `MAMBA_ROOT_PREFIX='/Users/adrienbarbot/.local/share/mamb'`. The `MAMBA_EXE` path needs to be Linux-appropriate (e.g. `~/.local/bin/micromamba`) and the root prefix should use `~` rather than a literal `/Users/adrienbarbot/...` path. Also: `MAMBA_ROOT_PREFIX` value `mamb` looks like a typo for `mamba` — worth checking.
- `macbook-m3/home/.config/tmux/tmux.conf` — tmux config; mostly portable (prefix, mouse, vim-pane keys, base-index, plugin list, catppuccin styling).
  - **Differences needed:**
    - `set -g default-command "$HOMEBREW_PREFIX/bin/bash --login"` — depends on Homebrew being present. On a VPS without brew, this should be `/usr/bin/bash --login` (or just `bash --login`).
    - `set -g default-terminal "tmux-256color"` — works on both, but only if the `tmux-256color` terminfo entry is installed on the host. On older Linux distros you may need to fall back to `screen-256color`. Worth noting per-OS.

