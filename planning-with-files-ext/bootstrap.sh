#!/bin/bash

set -euo pipefail

TARGET_ROOT="${1:-$(pwd)}"
NOW="$(date "+%Y-%m-%d %H:%M:%S")"

CURSOR_DIR="${TARGET_ROOT}/.cursor"
RULES_DIR="${CURSOR_DIR}/rules"
HOOKS_DIR="${CURSOR_DIR}/hooks"
PLANS_DIR="${TARGET_ROOT}/doc/plans"

mkdir -p "${RULES_DIR}" "${HOOKS_DIR}" "${PLANS_DIR}"

cat > "${PLANS_DIR}/planning-paths.sh" <<'PLANPATHSEOF'
#!/bin/bash
# planning-with-files-ext: 路径 id 校验与 effective_dir（SUB_ACTIVE）解析
# 由 hooks、new-plan.sh、plan.sh source；勿直接执行。

planning_validate_path_id() {
  local id="${1:-}"
  if [[ -z "${id}" ]]; then
    echo "planning-paths: plan id 为空" >&2
    return 1
  fi
  if [[ "${id}" == /* || "${id}" == */ ]]; then
    echo "planning-paths: plan id 不得以 / 开头或结尾：${id}" >&2
    return 1
  fi
  if [[ "${id}" == *..* ]]; then
    echo "planning-paths: plan id 不允许 ..：${id}" >&2
    return 1
  fi
  if [[ "${id}" == *//* ]]; then
    echo "planning-paths: plan id 不允许连续斜杠：${id}" >&2
    return 1
  fi
  local IFS='/'
  # shellcheck disable=SC2206
  local parts=(${id})
  local n="${#parts[@]}"
  if [[ "${n}" -gt 2 ]]; then
    echo "planning-paths: 路径至多两段（父 或 父/子）：${id}" >&2
    return 1
  fi
  local p
  for p in "${parts[@]}"; do
    if [[ -z "${p}" ]]; then
      echo "planning-paths: 含空路径段：${id}" >&2
      return 1
    fi
    if [[ ! "${p}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
      echo "planning-paths: 非法段「${p}」（仅字母数字._-）：${id}" >&2
      return 1
    fi
  done
  return 0
}

# 参数：$1 = doc/plans 的绝对路径；$2 = ACTIVE 文件内容（trim 前可先调用方处理）
# 输出：相对 doc/plans 的 effective 子路径（如 foo 或 foo/T1），无效时输出空行
planning_resolve_effective_subpath() {
  local plans_root="${1:-}"
  local active_line="${2:-}"
  active_line="$(printf '%s' "${active_line}" | tr -d '\r\n\t ')"
  if [[ -z "${active_line}" ]]; then
    echo ""
    return 0
  fi
  if ! planning_validate_path_id "${active_line}"; then
    echo ""
    return 0
  fi
  local parent_dir="${plans_root}/${active_line}"
  if [[ ! -d "${parent_dir}" ]]; then
    echo ""
    return 0
  fi

  if [[ "${active_line}" == */* ]]; then
    printf '%s\n' "${active_line}"
    return 0
  fi

  local sub_file="${parent_dir}/SUB_ACTIVE"
  if [[ -f "${sub_file}" ]]; then
    local child
    child="$(tr -d '\r\n\t ' < "${sub_file}")"
    if [[ -n "${child}" ]] && [[ "${child}" =~ ^[a-zA-Z0-9._-]+$ ]] && [[ -d "${parent_dir}/${child}" ]]; then
      printf '%s\n' "${active_line}/${child}"
      return 0
    fi
  fi
  printf '%s\n' "${active_line}"
  return 0
}
PLANPATHSEOF

HOOKS_JSON_DEST="${CURSOR_DIR}/hooks.json"
HOOKS_JSON_WANT="$(mktemp)"
trap 'rm -f "${HOOKS_JSON_WANT}"' EXIT

cat > "${HOOKS_JSON_WANT}" <<'EOF'
{
  "version": 1,
  "hooks": {
    "userPromptSubmit": [
      {
        "command": ".cursor/hooks/user-prompt-submit.sh",
        "timeout": 5
      }
    ],
    "preToolUse": [
      {
        "command": ".cursor/hooks/pre-tool-use.sh",
        "matcher": "Write|Edit|Shell|Read",
        "timeout": 5
      }
    ],
    "postToolUse": [
      {
        "command": ".cursor/hooks/post-tool-use.sh",
        "matcher": "Write|Edit",
        "timeout": 5
      }
    ],
    "stop": [
      {
        "command": ".cursor/hooks/stop.sh",
        "timeout": 10,
        "loop_limit": 3
      }
    ]
  }
}
EOF

if [ -f "${HOOKS_JSON_DEST}" ] && ! cmp -s "${HOOKS_JSON_WANT}" "${HOOKS_JSON_DEST}"; then
  echo "[planning-with-files] 错误: 已存在与本模板不一致的 .cursor/hooks.json，为避免覆盖已有钩子配置，已中断。" >&2
  echo "  文件路径: ${HOOKS_JSON_DEST}" >&2
  echo "  处理建议: 先备份该文件；将本模板所需的 hooks 段手动合并进去；或移走/删除现有 hooks.json 后重新运行 bootstrap。" >&2
  echo "--- 差异预览 (unified diff) ---" >&2
  diff -u "${HOOKS_JSON_DEST}" "${HOOKS_JSON_WANT}" >&2 || true
  exit 1
fi

cp "${HOOKS_JSON_WANT}" "${HOOKS_JSON_DEST}"

cat > "${RULES_DIR}/planning-with-files.mdc" <<EOF
<!--
UpdatedAt: ${NOW}
LatestChange: 增加路径 id、父计划+子计划、SUB_ACTIVE、effective_dir 与总纲索引表约定。
-->

# Planning workflow (file-based)

当用户提出“做计划/拆解任务/制定实现方案/进入 Plan 模式/这会是一个复杂任务”等请求时，默认使用 **planning-with-files** 的三文件工作流（无需用户点名）：

## plan-id 与目录（路径 id）

- **plan-id** 为相对 \`doc/plans/\` 的 POSIX 子路径，用 \`/\` 连接，**与磁盘目录一一对应**。每段仅 \`[a-zA-Z0-9._-]+\`，禁止 \`..\`、首尾 \`/\`、空段、连续 \`/\`；相对 \`doc/plans/\` **至多两段**（\`父\` 或 \`父/子\`），不支持更深嵌套。
- **必须先创建**（\`doc/plans/<plan-id>/\`）：
  - \`task_plan.md\`（权威：目标、阶段或总纲大纲、完成判定、重大决策、错误表）
  - \`findings.md\`（调研与证据：外部资料/检索结果/结论沉淀——**体量大的外部原文放这里**）
  - \`progress.md\`（执行日志）
  - （按需）\`execution_brief.md\`
- **激活计划**：\`doc/plans/ACTIVE\` 存当前 **全局** plan-id（一行）。hooks 解析 **effective_dir**（见下）后读写 **effective** 目录下的三文件。
- **可选「直挂子计划」**：\`ACTIVE\` 也可为两段路径（如 \`feature-a/T1\`），此时 effective_dir 即为该路径；**不**再读父目录的 \`SUB_ACTIVE\`。

## 父计划 + 子计划（总纲与子目录）

- **总纲（父计划）** \`doc/plans/<父>/\`：\`task_plan.md\` 仅保留 **大纲 + 子计划索引表 + 各子完成判据（一句话）**，不要把子计划的详细 Phase 写进总纲（避免 hook 注入过载）。
- **子计划** \`doc/plans/<父>/<子>/\`：各自一套三文件；**详细 Phase、执行细节**在子计划 \`task_plan.md\`。
- **子计划索引表**（唯一位置）：父级 \`task_plan.md\` 内固定标题 \`## 子计划索引表\`。表中数据行 **自上而下** 为 \`SUB_ACTIVE\` 推进顺序。
- **最小表头**（列）：\`序号 | 子目录 | 简述 | 完成判据（一句话） | 状态\`；\`子目录\` 仅一段名，与磁盘 \`<父>/<子目录>/\` 一致。
- **状态列**：\`pending\` / \`in_progress\` / \`complete\`；**全表同一时间仅允许一行 \`in_progress\`**，且必须与当前 \`SUB_ACTIVE\` 指向的子目录一致。推进时：先将当前行改为 \`complete\`，再将下一行改为 \`in_progress\`。创建子计划后：**仅第一行** \`in_progress\`，其余 \`pending\`。
- **SUB_ACTIVE**（父目录下文件 \`doc/plans/<父>/SUB_ACTIVE\`）：纯文本一行，为**子目录名**（一段，无 \`/\`）。由 **Agent** 维护（非 \`plan.sh\` 自动写）：子目录就绪后指向索引表首行；子计划按表顺序完成后推进 \`SUB_ACTIVE\` 与索引表状态；**全部子计划完成后删除或清空 \`SUB_ACTIVE\`**，effective_dir 回到父目录三文件。用户用 \`[计划: <父>]\` 或 \`plan.sh use <父>\` 切回父计划时 **不得清除** \`<父>/SUB_ACTIVE\`，保留上次子指针。
- **effective_dir**：若 \`ACTIVE\` 为单段 \`<父>\` 且存在有效 \`<父>/SUB_ACTIVE\` 指向已存在的子目录，则 effective 为 \`<父>/<子>\`；否则 effective 与 \`ACTIVE\` 对应目录一致（单段或两段直挂）。

## 单计划（无双总纲）

- **阶段设计**：\`task_plan.md\` 里 3–7 个 Phase，验收标准明确；Phase 1 标记 \`in_progress\`，其余 \`pending\`。

## 计划交付与更新频率

- **execution_brief（按需）**：仅当用户明确要求交接/执行文档时，阶段冻结后生成/更新，含目标、范围、任务顺序、DoD、验证门禁等。
- 每完成一个 Phase（或子计划）：更新对应 **effective** 下 \`task_plan.md\` 状态，并写 \`progress.md\`。
- 约每 2 次浏览/检索：结论记入 **effective** 的 \`findings.md\`。
- **安全边界**：\`task_plan.md\` 会被 hooks 反复读入；不可信原文进 \`findings.md\`，\`task_plan.md\` 只保留消化后的结论与决策摘要。

## 对用户的输出要求

- 先给出 **effective** 的 \`task_plan.md\` 骨架（总纲则含索引表；子计划则含 Phases）。
- 再开始大范围实现或搜索。
- 文档交付请求收尾时，说明 \`execution_brief.md\` 可作实施输入（若已生成）。

## 工具

- \`./doc/plans/plan.sh new <plan-id>\`、\`use\`、\`list\` 支持路径 id；\`list\` 列出所有含 \`task_plan.md\` 的计划目录（缩进表示父子）。
- 对话中 \`[计划: <plan-id>]\` / \`[plan: <plan-id>]\` 可切换 \`ACTIVE\`（**不**修改 \`SUB_ACTIVE\`）。
EOF

cat > "${HOOKS_DIR}/user-prompt-submit.sh" <<'EOF'
#!/bin/bash
# planning-with-files-ext: User prompt submit hook for Cursor
# Injects plan context on every user message.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${HOOK_DIR}/../.." && pwd)"
BASE_DIR="${REPO_ROOT}/doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

# shellcheck source=doc/plans/planning-paths.sh
source "${BASE_DIR}/planning-paths.sh"

extract_prompt_from_stdin() {
  local stdin_content
  stdin_content="$(cat 2>/dev/null || true)"
  if [ -z "${stdin_content}" ]; then
    echo ""
    return
  fi

  local parsed
  parsed="$(printf '%s' "${stdin_content}" | sed -nE 's/.*"prompt"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -n 1)"
  if [ -z "${parsed}" ]; then
    parsed="$(printf '%s' "${stdin_content}" | sed -nE 's/.*"message"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -n 1)"
  fi
  if [ -z "${parsed}" ]; then
    parsed="${stdin_content}"
  fi
  echo "${parsed}"
}

parse_plan_id_from_prompt() {
  local prompt_text="${1:-}"
  if [ -z "${prompt_text}" ]; then
    echo ""
    return
  fi

  local plan_id
  plan_id="$(printf '%s' "${prompt_text}" | sed -nE 's/.*\[(计划|plan)[[:space:]]*:[[:space:]]*([a-zA-Z0-9._/-]+)\].*/\2/p' | head -n 1)"
  echo "${plan_id}"
}

switch_active_if_needed() {
  local plan_id="${1:-}"
  if [ -z "${plan_id}" ]; then
    return
  fi

  if ! planning_validate_path_id "${plan_id}"; then
    echo "[planning-with-files] 提示中的 plan-id 校验失败，忽略切换: ${plan_id}" >&2
    return
  fi

  local plan_dir="${BASE_DIR}/${plan_id}"
  if [ ! -d "${plan_dir}" ]; then
    echo "[planning-with-files] 提示中指定的计划不存在，忽略切换: ${plan_id}" >&2
    return
  fi

  echo "${plan_id}" > "${ACTIVE_FILE}"
  echo "[planning-with-files] 已根据提示切换 ACTIVE: ${plan_id}（未修改各计划目录下 SUB_ACTIVE）" >&2
}

PROMPT_FROM_STDIN="$(extract_prompt_from_stdin)"
PLAN_ID_FROM_PROMPT="$(parse_plan_id_from_prompt "${PROMPT_FROM_STDIN}")"
switch_active_if_needed "${PLAN_ID_FROM_PROMPT}"

ACTIVE_LINE=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_LINE="$(tr -d '\r\n\t ' < "${ACTIVE_FILE}")"
fi

EFFECTIVE_SUBPATH="$(planning_resolve_effective_subpath "${BASE_DIR}" "${ACTIVE_LINE}")"
if [ -z "${EFFECTIVE_SUBPATH}" ]; then
  exit 0
fi

PLAN_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/task_plan.md"
FINDINGS_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/findings.md"
PROGRESS_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/progress.md"

if [ -f "${PLAN_FILE}" ]; then
  echo "[planning-with-files] ACTIVE='${ACTIVE_LINE}' effective='${EFFECTIVE_SUBPATH}' — current state:"
  head -50 "${PLAN_FILE}"
  echo ""
  echo "=== recent progress ==="
  tail -20 "${PROGRESS_FILE}" 2>/dev/null
  echo ""
  echo "[planning-with-files] Read ${FINDINGS_FILE} for research context. Continue from the current phase."
fi
exit 0
EOF

cat > "${HOOKS_DIR}/pre-tool-use.sh" <<'EOF'
#!/bin/bash
# planning-with-files-ext: Pre-tool-use hook for Cursor

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${HOOK_DIR}/../.." && pwd)"
BASE_DIR="${REPO_ROOT}/doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

# shellcheck source=doc/plans/planning-paths.sh
source "${BASE_DIR}/planning-paths.sh"

ACTIVE_LINE=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_LINE="$(tr -d '\r\n\t ' < "${ACTIVE_FILE}")"
fi

EFFECTIVE_SUBPATH="$(planning_resolve_effective_subpath "${BASE_DIR}" "${ACTIVE_LINE}")"
if [ -n "${EFFECTIVE_SUBPATH}" ]; then
  PLAN_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/task_plan.md"
  if [ -f "${PLAN_FILE}" ]; then
    head -30 "${PLAN_FILE}" >&2
  fi
fi

echo '{"decision": "allow"}'
exit 0
EOF

cat > "${HOOKS_DIR}/post-tool-use.sh" <<'EOF'
#!/bin/bash
# planning-with-files-ext: Post-tool-use hook for Cursor

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${HOOK_DIR}/../.." && pwd)"
BASE_DIR="${REPO_ROOT}/doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

# shellcheck source=doc/plans/planning-paths.sh
source "${BASE_DIR}/planning-paths.sh"

ACTIVE_LINE=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_LINE="$(tr -d '\r\n\t ' < "${ACTIVE_FILE}")"
fi

EFFECTIVE_SUBPATH="$(planning_resolve_effective_subpath "${BASE_DIR}" "${ACTIVE_LINE}")"
if [ -z "${EFFECTIVE_SUBPATH}" ]; then
  exit 0
fi

PLAN_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/task_plan.md"
PROGRESS_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/progress.md"

if [ -f "${PLAN_FILE}" ]; then
  echo "[planning-with-files] Update ${PROGRESS_FILE} with what you just did. If a phase is now complete, update ${PLAN_FILE} status."
fi
exit 0
EOF

cat > "${HOOKS_DIR}/stop.sh" <<'EOF'
#!/bin/bash
# planning-with-files-ext: Stop hook for Cursor

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${HOOK_DIR}/../.." && pwd)"
BASE_DIR="${REPO_ROOT}/doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

# shellcheck source=doc/plans/planning-paths.sh
source "${BASE_DIR}/planning-paths.sh"

ACTIVE_LINE=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_LINE="$(tr -d '\r\n\t ' < "${ACTIVE_FILE}")"
fi

EFFECTIVE_SUBPATH="$(planning_resolve_effective_subpath "${BASE_DIR}" "${ACTIVE_LINE}")"
PLAN_FILE="${BASE_DIR}/${EFFECTIVE_SUBPATH}/task_plan.md"
if [ -z "${EFFECTIVE_SUBPATH}" ] || [ ! -f "${PLAN_FILE}" ]; then
  exit 0
fi

TOTAL=$(grep -cE "^### (Phase|阶段)" "${PLAN_FILE}" || true)
COMPLETE=$(grep -cF "**Status:** complete" "${PLAN_FILE}" || true)
IN_PROGRESS=$(grep -cF "**Status:** in_progress" "${PLAN_FILE}" || true)
PENDING=$(grep -cF "**Status:** pending" "${PLAN_FILE}" || true)

if [ "${COMPLETE}" -eq 0 ] && [ "${IN_PROGRESS}" -eq 0 ] && [ "${PENDING}" -eq 0 ]; then
  COMPLETE=$(grep -c "\[complete\]" "${PLAN_FILE}" || true)
  IN_PROGRESS=$(grep -c "\[in_progress\]" "${PLAN_FILE}" || true)
  PENDING=$(grep -c "\[pending\]" "${PLAN_FILE}" || true)
fi

: "${TOTAL:=0}"
: "${COMPLETE:=0}"

REL_PROGRESS="doc/plans/${EFFECTIVE_SUBPATH}/progress.md"

if [ "${COMPLETE}" -eq "${TOTAL}" ] && [ "${TOTAL}" -gt 0 ]; then
  echo "{\"followup_message\": \"[planning-with-files] ALL PHASES COMPLETE (${COMPLETE}/${TOTAL}) for effective plan '${EFFECTIVE_SUBPATH}' (ACTIVE='${ACTIVE_LINE}'). If the user has additional work, add new phases to ${PLAN_FILE} before starting.\"}"
else
  echo "{\"followup_message\": \"[planning-with-files] Task incomplete (${COMPLETE}/${TOTAL} phases done) for effective plan '${EFFECTIVE_SUBPATH}' (ACTIVE='${ACTIVE_LINE}'). Update ${REL_PROGRESS}, then read ${PLAN_FILE} and continue working on remaining phases.\"}"
fi
exit 0
EOF

cat > "${PLANS_DIR}/new-plan.sh" <<'EOF'
#!/bin/bash

set -euo pipefail

PLANS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=planning-paths.sh
source "${PLANS_DIR}/planning-paths.sh"

PLAN_ID="${1:-}"
if [[ -z "${PLAN_ID}" ]]; then
  echo "用法: ./doc/plans/new-plan.sh <plan-id>" >&2
  echo "  plan-id：相对 doc/plans 的路径，一至两段（如 feature-a 或 feature-a/T1），段内仅字母数字._-" >&2
  exit 1
fi
if ! planning_validate_path_id "${PLAN_ID}"; then
  exit 1
fi

PLAN_DIR="${PLANS_DIR}/${PLAN_ID}"
mkdir -p "${PLAN_DIR}"

TASK_PLAN_FILE="${PLAN_DIR}/task_plan.md"
FINDINGS_FILE="${PLAN_DIR}/findings.md"
PROGRESS_FILE="${PLAN_DIR}/progress.md"
ACTIVE_FILE="${PLANS_DIR}/ACTIVE"
NOW="$(date "+%Y-%m-%d %H:%M:%S")"

if [[ ! -f "${TASK_PLAN_FILE}" ]]; then
  cat > "${TASK_PLAN_FILE}" <<EOF2
# Task Plan: ${PLAN_ID}
## 目标

-

## 阶段拆解

### 阶段 1：需求澄清与现状调研

- [ ] 明确用户意图与验收标准
- [ ] 梳理约束条件与边界
- [ ] 将调研结论记录到 findings.md
- **Status:** in_progress

### 阶段 2：方案设计与任务拆分

- [ ] 明确技术方案与实施路径
- [ ] 记录关键决策与取舍理由
- **Status:** pending

### 阶段 3：实施与自测

- [ ] 按计划逐步实施
- [ ] 每步完成后进行最小验证
- **Status:** pending

### 阶段 4：验证与回归

- [ ] 验证需求覆盖与边界场景
- [ ] 将测试结果记录到 progress.md
- **Status:** pending

### 阶段 5：交付与总结

- [ ] 确认交付物完整可用
- [ ] 输出结果与后续建议
- **Status:** pending

## 决策记录

| 决策 | 原因 |
|------|------|
| | |

## 问题与错误记录

| 问题/错误 | 尝试次数 | 解决方式 |
|-----------|----------|----------|
| | 1 | |
EOF2
fi

if [[ ! -f "${FINDINGS_FILE}" ]]; then
  cat > "${FINDINGS_FILE}" <<'EOF2'
# 调研与结论

## 需求摘要

-

## 调研发现

-

## 技术决策

| 决策 | 原因 |
|------|------|
| | |

## 遇到的问题

| 问题 | 处理结果 |
|------|----------|
| | |
EOF2
fi

if [[ ! -f "${PROGRESS_FILE}" ]]; then
  cat > "${PROGRESS_FILE}" <<EOF2
# 进度日志

## 会话：${NOW}

### 阶段 1：需求澄清与现状调研

- **Status:** in_progress
- **Started:** ${NOW}

- 已完成动作：
  -

- 影响文件：
  -

## 测试结果

| 测试项 | 输入 | 预期 | 实际 | 状态 |
|--------|------|------|------|------|
| | | | | |

## 错误日志

-
EOF2
fi

echo "${PLAN_ID}" > "${ACTIVE_FILE}"
echo "计划已初始化: ${PLAN_DIR}"
echo "已切换当前激活计划: ${PLAN_ID}"
echo "已准备文件:"
echo "  - ${TASK_PLAN_FILE}"
echo "  - ${FINDINGS_FILE}"
echo "  - ${PROGRESS_FILE}"
echo "  - （按需）${PLAN_DIR}/execution_brief.md"
echo "  - ${ACTIVE_FILE}"
EOF

cat > "${PLANS_DIR}/plan.sh" <<'EOF'
#!/bin/bash

set -euo pipefail

PLANS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTIVE_FILE="${PLANS_DIR}/ACTIVE"
NEW_PLAN_SCRIPT="${PLANS_DIR}/new-plan.sh"

# shellcheck source=planning-paths.sh
source "${PLANS_DIR}/planning-paths.sh"

usage() {
  cat <<'EOT'
用法:
  ./doc/plans/plan.sh list
  ./doc/plans/plan.sh use <plan-id>
  ./doc/plans/plan.sh new <plan-id>

plan-id：相对 doc/plans 的一至两段路径（如 myplan 或 myplan/T1）；切换到父计划不会修改该目录下 SUB_ACTIVE。
EOT
}

read_active() {
  if [[ -f "${ACTIVE_FILE}" ]]; then
    tr -d '\r\n\t ' < "${ACTIVE_FILE}"
  fi
}

cmd_list() {
  local active active_eff aggregated depth rel indent suf
  active="$(read_active)"
  active_eff="$(planning_resolve_effective_subpath "${PLANS_DIR}" "${active}")"
  echo "计划列表（目录: ${PLANS_DIR}）"
  if [[ -n "${active}" ]]; then
    echo "当前 ACTIVE: ${active}"
    if [[ -n "${active_eff}" ]]; then
      echo "当前 effective（ACTIVE + SUB_ACTIVE 解析）: ${active_eff}"
    fi
  else
    echo "当前 ACTIVE: （未设置）"
  fi
  echo

  aggregated="$(
    {
      find "${PLANS_DIR}" -type f -name task_plan.md 2>/dev/null || true
    } | while IFS= read -r f; do
      [[ -z "${f}" ]] && continue
      rel="${f#"${PLANS_DIR}/"}"
      rel="${rel%/task_plan.md}"
      slashes="${rel//[^\/]/}"
      depth=${#slashes}
      printf '%d\t%s\n' "${depth}" "${rel}"
    done | sort -n -t $'\t' -k1,1 -k2,2
  )"

  if [[ -z "${aggregated}" ]]; then
    echo "（暂无计划目录）"
    return 0
  fi

  printf '%s\n' "${aggregated}" | while IFS=$'\t' read -r depth rel; do
    [[ -z "${rel}" ]] && continue
    indent=""
    if [[ "${depth}" -ge 1 ]]; then
      indent="  "
    fi
    suf=""
    [[ "${rel}" == "${active}" ]] && suf=" (ACTIVE)"
    if [[ -n "${active_eff}" && "${rel}" == "${active_eff}" && "${active_eff}" != "${active}" ]]; then
      suf="${suf} (effective)"
    fi
    echo "${indent}* ${rel}${suf}"
  done
}

cmd_use() {
  local plan_id="${1:-}"
  if [[ -z "${plan_id}" ]]; then
    echo "错误: 缺少 plan-id。" >&2
    usage >&2
    exit 1
  fi
  if ! planning_validate_path_id "${plan_id}"; then
    exit 1
  fi
  local plan_dir="${PLANS_DIR}/${plan_id}"
  if [[ ! -d "${plan_dir}" ]]; then
    echo "错误: 计划不存在: ${plan_id}" >&2
    exit 1
  fi
  echo "${plan_id}" > "${ACTIVE_FILE}"
  echo "已切换当前激活计划: ${plan_id}（未修改任何 SUB_ACTIVE；父目录下 SUB_ACTIVE 由 Agent 维护）"
}

cmd_new() {
  local plan_id="${1:-}"
  if [[ ! -x "${NEW_PLAN_SCRIPT}" ]]; then
    echo "错误: new-plan.sh 不存在或不可执行: ${NEW_PLAN_SCRIPT}" >&2
    exit 1
  fi
  "${NEW_PLAN_SCRIPT}" "${plan_id}"
}

main() {
  local action="${1:-}"
  case "${action}" in
    list)
      cmd_list
      ;;
    use)
      cmd_use "${2:-}"
      ;;
    new)
      cmd_new "${2:-}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
EOF

chmod +x \
  "${HOOKS_DIR}/user-prompt-submit.sh" \
  "${HOOKS_DIR}/pre-tool-use.sh" \
  "${HOOKS_DIR}/post-tool-use.sh" \
  "${HOOKS_DIR}/stop.sh" \
  "${PLANS_DIR}/new-plan.sh" \
  "${PLANS_DIR}/plan.sh"

echo "模板初始化完成: ${TARGET_ROOT}"
echo "已写入:"
echo "  - ${RULES_DIR}/planning-with-files.mdc"
echo "  - ${CURSOR_DIR}/hooks.json"
echo "  - ${HOOKS_DIR}/*.sh"
echo "  - ${PLANS_DIR}/new-plan.sh"
echo "  - ${PLANS_DIR}/plan.sh"
echo "  - ${PLANS_DIR}/planning-paths.sh"
