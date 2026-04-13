#!/bin/bash
# 读取 shared-skills README 中的配置块，并按 target 生成业务项目 AGENTS.md 的 Shared Skills 节。
# 当前版本只支持 skills.sh 主路径，不保留任何旧键、旧路径或历史回退逻辑。

set -euo pipefail

usage() {
  cat <<'EOT' >&2
用法:
  bash /path/to/shared-skills/configure-from-readme.sh [--target claude|codex|both] [target_project_root]

环境变量:
  SKILLS_ROOT            可选。默认为本脚本所在目录（shared-skills 根）。
  SHARED_SKILLS_TARGET   可选。与 --target 含义相同，支持 claude/codex/both（默认 both）。

说明:
  - 默认配置（含 shared_skill_links）预写在 shared-skills 仓库根 README.md 的 <!-- shared-skills-config --> 中；业务项目 README 可省略或只写需要覆盖的键。
  - 当前只接受 shared_skill_links；出现旧键或未知键将直接失败。
  - target 路径策略:
      claude -> .claude/shared-skills
      codex  -> .codex/shared-skills
      both   -> 同时写入上述两套路径
  - 执行顺序: 合并配置 -> 解析并校验 shared_skill_links -> 按 target 写入 AGENTS.md
  - 若 shared-skills/README.md 与业务 README 中均无可解析配置块，以非零退出。

业务 README 可选片段（仅覆盖部分键时）:
  <!-- shared-skills-config
  shared_skill_links=eng-practices,code-styleguide-skills,unit-test-guide-skills,open-spec-cn
  -->
EOT
}

target_mode_cli=""
target_root_arg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "[shared-skills] 错误: --target 缺少参数（可选: claude|codex|both）。" >&2
        usage
        exit 2
      fi
      target_mode_cli="$2"
      shift 2
      ;;
    --target=*)
      target_mode_cli="${1#*=}"
      shift
      ;;
    -*)
      echo "[shared-skills] 错误: 未知参数: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -n "${target_root_arg}" ]]; then
        echo "[shared-skills] 错误: 仅允许一个 target_project_root，收到多余参数: $1" >&2
        usage
        exit 2
      fi
      target_root_arg="$1"
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="${SKILLS_ROOT:-${SCRIPT_DIR}}"
TARGET_ROOT="${target_root_arg:-$(pwd)}"
TARGET_ROOT="$(cd "${TARGET_ROOT}" && pwd)"
README="${TARGET_ROOT}/README.md"
SKILLS_README="${SKILLS_ROOT}/README.md"
TARGET_MODE_RAW="${target_mode_cli:-${SHARED_SKILLS_TARGET:-both}}"
TARGET_MODE="$(printf '%s' "${TARGET_MODE_RAW}" | tr '[:upper:]' '[:lower:]')"

case "${TARGET_MODE}" in
  claude|codex|both) ;;
  *)
    echo "[shared-skills] 错误: 无效 target: ${TARGET_MODE_RAW}（可选: claude|codex|both）" >&2
    exit 2
    ;;
esac

