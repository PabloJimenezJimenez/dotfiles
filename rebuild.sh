#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
if [ "$(uname -s)" = "Darwin" ]; then
  exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
fi
# Non-NixOS Linux (Ubuntu/WSL): home-manager standalone. No sudo - it would
# install into root's profile instead of yours.
if command -v home-manager >/dev/null 2>&1; then
  exec home-manager switch --flake ~/.dotfiles#linux
fi
# First run before home-manager landed on PATH: use the pinned upstream tool.
exec nix run github:nix-community/home-manager/release-26.05#home-manager -- \
  switch --flake ~/.dotfiles#linux
