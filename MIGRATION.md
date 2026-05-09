# Dotfiles Migration Plan

Migrate this repo from its ad-hoc `macbook-m3/` layout to a
chezmoi-managed cross-platform structure (current daily driver: MacBook
Pro M3; future target: Linux dev VPS).

**Strategy:** this repo's root *is* the chezmoi source directory.
Single repo, no separate `~/.local/share/chezmoi/` to manage.

## Steps

### 1. Inventory — DONE

Categorized every file under `macbook-m3/` as cross-platform / macOS-only
/ linux-only / conditional. See `INVENTORY.md`.

### 2. Install chezmoi, init default source dir — DONE

Confirmed chezmoi v2.70.3 already installed via Homebrew. Ran
`chezmoi init`, which created an empty `~/.local/share/chezmoi/` (will
be discarded in step 3). Also dropped three confirmed-dead files:
`macbook-m3/.bash-powerline.sh`, `macbook-m3/.profile`, and
`macbook-m3/home/.claude/skills/gitc/SKILL.md`.

### 3. Point chezmoi at this repo — DONE

Removed the empty `~/.local/share/chezmoi/`, created
`~/.config/chezmoi/chezmoi.toml` with
`sourceDir = "/Users/adrienbarbot/Workspace/github/config"`. Verified
with `chezmoi source-path` — prints the repo path.

> Important: do not run `chezmoi diff` or `chezmoi apply` until step 8
> adds `.chezmoiignore`. The repo still contains un-prefixed files
> (`INVENTORY.md`, `MIGRATION.md`, `macbook-m3/`, the obsolete distro
> dirs) that chezmoi would otherwise try to map to `~/`.

### 4. Drop obsolete per-distro folders — DONE

Deleted `arch-xps/`, `arch-zen/`, `debian-zen/`, `do/`, `fedora/`,
`lubuntu/`, `windows/`. ~150 files removed; `git status` confirms
all are staged for deletion. Repo root now contains only `.git/`,
`INVENTORY.md`, `MIGRATION.md`, and `macbook-m3/`.

### 5. Migrate cross-platform files (no templating) — DONE

`git mv`d into chezmoi-named paths at the repo root (renames detected
by git, history preserved):

- `macbook-m3/home/.bash-powerline.sh` → `dot_bash-powerline.sh`
- `macbook-m3/home/.config/nvim/` → `dot_config/nvim/`
  (init.lua, lua/config/lazy.lua, all 9 plugin files moved as a tree).

Files still inside `macbook-m3/home/` awaiting migration: `.bash_profile`
(step 6), `.config/tmux/tmux.conf` (step 6), `.config/kitty/*` (step 7).

### 6. Migrate conditional files as templates — DONE

Mamba verification turned up that micromamba *is* actively used on the
Mac (3 envs at the typo'd `~/.local/share/mamb` path, exported in the
running shell). Fixed the typo by:

- `rm -rf ~/.local/share/mamba` (deleted the empty correct-spelling scaffolding)
- `mv ~/.local/share/mamb ~/.local/share/mamba`

Verified `~/.local/share/mamba/envs/` contains `artio`, `lidar`,
`lidar1`. The user accepted that some envs may need recreating.

Templated both files:

- `macbook-m3/home/.bash_profile` → `dot_bash_profile.tmpl`. Brew
  shellenv + bash_completion gated to darwin. LM Studio PATH and
  mamba init block also darwin-only. Two intentional content diffs
  vs the live `~/.bash_profile` will show up at step 9: (a) mamba
  prefix uses corrected `mamba` not `mamb`, and (b) absolute
  `/Users/adrienbarbot/...` paths replaced with `$HOME/...` for
  portability.
- `macbook-m3/home/.config/tmux/tmux.conf` → `dot_config/tmux/tmux.conf.tmpl`.
  `default-command` line branches: `$HOMEBREW_PREFIX/bin/bash --login`
  on darwin, `/usr/bin/bash --login` elsewhere. Note: `tmux-256color`
  terminfo availability on the Linux target still needs confirming
  before step 9 / first VPS bootstrap.

Both templates verified with `chezmoi execute-template` — render output
matches the original (modulo the intentional fixes above).

Files still inside `macbook-m3/home/`: only the two kitty configs
(step 7).

### 7. Migrate macOS-only files — DONE

`git mv`d both kitty configs into `dot_config/kitty/`. Created
`.chezmoiignore` at the repo root with a template directive:

```
{{ if ne .chezmoi.os "darwin" -}}
.config/kitty
{{ end -}}
```

(Note: `.chezmoiignore` patterns reference *target* paths, not source
paths, so it's `.config/kitty` not `dot_config/kitty`.)

Verified with `chezmoi execute-template`: on darwin the rendered ignore
file is empty (kitty stays); the `ne darwin` conditional doesn't fire.
On any non-darwin host, the entire `~/.config/kitty/` tree will be
skipped at apply time.

`macbook-m3/` is now empty of files (only empty directories remain) —
will be removed in step 8.

### 8. Add repo-level `.chezmoiignore` — DONE

Extended `.chezmoiignore` (the same file created in step 7 for kitty
gating) to also ignore the loose docs:

```
# Repo-level docs — not dotfiles, must not deploy to ~/
MIGRATION.md
INVENTORY.md

# macOS-only paths
{{ if ne .chezmoi.os "darwin" -}}
.config/kitty
{{ end -}}
```

`.git/` is auto-ignored by chezmoi. The empty `macbook-m3/` shell was
removed with `rm -rf macbook-m3` rather than ignored.

Verified with `chezmoi managed`: the 23-entry list shows exactly the
expected targets (`.bash_profile`, `.bash-powerline.sh`, `.config/kitty/*`,
`.config/nvim/**`, `.config/tmux/tmux.conf`) — no `~/MIGRATION.md`,
no `~/INVENTORY.md`, no `~/macbook-m3/`. Safe to run `chezmoi diff` now.

### 9. Verify with `chezmoi diff` — DONE

First diff also showed a cosmetic blank-line drop in `tmux.conf` from
template whitespace stripping (`{{ end -}}` ate a newline). Fixed by
changing it to `{{ end }}` and dropping the now-redundant blank line
after the directive.

Final diff is exactly the two intentional `.bash_profile` fixes:

- LM Studio path: `/Users/adrienbarbot/.lmstudio/bin` → `$HOME/.lmstudio/bin`
- Mamba prefix: `/Users/adrienbarbot/.local/share/mamb` → `$HOME/.local/share/mamba`

No other diffs. Safe to apply.

### 10. Apply on the Mac, commit

- `chezmoi apply --dry-run --verbose` first.
- Then `chezmoi apply`.
- Sanity-check: open a fresh shell, run tmux, open nvim, open kitty.
- Commit the migrated source tree to this repo on `chezmoi-migration`.

### 11. Open PR, merge to master

Once verified working on the Mac.

### 12. (Future) Bootstrap the Linux VPS

On the VPS: `chezmoi init --apply <this-repo-url>`. Iterate on any
template guards that need adjustment (likely brew, mamba paths, kitty
gating).

## Decisions logged

- **Linux VPS will not use Homebrew.** Distro not yet picked, but assume
  system package manager. All brew-related blocks gate to darwin only.
- **Linux VPS does not need micromamba.** Mamba is Mac-only territory
  for now; gate to darwin (or drop entirely — see below).
- **The `mamb` typo is unintentional.** That it went unnoticed implies
  the mamba init may not actually be doing anything on the Mac either.
  Verify usage during step 6 before deciding whether to fix or delete.
