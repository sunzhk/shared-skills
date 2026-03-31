#!/bin/bash
# 读取 <!-- shared-skills-config ... -->：先应用 shared-skills 本仓库 README.md 中的默认块（含预置 cursor_skill_links），
# 再用业务项目根 README.md 中的块覆盖同名键（业务可整段省略，实现「只给 Agent 仓库地址、clone 后一条命令」）。
# 业务项目可无 README.md：此时仅使用仓库默认。若两处均无配置块则报错。
# 依次执行 planning-with-files-ext / lean-spec 桥接 / 解析并校验 cursor_skill_links → 写入 AGENTS.md（## Shared Skills）。
# 聚合包 code-styleguide-skills、unit-test-guide-skills 会解析为各自 router 子路径。不创建 .cursor/skills 软链。
# 本脚本须保留在 shared-skills 仓库根目录，以便解析 SKILLS_ROOT。

set -euo pipefail

usage() {
  cat <<'EOT' >&2
用法:
  bash /path/to/shared-skills/configure-from-readme.sh [target_project_root]

环境变量:
  SKILLS_ROOT   可选。默认为本脚本所在目录（shared-skills 根）。

说明:
  - 默认配置（含 cursor_skill_links）预写在 shared-skills 仓库根 README.md 的 <!-- shared-skills-config --> 中；业务项目 README 可省略或只写需要覆盖的键。
  - 执行顺序: planning_with_files_ext → lean_spec_bridge_doc → 解析并校验 cursor_skill_links → 写入 AGENTS.md
  - 若 shared-skills/README.md 与业务 README 中均无可解析配置块，以非零退出。

业务 README 可选片段（仅覆盖部分键时）:
  <!-- shared-skills-config
  lean_spec_bridge_doc=0
  -->
EOT
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="${SKILLS_ROOT:-${SCRIPT_DIR}}"
TARGET_ROOT="${1:-$(pwd)}"
TARGET_ROOT="$(cd "${TARGET_ROOT}" && pwd)"
README="${TARGET_ROOT}/README.md"
SKILLS_README="${SKILLS_ROOT}/README.md"

extract_config_block() {
  local f="$1"
  awk '
    BEGIN { inblk=0 }
    /<!--[[:space:]]*shared-skills-config/ { inblk=1; next }
    inblk && /-->/ { exit }
    inblk { print }
  ' "${f}"
}

tolower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

is_true() {
  local v
  v="$(tolower "${1:-}")"
  case "${v}" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "${s}"
}

# 将配置中的聚合技能包目录名解析为「含 SKILL.md」的路径（相对 shared-skills 根，可含 /）。
resolve_cursor_skill_entry() {
  local name="$1"
  case "${name}" in
    code-styleguide-skills)
      printf '%s' 'code-styleguide-skills/styleguide-router'
      ;;
    unit-test-guide-skills)
      printf '%s' 'unit-test-guide-skills/unit-test-router'
      ;;
    *)
      printf '%s' "${name}"
      ;;
  esac
}

