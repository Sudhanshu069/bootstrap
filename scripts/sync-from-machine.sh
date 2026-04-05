#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

SYNC_CONFIGS=true
SYNC_BREWFILE=false
SYNC_WALLPAPERS=false

usage() {
  cat <<'EOF'
Usage: ./scripts/sync-from-machine.sh [--configs] [--brewfile] [--wallpapers] [--all]

Sync current machine state back into this repo.

Defaults:
  --configs      Sync shell/app configs into chezmoi (default)

Optional:
  --brewfile     Export current Homebrew state into Brewfile
  --wallpapers   Copy ~/Pictures/Wallpapers into assets/wallpapers
  --all          Sync configs, Brewfile, and wallpapers
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --configs)
      SYNC_CONFIGS=true
      ;;
    --brewfile)
      SYNC_BREWFILE=true
      ;;
    --wallpapers)
      SYNC_WALLPAPERS=true
      ;;
    --all)
      SYNC_CONFIGS=true
      SYNC_BREWFILE=true
      SYNC_WALLPAPERS=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

copy_if_exists() {
  local source_path="$1"
  local target_path="$2"

  if [ ! -e "${source_path}" ]; then
    echo "Skipping missing path: ${source_path}"
    return 0
  fi

  mkdir -p "$(dirname "${target_path}")"
  cp "${source_path}" "${target_path}"
}

sync_configs() {
  copy_if_exists "${HOME}/.zshrc" "${ROOT_DIR}/chezmoi/dot_zshrc"
  copy_if_exists "${HOME}/.config/kitty/kitty.conf" "${ROOT_DIR}/chezmoi/dot_config/kitty/kitty.conf"
  copy_if_exists "${HOME}/.config/kitty/themes.conf" "${ROOT_DIR}/chezmoi/dot_config/kitty/themes.conf"
  copy_if_exists "${HOME}/.config/kitty/current-theme.conf" "${ROOT_DIR}/chezmoi/dot_config/kitty/current-theme.conf"
  copy_if_exists "${HOME}/.config/kitty/overrides.conf" "${ROOT_DIR}/chezmoi/dot_config/kitty/overrides.conf"
  copy_if_exists "${HOME}/.tmux.conf" "${ROOT_DIR}/chezmoi/dot_tmux.conf"
  copy_if_exists "${HOME}/.config/starship.toml" "${ROOT_DIR}/chezmoi/dot_config/starship.toml"

  local nvim_source=""
  if [ -d "${HOME}/.config/nvim" ]; then
    nvim_source="${HOME}/.config/nvim"
  elif [ -d "${HOME}/.config/nvim-kickstart" ]; then
    nvim_source="${HOME}/.config/nvim-kickstart"
  fi

  if [ -n "${nvim_source}" ]; then
    mkdir -p "${ROOT_DIR}/chezmoi/dot_config/nvim"
    rsync -a --delete \
      --exclude='.git' \
      --exclude='.github' \
      --exclude='README.md' \
      --exclude='LICENSE.md' \
      --exclude='doc' \
      --exclude='.gitignore' \
      "${nvim_source}/" "${ROOT_DIR}/chezmoi/dot_config/nvim/"
  else
    echo "Skipping missing Neovim config: ~/.config/nvim or ~/.config/nvim-kickstart"
  fi
}

sync_brewfile() {
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Skipping Brewfile export on non-macOS."
    return 0
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "Skipping Brewfile export because Homebrew is not installed."
    return 0
  fi

  brew bundle dump --file "${ROOT_DIR}/Brewfile" --force
}

sync_wallpapers() {
  local wallpaper_source="${HOME}/Pictures/Wallpapers"
  local wallpaper_target="${ROOT_DIR}/assets/wallpapers"

  if [ ! -d "${wallpaper_source}" ]; then
    echo "Skipping missing wallpaper source: ${wallpaper_source}"
    return 0
  fi

  mkdir -p "${wallpaper_target}"
  rsync -a --delete --exclude='.gitkeep' "${wallpaper_source}/" "${wallpaper_target}/"
}

if [ "${SYNC_CONFIGS}" = true ]; then
  sync_configs
fi

if [ "${SYNC_BREWFILE}" = true ]; then
  sync_brewfile
fi

if [ "${SYNC_WALLPAPERS}" = true ]; then
  sync_wallpapers
fi

echo "Sync complete."
