#!/bin/bash
set -euo pipefail

skill_name="open-spec-cn"
use_claude=0
use_codex=0

usage() {
  cat <<'EOF' >&2
用法:
  bash /path/to/open-spec-cn/scripts/init-open-spec-cn.sh [target_project_root]
EOF
}

check_args() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -gt 1 ]]; then
    usage
    [[ $# -gt 1 ]] && exit 2
    exit 0
  fi
}

resolve_paths() {
  local root="${1:-$PWD}"
  target_root="$(cd "${root}" && pwd)"
  agents_md="${target_root}/AGENTS.md"
}

detect_supported_targets() {
  if [[ -d "${target_root}/.claude" || -d "${target_root}/.claude/commands" || -d "${target_root}/.claude/shared-skills" ]]; then
    use_claude=1
  fi

  if [[ -d "${target_root}/.codex" || -d "${target_root}/.codex/commands" || -d "${target_root}/.codex/skills" || -d "${target_root}/.codex/prompts" || -d "${target_root}/.codex/shared-skills" ]]; then
    use_codex=1
  fi

  if [[ "$use_claude" -eq 0 && "$use_codex" -eq 0 ]]; then
    use_claude=1
    use_codex=1
    echo "[${skill_name}] 未检测到 .claude/.codex 目录，回退为 Claude + Codex 双 target 初始化。" >&2
  fi
}

build_skill_path_lines() {
  if [[ "$use_claude" -eq 1 ]]; then
    echo "- Skill path (Claude): \`.claude/shared-skills/open-spec-cn/SKILL.md\`"
  fi
  if [[ "$use_codex" -eq 1 ]]; then
    echo "- Skill path (Codex): \`.codex/shared-skills/open-spec-cn/SKILL.md\`"
  fi
}

build_target_label() {
  if [[ "$use_claude" -eq 1 && "$use_codex" -eq 1 ]]; then
    echo "Claude + Codex"
  elif [[ "$use_claude" -eq 1 ]]; then
    echo "Claude"
  else
    echo "Codex"
  fi
}

build_section() {
  local skill_path_lines
  local target_label
  skill_path_lines="$(build_skill_path_lines)"
  target_label="$(build_target_label)"

  cat <<EOF
## Shared Skill: \`open-spec-cn\`（由 \`/open-spec-cn init\` 生成）

${skill_path_lines}
- Detected targets: ${target_label}.
- Use when the user asks for OpenSpec Chinese writing rules, \`MUST/SHALL\` requirement enforcement, or \`/opsx-*-cn\` command generation.
- Subcommand \`init\`: create or refresh this section in \`AGENTS.md\`.
- Subcommand \`commands-init\`: run \`open-spec-cn/scripts/install-open-spec-cn.sh\` to generate \`-cn\` commands/skills/prompts in the project (add \`--all-targets\` to initialize Claude + Codex together, including Codex prompts).
- Default action: apply Chinese OpenSpec rules, keep \`Purpose\` free of \`TBD\`, and make validation steps explicit.
- Command resolution for \`commands-init\`: \`OPSX_COMMANDS_DIR\` > \`.claude/commands(/opsx)\` > \`.codex/commands\` > \`.codex/skills\`; Codex prompts via \`OPSX_PROMPTS_DIR\` (or \`--codex-prompts\` / \`--all-targets\`).
EOF
}

upsert_section() {
  local section="$1"
  local section_marker
  section_marker="$(printf '%s\n' "${section}" | sed -n '1p')"

  if [[ ! -f "${agents_md}" ]]; then
    printf '%s\n' "${section}" > "${agents_md}"
    echo "[${skill_name}] 已创建 AGENTS.md 并写入 ${skill_name} 说明: ${agents_md}" >&2
    return 0
  fi

  if grep -qF "${section_marker}" "${agents_md}"; then
    python3 - "${agents_md}" "${section_marker}" "${section}" <<'PYEOF'
import re
import sys

path = sys.argv[1]
marker = sys.argv[2]
new_section = sys.argv[3]
text = open(path, 'r', encoding='utf-8').read()
pattern = re.compile(r'(^|\n)' + re.escape(marker) + r'.*?(?=\n## |\Z)', re.DOTALL)
replaced = pattern.sub(lambda m: (('\n' if m.group(1) == '\n' else '') + new_section), text)
open(path, 'w', encoding='utf-8').write(replaced)
PYEOF
    echo "[${skill_name}] 已更新 AGENTS.md 中的 ${skill_name} 说明: ${agents_md}" >&2
  else
    {
      printf '\n'
      printf '%s\n' "${section}"
    } >> "${agents_md}"
    echo "[${skill_name}] 已追加 ${skill_name} 说明到 AGENTS.md: ${agents_md}" >&2
  fi
}

main() {
  check_args "$@"
  resolve_paths "${1:-}"
  detect_supported_targets
  upsert_section "$(build_section)"
}

main "$@"
