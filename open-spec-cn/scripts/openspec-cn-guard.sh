#!/usr/bin/env bash
set -euo pipefail

# 用法：
# 1) openspec-cn-guard.sh --change <change-name>
# 2) openspec-cn-guard.sh --main-specs

mode="${1:-}"

require_keywords() {
  local target_dir="$1"
  local failed=0

  if [[ ! -d "$target_dir" ]]; then
    echo "[open-spec-cn] skip: directory not found -> $target_dir"
    return 0
  fi

  while IFS= read -r spec_file; do
    if ! rg -q "MUST|SHALL" "$spec_file"; then
      echo "[open-spec-cn] FAIL: missing MUST/SHALL -> $spec_file"
      failed=1
    fi
    if rg -q "TBD - created by archiving|^TBD$" "$spec_file"; then
      echo "[open-spec-cn] FAIL: contains TBD placeholder -> $spec_file"
      failed=1
    fi
  done < <(rg --files "$target_dir" -g "**/spec.md")

  if [[ $failed -ne 0 ]]; then
    echo "[open-spec-cn] validation failed."
    return 1
  fi

  echo "[open-spec-cn] validation passed for: $target_dir"
}

case "$mode" in
  --change)
    change_name="${2:-}"
    if [[ -z "$change_name" ]]; then
      echo "usage: $0 --change <change-name>"
      exit 2
    fi
    require_keywords "openspec/changes/$change_name/specs"
    ;;
  --main-specs)
    require_keywords "openspec/specs"
    ;;
  *)
    echo "usage: $0 --change <change-name> | --main-specs"
    exit 2
    ;;
esac
