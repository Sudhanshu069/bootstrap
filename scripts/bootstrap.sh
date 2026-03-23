#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

install_macos_prereqs() {
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  brew install ansible chezmoi

  if [ -f "${ROOT_DIR}/Brewfile" ]; then
    brew bundle --file "${ROOT_DIR}/Brewfile"
  fi
}

install_linux_prereqs() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "This starter bootstrap script currently supports pacman-based Linux only."
    echo "Install ansible and chezmoi manually, then run the commands in README.md."
    exit 1
  fi

  sudo pacman -Sy --needed ansible chezmoi
}

run_ansible() {
  if [ "$(uname -s)" = "Darwin" ]; then
    ansible-playbook -i "${ROOT_DIR}/ansible/inventory/localhost.yml" "${ROOT_DIR}/ansible/site.yml"
  else
    ansible-playbook -i "${ROOT_DIR}/ansible/inventory/localhost.yml" "${ROOT_DIR}/ansible/site.yml" --ask-become-pass
  fi
}

apply_chezmoi() {
  chezmoi init --apply --source "${ROOT_DIR}/chezmoi"
}

apply_wallpaper() {
  if [ -x "${ROOT_DIR}/scripts/apply-wallpaper.sh" ]; then
    "${ROOT_DIR}/scripts/apply-wallpaper.sh" || true
  fi
}

apply_macos_defaults() {
  if [ "$(uname -s)" = "Darwin" ] && [ -x "${ROOT_DIR}/scripts/macos-defaults.sh" ]; then
    "${ROOT_DIR}/scripts/macos-defaults.sh" || true
  fi
}

case "$(uname -s)" in
  Darwin)
    install_macos_prereqs
    ;;
  Linux)
    install_linux_prereqs
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

run_ansible
apply_chezmoi
apply_wallpaper
apply_macos_defaults
