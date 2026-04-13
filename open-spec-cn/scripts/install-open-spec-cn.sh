#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$PWD}"
default_commands_dir="$project_root/.claude/commands"

if [[ -n "${OPSX_COMMANDS_DIR:-}" ]]; then
  commands_dir="$OPSX_COMMANDS_DIR"
elif [[ -d "$project_root/.claude/commands" ]]; then
  commands_dir="$project_root/.claude/commands"
elif [[ -d "$project_root/.codex/commands" ]]; then
  commands_dir="$project_root/.codex/commands"
else
  commands_dir="$default_commands_dir"
fi

mkdir -p "$commands_dir"

updated_at="$(date "+%Y-%m-%d %H:%M:%S %z")"
generated_count=0

for src in "$commands_dir"/opsx-*.md; do
  if [[ ! -f "$src" ]]; then
    continue
  fi
  if [[ "$src" == *"-cn.md" ]]; then
    continue
  fi

  base_name="$(basename "$src" .md)"
  target="$commands_dir/${base_name}-cn.md"

  awk -v updated_at="$updated_at" '
    BEGIN {
      in_frontmatter = 0
      frontmatter_done = 0
    }
    /^---[[:space:]]*$/ {
      print
      if (frontmatter_done == 0) {
        if (in_frontmatter == 0) {
          in_frontmatter = 1
        } else {
          in_frontmatter = 0
          frontmatter_done = 1
          print ""
          print "<!--"
          print "更新时间: " updated_at
          print "最近更新: 通过 open-spec-cn 初始化脚本自动生成 -cn 版本命令文件。"
          print "-->"
          print ""
        }
      }
      next
    }
    {
      if (in_frontmatter == 1) {
        if ($0 ~ /^name:[[:space:]]*\/opsx-[^[:space:]]+$/ && $0 !~ /-cn$/) {
          sub(/$/, "-cn")
        } else if ($0 ~ /^id:[[:space:]]*opsx-[^[:space:]]+$/ && $0 !~ /-cn$/) {
          sub(/$/, "-cn")
        } else if ($0 ~ /^description:[[:space:]]*/ && $0 !~ /\(CN\)$/) {
          $0 = $0 " (CN)"
        }
      }
      print
    }
  ' "$src" > "$target"

  generated_count=$((generated_count + 1))
done

echo "[open-spec-cn] generated cn slash commands: $generated_count"
echo "[open-spec-cn] output directory: $commands_dir"
echo "[open-spec-cn] directory resolution: OPSX_COMMANDS_DIR > .claude/commands > .codex/commands"
echo "[open-spec-cn] done. no terminal wrapper commands are installed."