extract_config_block() {
  local file="$1"
  awk '
    BEGIN { inblk=0 }
    /<!--[[:space:]]*shared-skills-config/ { inblk=1; next }
    inblk && /-->/ { exit }
    inblk { print }
  ' "$file"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

resolve_skill_entry() {
  printf '%s' "$1"
}

expand_skill_links_csv() {
  local csv="$1"
  local saved_ifs="$IFS"
  IFS=','
  # shellcheck disable=SC2206
  local parts=(${csv})
  IFS="$saved_ifs"
  local out=()
  local resolved part entry duplicate

  for part in "${parts[@]}"; do
    part="$(trim "${part}")"
    [[ -z "${part}" ]] && continue
    resolved="$(resolve_skill_entry "${part}")"
    duplicate=0
    if [[ ${#out[@]} -gt 0 ]]; then
      for entry in "${out[@]}"; do
        if [[ "${entry}" == "${resolved}" ]]; then
          duplicate=1
          break
        fi
      done
    fi
    [[ "${duplicate}" -eq 1 ]] && continue
    out+=("${resolved}")
  done

  if [[ ${#out[@]} -eq 0 ]]; then
    printf ''
    return 0
  fi

  (IFS=','; printf '%s' "${out[*]}")
}

shared_skill_links=""

apply_config_block() {
  local block="$1"
  local src_label="$2"
  local line key value

  [[ -z "${block//[[:space:]]/}" ]] && return 0

  while IFS= read -r raw || [[ -n "${raw}" ]]; do
    line="$(trim "${raw}")"
    [[ -z "${line}" ]] && continue
    [[ "${line}" == \#* ]] && continue

    if [[ "${line}" != *"="* ]]; then
      echo "[shared-skills] 错误: [${src_label}] 仅支持 key=value 行，收到: ${line}" >&2
      exit 2
    fi

    key="$(trim "${line%%=*}")"
    value="$(trim "${line#*=}")"

    case "${key}" in
      shared_skill_links)
        shared_skill_links="${value}"
        ;;
      *)
        echo "[shared-skills] 错误: [${src_label}] 不支持配置项: ${key}。当前版本只接受 shared_skill_links。" >&2
        exit 2
        ;;
    esac
  done <<< "${block}"
}

DEFAULT_BLOCK=""
if [[ -f "${SKILLS_README}" ]]; then
  DEFAULT_BLOCK="$(extract_config_block "${SKILLS_README}")"
fi

PROJECT_BLOCK=""
if [[ -f "${README}" ]]; then
  PROJECT_BLOCK="$(extract_config_block "${README}")"
else
  echo "[shared-skills] 提示: 业务项目无 README.md，将仅使用 shared-skills 仓库 README 中的默认配置块。" >&2
fi

if [[ -z "${DEFAULT_BLOCK//[[:space:]]/}" && -z "${PROJECT_BLOCK//[[:space:]]/}" ]]; then
  echo "[shared-skills] 错误: 未找到 <!-- shared-skills-config ... -->。" >&2
  echo "  须在 ${SKILLS_README} 中预置默认块，或在业务项目 ${README} 中加入配置块。" >&2
  exit 1
fi

if [[ -n "${DEFAULT_BLOCK//[[:space:]]/}" ]]; then
  echo "[shared-skills] 已加载默认配置块: ${SKILLS_README}" >&2
  apply_config_block "${DEFAULT_BLOCK}" "默认(shared-skills/README.md)"
fi

if [[ -n "${PROJECT_BLOCK//[[:space:]]/}" ]]; then
  echo "[shared-skills] 已合并业务项目配置块: ${README}" >&2
  apply_config_block "${PROJECT_BLOCK}" "业务 README.md"
fi

if [[ -z "$(trim "${shared_skill_links}")" ]]; then
  echo "[shared-skills] 错误: shared_skill_links 为空。当前版本要求显式解析出至少一个入口技能。" >&2
  exit 1
fi

skill_links_resolved="$(expand_skill_links_csv "${shared_skill_links}")"
if [[ -z "$(trim "${skill_links_resolved}")" ]]; then
  echo "[shared-skills] 错误: shared_skill_links 解析后为空，请检查配置值。" >&2
  exit 1
fi

saved_ifs="$IFS"
IFS=','
# shellcheck disable=SC2206
resolved_links=(${skill_links_resolved})
IFS="$saved_ifs"

for entry in "${resolved_links[@]}"; do
  name="$(trim "${entry}")"
  [[ -z "${name}" ]] && continue
  src="${SKILLS_ROOT}/${name}"
  if [[ ! -d "${src}" ]] || [[ ! -f "${src}/SKILL.md" ]]; then
    echo "[shared-skills] 错误: 技能目录不存在或缺少 SKILL.md: ${src}" >&2
    exit 1
  fi
  echo "[shared-skills] 已校验 shared_skill_links 项: ${name}" >&2
done

SKILL_PATH_PREFIXES=()
case "${TARGET_MODE}" in
  claude) SKILL_PATH_PREFIXES+=(".claude/shared-skills") ;;
  codex) SKILL_PATH_PREFIXES+=(".codex/shared-skills") ;;
  both) SKILL_PATH_PREFIXES+=(".claude/shared-skills" ".codex/shared-skills") ;;
esac

prefix_label() {
  case "$1" in
    .claude/shared-skills) printf 'Claude' ;;
    .codex/shared-skills) printf 'Codex' ;;
    *) printf '%s' "$1" ;;
  esac
}

write_agents_md() {
  local links_csv="$1"
  local agents_md="${TARGET_ROOT}/AGENTS.md"
  local section_marker="## Shared Skills（由 configure-from-readme.sh 生成，勿手动删除此行）"
  local new_section

  new_section="${section_marker}"

  local saved_ifs="$IFS"
  IFS=','
  # shellcheck disable=SC2206
  local skill_names=(${links_csv})
  IFS="$saved_ifs"

  local prefix_count="${#SKILL_PATH_PREFIXES[@]}"
  local prefix entry sname
  for prefix in "${SKILL_PATH_PREFIXES[@]}"; do
    if [[ "${prefix_count}" -gt 1 ]]; then
      new_section+=$'\n\n'"### $(prefix_label "${prefix}")"
    fi
    for entry in "${skill_names[@]}"; do
      sname="$(trim "${entry}")"
      [[ -z "${sname}" ]] && continue
      new_section+=$'\n'"- \`${prefix}/${sname}/SKILL.md\`"
    done
  done
  new_section+=$'\n'

  if [[ ! -f "${agents_md}" ]]; then
    printf '%s\n' "${new_section}" > "${agents_md}"
    echo "[shared-skills] 已创建 AGENTS.md 并写入 Shared Skills 节: ${agents_md}" >&2
  elif grep -qF "${section_marker}" "${agents_md}"; then
    python3 - "${agents_md}" "${section_marker}" "${new_section}" <<'PYEOF'
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
    echo "[shared-skills] 已更新 AGENTS.md 中的 Shared Skills 节: ${agents_md}" >&2
  else
    {
      printf '\n'
      printf '%s\n' "${new_section}"
    } >> "${agents_md}"
    echo "[shared-skills] 已追加 Shared Skills 节到 AGENTS.md: ${agents_md}" >&2
  fi
}

write_agents_md "${skill_links_resolved}"

echo "[shared-skills] target=${TARGET_MODE}，写入路径前缀: ${SKILL_PATH_PREFIXES[*]}" >&2
echo "[shared-skills] 配置完成: ${TARGET_ROOT}" >&2
