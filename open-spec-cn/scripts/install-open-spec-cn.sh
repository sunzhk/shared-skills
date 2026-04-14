#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
用法:
  bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh [--all-targets] [project-root]

参数:
  --all-targets  同时初始化所有可用目标（Claude 与 Codex）
  -h, --help     显示帮助
EOF
}

all_targets=0
positionals=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all-targets)
      all_targets=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "[open-spec-cn] unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      positionals+=("$1")
      shift
      ;;
  esac
done

if [[ ${#positionals[@]} -gt 1 ]]; then
  usage
  exit 2
fi

project_root="${positionals[0]:-$PWD}"
updated_at="$(date "+%Y-%m-%d %H:%M:%S %z")"
generated_commands=0
generated_codex_skills=0
target_modes=()
target_paths=()
target_details=()

has_codex_openspec_skills() {
  local skills_dir="$1"
  find "$skills_dir" -maxdepth 1 -type d -name "openspec-*" ! -name "*-cn" | grep -q .
}

transform_markdown() {
  local source_file="$1"
  local target_file="$2"
  local mode="$3"

  python3 - "$source_file" "$target_file" "$mode" "$updated_at" <<'PYEOF'
import re
import sys

source_file, target_file, mode, updated_at = sys.argv[1:5]

with open(source_file, "r", encoding="utf-8") as file_handle:
    lines = file_handle.readlines()

in_frontmatter = False
frontmatter_done = False
frontmatter_delimiters = 0
output = []
inserted_comment = False

def append_cn_suffix(line: str, field_name: str) -> str:
    line = line.rstrip("\n")
    field_prefix = f"{field_name}:"
    if not line.startswith(field_prefix):
        return line + "\n"
    value = line[len(field_prefix):].rstrip()
    if "(CN)" in value:
        return line + "\n"
    if value.endswith('"') or value.endswith("'"):
        quote = value[-1]
        value = value[:-1].rstrip() + " (CN)" + quote
    else:
        value = value + " (CN)"
    return field_prefix + value + "\n"

for line in lines:
    if re.match(r"^---\s*$", line):
        output.append(line)
        if not frontmatter_done:
            if not in_frontmatter:
                in_frontmatter = True
                frontmatter_delimiters += 1
            else:
                in_frontmatter = False
                frontmatter_done = True
                frontmatter_delimiters += 1
                if not inserted_comment:
                    output.extend([
                        "\n",
                        "<!--\n",
                        f"更新时间: {updated_at}\n",
                        "最近更新: 通过 open-spec-cn 初始化脚本自动生成 -cn 版本命令文件。\n",
                        "-->\n",
                        "\n",
                    ])
                    inserted_comment = True
        continue

    if in_frontmatter:
        if mode == "commands":
            line = re.sub(
                r'^(id:\s*opsx-[^\s]+)\s*$',
                lambda match: match.group(1) if match.group(1).endswith("-cn") else match.group(1) + "-cn",
                line.rstrip("\n"),
            ) + "\n"
            line = append_cn_suffix(line, "name")
        elif mode == "codex-skills":
            line = re.sub(
                r'^(name:\s*["\']?openspec-[^"\']*?)(["\']?)\s*$',
                lambda match: (match.group(1) + match.group(2)) if match.group(1).endswith("-cn") else (match.group(1) + "-cn" + match.group(2)),
                line.rstrip("\n"),
            ) + "\n"

        line = append_cn_suffix(line, "description")

    output.append(line)

if frontmatter_delimiters < 2:
    pass

with open(target_file, "w", encoding="utf-8") as file_handle:
    file_handle.writelines(output)
PYEOF
}

add_target() {
  local mode="$1"
  local path="$2"
  local detail="$3"
  local idx
  for idx in "${!target_paths[@]}"; do
    if [[ "${target_modes[$idx]}" == "$mode" && "${target_paths[$idx]}" == "$path" ]]; then
      return 0
    fi
  done
  target_modes+=("$mode")
  target_paths+=("$path")
  target_details+=("$detail")
}

generate_cn_command_files() {
  local root_dir="$1"
  local source_list
  source_list="$(
    {
      if [[ -d "$root_dir" ]]; then
        if [[ "$(basename "$root_dir")" == "opsx" ]]; then
          find "$root_dir" -maxdepth 1 -type f -name "*.md"
        else
          find "$root_dir" -maxdepth 1 -type f -name "opsx-*.md"
          if [[ -d "$root_dir/opsx" ]]; then
            find "$root_dir/opsx" -maxdepth 1 -type f -name "*.md"
          fi
        fi
      fi
    } | sort -u
  )"

  while IFS= read -r src; do
    if [[ -z "$src" || ! -f "$src" ]]; then
      continue
    fi
    if [[ "$src" == *"-cn.md" ]]; then
      continue
    fi
    local base_name
    local target
    base_name="$(basename "$src" .md)"
    target="$(dirname "$src")/${base_name}-cn.md"
    transform_markdown "$src" "$target" "commands"
    generated_commands=$((generated_commands + 1))
  done <<< "$source_list"
}

generate_cn_codex_skills() {
  local skills_dir="$1"
  for src_dir in "$skills_dir"/openspec-*; do
    if [[ ! -d "$src_dir" ]]; then
      continue
    fi
    if [[ "$src_dir" == *"-cn" ]]; then
      continue
    fi

    local target_dir="${src_dir}-cn"
    rm -rf "$target_dir"
    cp -R "$src_dir" "$target_dir"

    local skill_file="$target_dir/SKILL.md"
    if [[ -f "$skill_file" ]]; then
      transform_markdown "$skill_file" "$skill_file" "codex-skills"
      generated_codex_skills=$((generated_codex_skills + 1))
    fi
  done
}

resolve_single_target() {
  if [[ -n "${OPSX_COMMANDS_DIR:-}" ]]; then
    if [[ -d "$OPSX_COMMANDS_DIR" ]] && has_codex_openspec_skills "$OPSX_COMMANDS_DIR"; then
      add_target "codex-skills" "$OPSX_COMMANDS_DIR" "OPSX_COMMANDS_DIR(codex skills)"
    else
      add_target "commands" "$OPSX_COMMANDS_DIR" "OPSX_COMMANDS_DIR(commands)"
    fi
  elif [[ -d "$project_root/.claude/commands/opsx" || -d "$project_root/.claude/commands" ]]; then
    add_target "commands" "$project_root/.claude/commands" ".claude/commands (opsx namespace supported)"
  elif [[ -d "$project_root/.codex/commands" ]]; then
    add_target "commands" "$project_root/.codex/commands" ".codex/commands"
  elif [[ -d "$project_root/.codex/skills" ]] && has_codex_openspec_skills "$project_root/.codex/skills"; then
    add_target "codex-skills" "$project_root/.codex/skills" ".codex/skills"
  else
    add_target "commands" "$project_root/.claude/commands/opsx" "fallback create .claude/commands/opsx"
  fi
}

resolve_all_targets() {
  if [[ -n "${OPSX_COMMANDS_DIR:-}" ]]; then
    if [[ -d "$OPSX_COMMANDS_DIR" ]] && has_codex_openspec_skills "$OPSX_COMMANDS_DIR"; then
      add_target "codex-skills" "$OPSX_COMMANDS_DIR" "OPSX_COMMANDS_DIR(codex skills)"
    else
      add_target "commands" "$OPSX_COMMANDS_DIR" "OPSX_COMMANDS_DIR(commands)"
    fi
  fi

  if [[ -d "$project_root/.claude/commands/opsx" || -d "$project_root/.claude/commands" ]]; then
    add_target "commands" "$project_root/.claude/commands" ".claude/commands (opsx namespace supported)"
  else
    add_target "commands" "$project_root/.claude/commands/opsx" "fallback create .claude/commands/opsx"
  fi

  if [[ -d "$project_root/.codex/commands" ]]; then
    add_target "commands" "$project_root/.codex/commands" ".codex/commands"
  fi

  if [[ -d "$project_root/.codex/skills" ]] && has_codex_openspec_skills "$project_root/.codex/skills"; then
    add_target "codex-skills" "$project_root/.codex/skills" ".codex/skills"
  fi
}

if [[ "$all_targets" -eq 1 ]]; then
  resolve_all_targets
else
  resolve_single_target
fi

for idx in "${!target_modes[@]}"; do
  mode="${target_modes[$idx]}"
  path="${target_paths[$idx]}"
  detail="${target_details[$idx]}"

  before_commands="$generated_commands"
  before_codex_skills="$generated_codex_skills"

  mkdir -p "$path"
  if [[ "$mode" == "commands" ]]; then
    generate_cn_command_files "$path"
  else
    generate_cn_codex_skills "$path"
  fi

  delta_commands=$((generated_commands - before_commands))
  delta_codex_skills=$((generated_codex_skills - before_codex_skills))
  echo "[open-spec-cn] target: $detail"
  echo "[open-spec-cn] mode: $mode"
  echo "[open-spec-cn] generated in target: commands=$delta_commands, codex_skills=$delta_codex_skills"
  echo "[open-spec-cn] output directory: $path"
done

echo "[open-spec-cn] directory resolution: OPSX_COMMANDS_DIR > .claude/commands(/opsx) > .codex/commands > .codex/skills"
if [[ "$all_targets" -eq 1 ]]; then
  echo "[open-spec-cn] selected: --all-targets (${#target_modes[@]} targets)"
else
  echo "[open-spec-cn] selected: ${target_details[0]}"
fi
echo "[open-spec-cn] generated cn slash commands: $generated_commands"
echo "[open-spec-cn] generated cn codex skills: $generated_codex_skills"
echo "[open-spec-cn] done. no terminal wrapper commands are installed."
