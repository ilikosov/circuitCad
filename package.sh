#!/bin/bash
# Build the release zip for the Factorio mod portal / mods directory.
# Produces dist/compaktcircuit_<version>.zip with the required
# compaktcircuit_<version>/ top-level folder inside.
# Only files tracked by git are packaged, minus dev-only paths.
set -euo pipefail
cd "$(dirname "$0")"

NAME=$(python3 -c "import json; print(json.load(open('info.json'))['name'])")
VERSION=$(python3 -c "import json; print(json.load(open('info.json'))['version'])")
PKG="${NAME}_${VERSION}"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/$PKG" dist
git ls-files -z \
    | grep -zEv '^(\.claude/|\.vscode/|\.github/|\.gitignore|\.luacheckrc|\.luarc\.json|package\.sh|README\.md|CLAUDE\.md)' \
    | xargs -0 -I{} cp --parents {} "$STAGE/$PKG/"

rm -f "dist/$PKG.zip"
(cd "$STAGE" && zip -qr "$OLDPWD/dist/$PKG.zip" "$PKG")
echo "Built dist/$PKG.zip"
unzip -l "dist/$PKG.zip" | tail -1
