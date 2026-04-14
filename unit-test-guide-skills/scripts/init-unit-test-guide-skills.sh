#!/bin/bash
set -euo pipefail

skill_name="unit-test-guide-skills"
use_claude=0
use_codex=0

usage() {
  cat <<'EOF' >&2
用法:
  bash /path/to/unit-test-guide-skills/scripts/init-unit-test-guide-skills.sh [target_project_root]
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
    echo "- Skill path (Claude): \`.claude/shared-skills/unit-test-guide-skills/SKILL.md\`"
  fi
  if [[ "$use_codex" -eq 1 ]]; then
    echo "- Skill path (Codex): \`.codex/shared-skills/unit-test-guide-skills/SKILL.md\`"
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
## Shared Skill: \`unit-test-guide-skills\`（由 \`/unit-test-guide-skills init\` 生成）

${skill_path_lines}
- Detected targets: ${target_label}.
- Use when the user asks for unit-test standards, platform-specific testing strategy, mock/fake choices, layering, or coverage guidance.
- Subcommand \`init\`: create or refresh this section in \`AGENTS.md\`.
- Default action: delegate to \`unit-test-guide-skills/unit-test-router/SKILL.md\`, then route to Android, iOS, or WeChat Mini Program guidance.
- Priority: project test rules > this skill > official platform testing guidance > personal preference.
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
