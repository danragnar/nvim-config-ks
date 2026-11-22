#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

if command -v yarn >/dev/null; then
  echo 'Run this smoke test with Yarn off PATH to exercise the npx fallback.' >&2
  exit 1
fi

nvim --version
node --version
npm --version
tree-sitter --version

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
export NVIM_APPNAME=nvim NVIM_LOG_FILE="$test_root/nvim.log"
export XDG_CONFIG_HOME="$test_root/config" XDG_DATA_HOME="$test_root/data"
export XDG_STATE_HOME="$test_root/state" XDG_CACHE_HOME="$test_root/cache"
export npm_config_cache="$test_root/npm"
unset VIMINIT EXINIT

mkdir -p "$XDG_CONFIG_HOME/nvim"
cp -R init.lua lua "$XDG_CONFIG_HOME/nvim/"
nvim --headless -i NONE --cmd 'luafile tests/smoke.lua'
