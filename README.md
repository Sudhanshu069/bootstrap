# bootstrap

Minimal cross-platform personal bootstrap for macOS and Linux, using:

- `chezmoi` for home-directory config files
- `ansible` for machine bootstrap

This starter favors a small, readable layout over extra layers. Linux support is aimed at Arch/CachyOS first. The structure leaves room for other distros without guessing package mappings too early.

The tracked `Brewfile` is curated for baseline workstation setup, not a raw export of every package ever installed on one machine.

## Layout

```text
.
├── Brewfile
├── README.md
├── ansible
│   ├── inventory
│   │   └── localhost.yml
│   ├── roles
│   │   └── common
│   │       └── tasks
│   │           └── main.yml
│   └── site.yml
├── assets
│   ├── themes
│   └── wallpapers
├── chezmoi
│   ├── dot_config
│   │   ├── kitty
│   │   │   └── kitty.conf
│   │   ├── nvim
│   │   │   └── init.lua
│   │   ├── starship.toml
│   ├── dot_tmux.conf
│   └── dot_zshrc
└── scripts
    ├── apply-wallpaper.sh
    ├── bootstrap.sh
    ├── macos-defaults.sh
    └── sync-from-machine.sh
```

## What This Version Does

- Installs a small baseline toolset with Ansible
- Applies dotfiles from the repo with `chezmoi`
- Keeps OS-specific package logic isolated to Ansible tasks
- Uses `Brewfile` for macOS package state
- Leaves wallpapers and themes as shared repo assets
- Applies a repo-tracked wallpaper on supported desktop environments
- Applies a small set of baseline macOS defaults

## Bootstrap

Run the repo bootstrap script from the project root:

```bash
./scripts/bootstrap.sh
```

The script does the minimum needed to get started:

- On macOS:
  - installs Homebrew if missing
  - installs `ansible` and `chezmoi`
  - applies the repo `Brewfile` if present
  - runs the local Ansible playbook
  - applies the `chezmoi` source tree
  - applies the default wallpaper from `assets/wallpapers/`
  - applies baseline macOS defaults from `scripts/macos-defaults.sh`
- On Linux:
  - supports `pacman`-based systems in this starter
  - installs `ansible` and `chezmoi`
  - runs the local Ansible playbook with privilege escalation
  - applies the `chezmoi` source tree
  - tries to apply the default wallpaper on KDE Plasma, GNOME, or Cinnamon

To apply a specific wallpaper from the repo:

```bash
BOOTSTRAP_WALLPAPER="Mojave Night.jpg" ./scripts/apply-wallpaper.sh
```

To apply only the macOS settings:

```bash
./scripts/macos-defaults.sh
```

To sync your current machine state back into the repo:

```bash
./scripts/sync-from-machine.sh
```

## Manual Apply Flow

If you prefer to run steps yourself:

### macOS

```bash
brew bundle --file Brewfile
ansible-playbook -i ansible/inventory/localhost.yml ansible/site.yml
chezmoi init --apply --source "$PWD/chezmoi"
```

### Linux

```bash
ansible-playbook -i ansible/inventory/localhost.yml ansible/site.yml --ask-become-pass
chezmoi init --apply --source "$PWD/chezmoi"
```

## Sync Back Into The Repo

Use the sync script when you have changed your live setup and want to pull it back into this repo.

```bash
./scripts/sync-from-machine.sh
```

By default it syncs configs only:

- `~/.zshrc`
- `~/.config/kitty/kitty.conf`
- `~/.tmux.conf`
- `~/.config/starship.toml`
- `~/.config/nvim` or `~/.config/nvim-kickstart`

Optional flags:

- `./scripts/sync-from-machine.sh --brewfile`
- `./scripts/sync-from-machine.sh --wallpapers`
- `./scripts/sync-from-machine.sh --all`

This is conservative on purpose:

- config sync is safe to do often
- `Brewfile` export is optional because it overwrites the curated package list with the current machine snapshot
- wallpaper sync is optional because it mirrors `~/Pictures/Wallpapers` into the repo

## Linux Notes

- Package automation is implemented for Arch/CachyOS style systems first.
- On other Linux distros, this repo still applies dotfiles cleanly, but you should add the distro-specific package task block before relying on Ansible for package install.

## Assets

- Keep wallpapers curated rather than mirroring all of `~/Pictures`.
- If your source images live in `~/Pictures/Wallpapers`, copy only the ones you actually want into `assets/wallpapers/`.
- This repo currently tracks the wallpaper set copied from `~/Pictures/Wallpapers`.
- The default repo wallpaper is `TahoeDay.png`. Override it with `BOOTSTRAP_WALLPAPER`.

## macOS Defaults

The current macOS defaults script keeps to a small baseline:

- show all filename extensions
- disable press-and-hold so key repeat works normally
- use faster key repeat
- auto-hide the Dock
- hide recent apps in the Dock
- show Finder path bar
- show Finder status bar

## Next Extensions

Add these only when you actually need them:

- extra Ansible roles for desktop, fonts, or GUI apps
- distro-specific package blocks beyond Arch
- machine-specific `chezmoi` templates if a config truly diverges by host
- pruning `Brewfile` down to the packages you want on every Mac

## Keeping It Modular

Keep the repo modular by putting each concern in the smallest obvious place:

- home-directory config files go in `chezmoi/`
- machine bootstrap goes in `ansible/`
- shared static files go in `assets/`
- one-off apply or sync actions go in `scripts/`

The practical rule is:

- if you add a new app config, add it under `chezmoi/`
- if you add packages or OS bootstrap logic, add it under `ansible/`
- if you add machine assets like wallpapers or themes, add them under `assets/`
- if you add a behavior like “apply X” or “sync X”, give it one focused script in `scripts/`

As the repo grows, split only when a file becomes crowded:

- split `ansible/roles/common` into `macos` and `linux` roles once the task file stops fitting in one sitting
- add subdirectories under `assets/` only when you have more than one asset type worth tracking
- add more scripts instead of turning `bootstrap.sh` into a giant all-purpose file
