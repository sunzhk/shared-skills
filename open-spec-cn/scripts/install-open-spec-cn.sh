#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$PWD}"
updated_at="$(date "+%Y-%m-%d %H:%M:%S %z")"
generated_commands=0
generated_codex_skills=0

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

def append_cn_suffix(line: str) -> str:
    line = line.rstrip("\n")
    if not line.startswith("description:"):
        return line + "\n"
    value = line[len("description:"):].rstrip()
    if "(CN)" in value:
        return line + "\n"
    if value.endswith('"') or value.endswith("'"):
        quote = value[-1]
        value = value[:-1].rstrip() + " (CN)" + quote
    else:
        value = value + " (CN)"
    return "description:" + value + "\n"

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
                r'^(name:\s*["\']?/opsx-[^"\']*?)(["\']?)\s*$',
                lambda match: (match.group(1) + match.group(2)) if match.group(1).endswith("-cn") else (match.group(1) + "-cn" + match.group(2)),
                line.rstrip("\n"),
            ) + "\n"
            line = re.sub(
                r'^(id:\s*opsx-[^\s]+)\s*$',
                lambda match: match.group(1) if match.group(1).endswith("-cn") else match.group(1) + "-cn",
                line.rstrip("\n"),
            ) + "\n"
        elif mode == "codex-skills":
            line = re.sub(
                r'^(name:\s*["\']?openspec-[^"\']*?)(["\']?)\s*$',
                lambda match: (match.group(1) + match.group(2)) if match.group(1).endswith("-cn") else (match.group(1) + "-cn" + match.group(2)),
                line.rstrip("\n"),
            ) + "\n"

        line = append_cn_suffix(line)

    output.append(line)

if frontmatter_delimiters < 2:
    pass

with open(target_file, "w", encoding="utf-8") as file_handle:
    file_handle.writelines(output)
PYEOF
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

if [[ -n "${OPSX_COMMANDS_DIR:-}" ]]; then
  if [[ -d "$OPSX_COMMANDS_DIR" ]] && has_codex_openspec_skills "$OPSX_COMMANDS_DIR"; then
    run_mode="codex-skills"
    target_path="$OPSX_COMMANDS_DIR"
    resolution_detail="OPSX_COMMANDS_DIR(codex skills)"
  else
    run_mode="commands"
    target_path="$OPSX_COMMANDS_DIR"
    resolution_detail="OPSX_COMMANDS_DIR(commands)"
  fi
elif [[ -d "$project_root/.claude/commands/opsx" || -d "$project_root/.claude/commands" ]]; then
  run_mode="commands"
  target_path="$project_root/.claude/commands"
  resolution_detail=".claude/commands (opsx namespace supported)"
elif [[ -d "$project_root/.codex/commands" ]]; then
  run_mode="commands"
  target_path="$project_root/.codex/commands"
  resolution_detail=".codex/commands"
elif [[ -d "$project_root/.codex/skills" ]] && has_codex_openspec_skills "$project_root/.codex/skills"; then
  run_mode="codex-skills"
  target_path="$project_root/.codex/skills"
  resolution_detail=".codex/skills"
else
  run_mode="commands"
  target_path="$project_root/.claude/commands/opsx"
  resolution_detail="fallback create .claude/commands/opsx"
fi

if [[ "$run_mode" == "commands" ]]; then
  mkdir -p "$target_path"
  generate_cn_command_files "$target_path"
  echo "[open-spec-cn] mode: commands"
  echo "[open-spec-cn] generated cn slash commands: $generated_commands"
  echo "[open-spec-cn] output directory: $target_path"
else
  mkdir -p "$target_path"
  generate_cn_codex_skills "$target_path"
  echo "[open-spec-cn] mode: codex-skills"
  echo "[open-spec-cn] generated cn codex skills: $generated_codex_skills"
  echo "[open-spec-cn] output directory: $target_path"
fi

echo "[open-spec-cn] directory resolution: OPSX_COMMANDS_DIR > .claude/commands(/opsx) > .codex/commands > .codex/skills"
echo "[open-spec-cn] selected: $resolution_detail"
echo "[open-spec-cn] done. no terminal wrapper commands are installed."
