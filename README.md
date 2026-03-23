# bootstrap

Cross-platform personal bootstrap for macOS and Linux with:

- `chezmoi` for dotfiles
- `ansible` for machine bootstrap
- `Brewfile` for macOS packages

## What It Covers

- shell and app config: `zsh`, `kitty`, `tmux`, `starship`, `nvim`
- macOS package install via `Brewfile`
- Arch/CachyOS-friendly Linux package install via Ansible
- wallpapers stored in `assets/wallpapers/`
- baseline macOS defaults

## Repo Layout

```text
.
├── Brewfile
├── ansible/
├── assets/
├── chezmoi/
└── scripts/
```

Use this rule when adding new things:

- `chezmoi/`: home-directory config files
- `ansible/`: package install and OS bootstrap logic
- `assets/`: wallpapers, themes, other tracked static files
- `scripts/`: focused apply/sync helpers

## Quick Start

From the repo root:

```bash
./scripts/bootstrap.sh
```

That will:

- install bootstrap prerequisites
- install packages
- apply dotfiles
- apply a wallpaper
- apply baseline macOS defaults on macOS

## Common Commands

Apply everything:

```bash
./scripts/bootstrap.sh
```

Apply only wallpaper:

```bash
./scripts/apply-wallpaper.sh
```

Apply a specific wallpaper:

```bash
BOOTSTRAP_WALLPAPER="Mojave Night.jpg" ./scripts/apply-wallpaper.sh
```

Apply only macOS defaults:

```bash
./scripts/macos-defaults.sh
```

Sync current machine config back into the repo:

```bash
./scripts/sync-from-machine.sh
```

Sync current Homebrew state back into `Brewfile`:

```bash
./scripts/sync-from-machine.sh --brewfile
```

Sync wallpapers from `~/Pictures/Wallpapers`:

```bash
./scripts/sync-from-machine.sh --wallpapers
```

Sync everything:

```bash
./scripts/sync-from-machine.sh --all
```

## Platform Notes

macOS:

- uses `Brewfile` for packages
- applies wallpaper
- applies baseline macOS defaults

Linux:

- package bootstrap is currently aimed at Arch/CachyOS-style systems
- wallpaper apply currently supports KDE Plasma, GNOME, and Cinnamon
- dotfiles still apply cleanly on other distros

## Important Files

- `Brewfile`: curated macOS package baseline
- `ansible/site.yml`: local bootstrap playbook
- `ansible/roles/common/tasks/main.yml`: shared bootstrap tasks
- `scripts/bootstrap.sh`: one-shot machine setup
- `scripts/sync-from-machine.sh`: pulls live machine state back into the repo

## How To Extend It

When adding something new:

1. If it is a dotfile or app config, add it under `chezmoi/`.
2. If it installs packages or does OS bootstrap work, add it under `ansible/`.
3. If it is a tracked asset, add it under `assets/`.
4. If it is an action like apply/sync/setup, add one focused script under `scripts/`.

Keep it small. Split only when a file stops being readable in one sitting.