# 逗号分隔的 cursor_skill_links → 解析聚合包名、按首次出现顺序去重，输出逗号分隔路径。
expand_cursor_skill_links_csv() {
  local csv="$1"
  local _saved_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2206
  local parts=(${csv})
  IFS="${_saved_ifs}"
  local out=()
  local r p e dup
  for p in "${parts[@]}"; do
    p="$(trim "${p}")"
    [[ -z "${p}" ]] && continue
    r="$(resolve_cursor_skill_entry "${p}")"
    if [[ "${r}" != "${p}" ]]; then
      echo "[shared-skills] 聚合技能包 \"${p}\" 解析为路径: ${r}" >&2
    fi
    dup=0
    if [[ ${#out[@]} -gt 0 ]]; then
      for e in "${out[@]}"; do
        if [[ "${e}" == "${r}" ]]; then dup=1; break; fi
      done
    fi
    [[ "${dup}" -eq 1 ]] && continue
    out+=("${r}")
  done
  if [[ ${#out[@]} -eq 0 ]]; then
    printf ''
    return
  fi
  (IFS=','; printf '%s' "${out[*]}")
}

# shellcheck disable=SC2034
planning_with_files_ext=""
planning_with_files_ext_no_install_pwfz=""
lean_spec_bridge_doc=""
cursor_skill_links=""

apply_config_block() {
  local block="$1"
  local src_label="$2"
  [[ -z "${block//[[:space:]]/}" ]] && return 0
  while IFS= read -r raw || [[ -n "${raw}" ]]; do
    line="$(trim "${raw}")"
    [[ -z "${line}" ]] && continue
    [[ "${line}" == \#* ]] && continue
    if [[ "${line}" != *"="* ]]; then
      echo "[shared-skills] 警告: [${src_label}] 忽略非 key=value 行: ${line}" >&2
      continue
    fi
    key="$(trim "${line%%=*}")"
    val="$(trim "${line#*=}")"
    case "${key}" in
      planning_with_files_ext) planning_with_files_ext="${val}" ;;
      planning_with_files_ext_no_install_pwfz) planning_with_files_ext_no_install_pwfz="${val}" ;;
      lean_spec_bridge_doc) lean_spec_bridge_doc="${val}" ;;
      cursor_skill_links) cursor_skill_links="${val}" ;;
      *)
        echo "[shared-skills] 警告: [${src_label}] 未知配置项（已忽略）: ${key}" >&2
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
  echo "  请参阅: ${SKILLS_ROOT}/README.human.md「README 驱动一键配置」。" >&2
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

cursor_skill_links_resolved=""
if [[ -n "$(trim "${cursor_skill_links}")" ]]; then
  cursor_skill_links_resolved="$(expand_cursor_skill_links_csv "${cursor_skill_links}")"
fi

EXT_BOOT="${SKILLS_ROOT}/planning-with-files-ext/bootstrap.sh"
BRIDGE_BOOT="${SKILLS_ROOT}/planning-with-files-lean-spec-bridge/bootstrap-bridge.sh"

if is_true "${planning_with_files_ext}"; then
  if [[ ! -f "${EXT_BOOT}" ]]; then
    echo "[shared-skills] 错误: 找不到 planning-with-files-ext/bootstrap.sh: ${EXT_BOOT}" >&2
    exit 1
  fi
  ext_args=(bash "${EXT_BOOT}" "${TARGET_ROOT}")
  if is_true "${planning_with_files_ext_no_install_pwfz}"; then
    ext_args+=(--no-install-planning-with-files-zh)
  fi
  echo "[shared-skills] 执行: planning-with-files-ext/bootstrap.sh" >&2
  "${ext_args[@]}"
else
  echo "[shared-skills] 跳过 planning_with_files_ext（未启用或为假）。" >&2
fi

if is_true "${lean_spec_bridge_doc}"; then
  if [[ ! -f "${BRIDGE_BOOT}" ]]; then
    echo "[shared-skills] 错误: 找不到 bootstrap-bridge.sh: ${BRIDGE_BOOT}" >&2
    exit 1
  fi
  echo "[shared-skills] 执行: planning-with-files-lean-spec-bridge/bootstrap-bridge.sh" >&2
  bash "${BRIDGE_BOOT}" "${TARGET_ROOT}"
else
  echo "[shared-skills] 跳过 lean_spec_bridge_doc（未启用或为假）。" >&2
fi

if [[ -n "$(trim "${cursor_skill_links_resolved}")" ]]; then
  _saved_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2206
  _links=(${cursor_skill_links_resolved})
  IFS="${_saved_ifs}"
  for entry in "${_links[@]}"; do
    name="$(trim "${entry}")"
    [[ -z "${name}" ]] && continue
    src="${SKILLS_ROOT}/${name}"
    if [[ ! -d "${src}" ]] || [[ ! -f "${src}/SKILL.md" ]]; then
      echo "[shared-skills] 错误: 技能目录不存在或缺少 SKILL.md: ${src}" >&2
      exit 1
    fi
    echo "[shared-skills] 已校验 cursor_skill_links 项: ${name}" >&2
  done
else
  if [[ -n "$(trim "${cursor_skill_links}")" ]]; then
    echo "[shared-skills] 警告: cursor_skill_links 非空但解析后无有效条目，跳过校验与 AGENTS.md。" >&2
  else
    echo "[shared-skills] 跳过 cursor_skill_links（空）。" >&2
  fi
fi

# ── 写入 AGENTS.md（## Shared Skills 节） ──────────────────────────────────────
write_agents_md() {
  local links_csv="$1"          # 解析后的技能相对路径列表（逗号分隔，可含 /）
  local agents_md="${TARGET_ROOT}/AGENTS.md"
  local section_marker="## Shared Skills（由 configure-from-readme.sh 生成，勿手动删除此行）"

  # 构建新的 ## Shared Skills 节内容（按 submodule 典型路径生成条目）
  local new_section
  new_section="${section_marker}"$'\n'
  _saved_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2206
  _skill_names=(${links_csv})
  IFS="${_saved_ifs}"
  for entry in "${_skill_names[@]}"; do
    local sname
    sname="$(trim "${entry}")"
    [[ -z "${sname}" ]] && continue
    new_section+=$'\n'"- \`.cursor/skills-shared/${sname}/SKILL.md\`"
  done

  if [[ ! -f "${agents_md}" ]]; then
    # 文件不存在 → 新建
    printf '%s\n' "${new_section}" > "${agents_md}"
    echo "[shared-skills] 已创建 AGENTS.md 并写入 Shared Skills 节: ${agents_md}" >&2
  elif grep -qF "${section_marker}" "${agents_md}"; then
    # 已有 ## Shared Skills 节 → 替换该节（从 marker 到下一个 ## 或文件末尾）
    python3 - "${agents_md}" "${section_marker}" "${new_section}" <<'PYEOF'
import sys, re

path       = sys.argv[1]
marker     = sys.argv[2]
new_sec    = sys.argv[3]

text = open(path, 'r', encoding='utf-8').read()

# 匹配从 marker 行开始到（不含）下一个 ## 标题行或文件末尾
pattern = re.compile(
    r'(^|\n)' + re.escape(marker) + r'.*?(?=\n## |\Z)',
    re.DOTALL
)

replaced = pattern.sub(
    lambda m: (('\n' if m.group(1) == '\n' else '') + new_sec),
    text
)

open(path, 'w', encoding='utf-8').write(replaced)
PYEOF
    echo "[shared-skills] 已更新 AGENTS.md 中的 Shared Skills 节: ${agents_md}" >&2
  else
    # 文件存在但无 ## Shared Skills 节 → 末尾追加
    {
      printf '\n'
      printf '%s\n' "${new_section}"
    } >> "${agents_md}"
    echo "[shared-skills] 已追加 Shared Skills 节到 AGENTS.md: ${agents_md}" >&2
  fi
}

if [[ -n "$(trim "${cursor_skill_links_resolved}")" ]]; then
  write_agents_md "${cursor_skill_links_resolved}"
else
  echo "[shared-skills] cursor_skill_links 解析后为空，跳过写入 AGENTS.md。" >&2
fi

echo "[shared-skills] 配置完成: ${TARGET_ROOT}" >&2
