#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
用法:
  bash /path/to/shared-skills/scripts/init-shared-skill.sh <skill-id> [target_project_root]

支持的 skill-id:
  eng-practices
  code-styleguide-skills
  unit-test-guide-skills
  open-spec-cn
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 || $# -gt 2 ]]; then
  usage
  [[ $# -ge 1 ]] && [[ "${1:-}" != "-h" && "${1:-}" != "--help" ]] && exit 2
  exit 0
fi

skill_id="$1"
target_root="${2:-$PWD}"
target_root="$(cd "${target_root}" && pwd)"
agents_md="${target_root}/AGENTS.md"

build_section() {
  case "$1" in
    eng-practices)
      cat <<'EOF'
## Shared Skill: `eng-practices`（由 `/eng-practices init` 生成）

- Skill path (Claude): `.claude/shared-skills/eng-practices/SKILL.md`
- Skill path (Codex): `.codex/shared-skills/eng-practices/SKILL.md`
- Use when the user asks for PR/CL review strategy, review wording, Required/Nit/Optional/FYI grading, conflict handling, small CL splitting, or review acceleration.
- Subcommand `init`: create or refresh this section in `AGENTS.md`.
- Default action: apply the `eng-practices` review workflow directly and keep conclusions actionable.
- Priority: project review rules > this skill > official guidance > personal preference.
EOF
      ;;
    code-styleguide-skills)
      cat <<'EOF'
## Shared Skill: `code-styleguide-skills`（由 `/code-styleguide-skills init` 生成）

- Skill path (Claude): `.claude/shared-skills/code-styleguide-skills/SKILL.md`
- Skill path (Codex): `.codex/shared-skills/code-styleguide-skills/SKILL.md`
- Use when the user asks for code style consistency, naming, comments, readability, or language-specific style checks.
- Subcommand `init`: create or refresh this section in `AGENTS.md`.
- Default action: delegate to `code-styleguide-skills/styleguide-router/SKILL.md`, then route to the matching `styleguide-*` sub-skill.
- Priority: project style rules > this skill > official language style guides > personal preference.
EOF
      ;;
    unit-test-guide-skills)
      cat <<'EOF'
## Shared Skill: `unit-test-guide-skills`（由 `/unit-test-guide-skills init` 生成）

- Skill path (Claude): `.claude/shared-skills/unit-test-guide-skills/SKILL.md`
- Skill path (Codex): `.codex/shared-skills/unit-test-guide-skills/SKILL.md`
- Use when the user asks for unit-test standards, platform-specific testing strategy, mock/fake choices, layering, or coverage guidance.
- Subcommand `init`: create or refresh this section in `AGENTS.md`.
- Default action: delegate to `unit-test-guide-skills/unit-test-router/SKILL.md`, then route to Android, iOS, or WeChat Mini Program guidance.
- Priority: project test rules > this skill > official platform testing guidance > personal preference.
EOF
      ;;
    open-spec-cn)
      cat <<'EOF'
## Shared Skill: `open-spec-cn`（由 `/open-spec-cn init` 生成）

- Skill path (Claude): `.claude/shared-skills/open-spec-cn/SKILL.md`
- Skill path (Codex): `.codex/shared-skills/open-spec-cn/SKILL.md`
- Use when the user asks for OpenSpec Chinese writing rules, `MUST/SHALL` requirement enforcement, or `/opsx-*-cn` command generation.
- Subcommand `init`: create or refresh this section in `AGENTS.md`.
- Subcommand `commands-init`: run `open-spec-cn/scripts/install-open-spec-cn.sh` to generate `/opsx-*-cn` command files in the project.
- Default action: apply Chinese OpenSpec rules, keep `Purpose` free of `TBD`, and make validation steps explicit.
- Command directory priority for `commands-init`: `OPSX_COMMANDS_DIR` > `.claude/commands` > `.codex/commands`.
EOF
      ;;
    *)
      echo "[shared-skills] 错误: 不支持的 skill-id: ${skill_id}" >&2
      exit 2
      ;;
  esac
}

section="$(build_section "${skill_id}")"
section_marker="$(printf '%s\n' "${section}" | sed -n '1p')"

if [[ ! -f "${agents_md}" ]]; then
  printf '%s\n' "${section}" > "${agents_md}"
  echo "[shared-skills] 已创建 AGENTS.md 并写入 ${skill_id} 说明: ${agents_md}" >&2
  exit 0
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
  echo "[shared-skills] 已更新 AGENTS.md 中的 ${skill_id} 说明: ${agents_md}" >&2
else
  {
    printf '\n'
    printf '%s\n' "${section}"
  } >> "${agents_md}"
  echo "[shared-skills] 已追加 ${skill_id} 说明到 AGENTS.md: ${agents_md}" >&2
fi
