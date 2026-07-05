#!/bin/bash
# SessionStart hook: install luacheck so `luacheck .` works in
# Claude Code on the web sessions. Idempotent; web-only.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if command -v luacheck >/dev/null 2>&1; then
  exit 0
fi

# Debian/Ubuntu package the luacheck binary as "lua-check"
apt-get install -y lua-check >/dev/null 2>&1 || {
  apt-get update -qq || true
  apt-get install -y lua-check >/dev/null
}

luacheck --version
