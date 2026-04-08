#!/usr/bin/env bash
set -euo pipefail

if ! command -v openspec >/dev/null 2>&1; then
  echo "[open-spec-cn] openspec not found in PATH."
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard_script="$script_dir/openspec-cn-guard.sh"

cmd="${1:-}"
shift || true

if [[ -z "$cmd" ]]; then
  echo "usage: openspec-cn-run.sh <openspec-top-command> [args...]"
  exit 2
fi

run_archive() {
  local change_name="${1:-}"
  if [[ -z "$change_name" ]]; then
    echo "[open-spec-cn] archive requires change name."
    exit 2
  fi
  shift || true

  "$guard_script" --change "$change_name"
  openspec archive "$change_name" --no-interactive "$@"
  "$guard_script" --main-specs
}

case "$cmd" in
  archive)
    run_archive "$@"
    ;;
  *)
    openspec "$cmd" "$@"
    ;;
esac
