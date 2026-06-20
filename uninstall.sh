#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Removing symlinks ..."
stow -D */

echo "Done. Local overrides and installed packages were not removed."