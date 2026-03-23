#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPER_DIR="${ROOT_DIR}/assets/wallpapers"
DEFAULT_WALLPAPER="TahoeDay.png"

pick_wallpaper() {
  local requested="${1:-${BOOTSTRAP_WALLPAPER:-${DEFAULT_WALLPAPER}}}"

  if [ -f "${requested}" ]; then
    printf '%s\n' "${requested}"
    return 0
  fi

  if [ -f "${WALLPAPER_DIR}/${requested}" ]; then
    printf '%s\n' "${WALLPAPER_DIR}/${requested}"
    return 0
  fi

  local first_wallpaper
  first_wallpaper="$(find "${WALLPAPER_DIR}" -maxdepth 1 -type f ! -name '.gitkeep' | sort | head -n 1)"
  if [ -n "${first_wallpaper}" ]; then
    printf '%s\n' "${first_wallpaper}"
    return 0
  fi

  return 1
}

apply_macos_wallpaper() {
  local wallpaper="$1"

  osascript <<EOF
tell application "System Events"
  tell every desktop
    set picture to "${wallpaper}"
  end tell
end tell
EOF
}

apply_gsettings_wallpaper() {
  local wallpaper_uri="file://$1"

  if gsettings writable org.gnome.desktop.background picture-uri >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.background picture-uri "${wallpaper_uri}"
    gsettings set org.gnome.desktop.background picture-uri-dark "${wallpaper_uri}" >/dev/null 2>&1 || true
    return 0
  fi

  if gsettings writable org.cinnamon.desktop.background picture-uri >/dev/null 2>&1; then
    gsettings set org.cinnamon.desktop.background picture-uri "${wallpaper_uri}"
    return 0
  fi

  return 1
}

apply_linux_wallpaper() {
  local wallpaper="$1"

  if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    plasma-apply-wallpaperimage "${wallpaper}" >/dev/null 2>&1
    return 0
  fi

  if command -v gsettings >/dev/null 2>&1 && apply_gsettings_wallpaper "${wallpaper}"; then
    return 0
  fi

  echo "No supported Linux wallpaper backend found. Supported backends: KDE Plasma, GNOME, Cinnamon."
  return 1
}

main() {
  local wallpaper
  wallpaper="$(pick_wallpaper "${1:-}")" || {
    echo "No wallpaper files found in ${WALLPAPER_DIR}."
    exit 1
  }

  case "$(uname -s)" in
    Darwin)
      apply_macos_wallpaper "${wallpaper}"
      ;;
    Linux)
      apply_linux_wallpaper "${wallpaper}"
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)"
      exit 1
      ;;
  esac

  printf 'Applied wallpaper: %s\n' "${wallpaper}"
}

main "$@"
