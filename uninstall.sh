#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Removing symlinks ..."
packages=(*/)
stow -D "${packages[@]%/}"

echo "Done. Local overrides and installed packages were not removed."