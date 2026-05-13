# config

Personal cross-platform dotfiles, managed by [chezmoi], plus a SOPS-encrypted
secrets store consumed by the dev VPS bootstrap.

Targets two hosts:

- **MacBook (Darwin)** — daily driver. Includes kitty + brew + mamba bits.
- **Dev VPS (Linux)** — see [`catzhead/infra`](https://github.com/catzhead/infra).
  Headless; no kitty, no brew, mise instead.

Per-OS differences live inside `.tmpl` files and `.chezmoiignore`.

## Layout

```
dot_bash_profile.tmpl    # login shell — branches on .chezmoi.os
dot_bash-powerline.sh    # prompt; runtime-branches on uname
dot_gitconfig            # user.name / user.email / defaults
dot_config/
  nvim/                  # cross-platform
  tmux/                  # cross-platform
  kitty/                 # macOS-only (gated in .chezmoiignore)
secrets/
  secrets.enc.yaml       # SOPS+age, consumed by the infra bootstrap
.sops.yaml               # recipient = operator's age master key
.chezmoiignore           # repo docs + secrets/ + per-OS gates
```

## Apply on a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply catzhead
```

On the dev VPS this is invoked by `bootstrap/bootstrap.sh` in the infra repo;
no manual run needed there.

## Secrets

`secrets/secrets.enc.yaml` holds tailscale auth, GitHub PAT + SSH key, R2
credentials, OpenTofu state passphrase, and the Vultr API key. It is **not**
deployed to `~/` — it stays in the repo and is read directly by the infra
bootstrap.

Edit:

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops secrets/secrets.enc.yaml
```

Rotation procedures (per secret, including the age master key itself) are
documented in `catzhead/infra:docs/rotation.md`.

The age master private key lives in the operator's 1Password personal vault
as Secure Note "age master key — sops". It never enters this repo.

[chezmoi]: https://www.chezmoi.io/
