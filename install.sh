#!/usr/bin/env bash
# Kept for muscle memory and README compatibility. The real logic lives in bin/dotfiles.
exec "$(cd "$(dirname "$0")" && pwd)/bin/dotfiles" install "$@"
