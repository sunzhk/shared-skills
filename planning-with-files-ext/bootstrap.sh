#!/bin/bash

set -euo pipefail

TARGET_ROOT="${1:-$(pwd)}"
NOW="$(date "+%Y-%m-%d %H:%M:%S")"

CURSOR_DIR="${TARGET_ROOT}/.cursor"
RULES_DIR="${CURSOR_DIR}/rules"
HOOKS_DIR="${CURSOR_DIR}/hooks"
PLANS_DIR="${TARGET_ROOT}/doc/plans"

mkdir -p "${RULES_DIR}" "${HOOKS_DIR}" "${PLANS_DIR}"

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
LatestChange: 通过模板脚本初始化 planning-with-files 项目规则（按需交付 execution_brief.md）。
-->

# Planning workflow (file-based)

当用户提出“做计划/拆解任务/制定实现方案/进入 Plan 模式/这会是一个复杂任务”等请求时，默认使用 **planning-with-files** 的三文件工作流（无需用户点名）：

- **必须先创建**（项目根目录下 \`doc/plans/<plan-id>/\`）：
  - \`doc/plans/<plan-id>/task_plan.md\`（权威：目标、阶段、完成判定、重大决策、错误表）
  - \`doc/plans/<plan-id>/findings.md\`（调研与证据：外部资料/检索结果/结论沉淀）
  - \`doc/plans/<plan-id>/progress.md\`（执行日志：做了什么、改了哪些文件、验证结果）
  - （按需）\`doc/plans/<plan-id>/execution_brief.md\`（交付文档：给新 agent 或执行人直接开工的“执行视图”）
- **激活计划**：同时存在多个计划时，用 \`doc/plans/ACTIVE\` 存放当前激活的 \`<plan-id>\`（纯文本一行），hooks 会基于该指针读取对应的三文件。
- **阶段设计**：\`doc/plans/<plan-id>/task_plan.md\` 里给出 3–7 个 Phase，并明确每个 Phase 的验收标准；Phase 1 标记为 \`in_progress\`，其余为 \`pending\`。
- **计划交付（按需）**：仅当用户明确要求“输出交接文档/执行文档”时，阶段冻结后生成/更新 \`doc/plans/<plan-id>/execution_brief.md\`，至少包含：目标、范围、任务顺序、DoD、验证门禁、回填要求、风险升级条件。
- **更新频率**：
  - 每完成一个 Phase：更新 \`doc/plans/<plan-id>/task_plan.md\` 状态（\`pending → in_progress → complete\`），并在 \`doc/plans/<plan-id>/progress.md\` 记录本阶段动作与验证结果。
  - 每进行约 2 次浏览/检索/阅读类操作：把结论写入 \`doc/plans/<plan-id>/findings.md\`（避免信息丢失）。
- **安全边界**：\`doc/plans/<plan-id>/task_plan.md\` 会被 hooks 反复读入上下文。不要把外部网页/API 原文大段粘贴进该文件；外部不可信内容应写入 \`doc/plans/<plan-id>/findings.md\`，在 \`task_plan.md\` 仅保留你已消化后的结论与决策摘要。

对用户的输出要求：

- 先给出 \`doc/plans/<plan-id>/task_plan.md\` 的骨架（Goal + Phases + 关键问题 + 验收标准）。
- 再开始任何实现或大范围搜索/改动。
- 若本次包含文档交付请求，收尾时明确告知 \`execution_brief.md\` 已可作为实施输入文档（\`findings.md\`/\`progress.md\` 仅作佐证与追溯）。
EOF

cat > "${HOOKS_DIR}/user-prompt-submit.sh" <<'EOF'
#!/bin/bash
# planning-with-files: User prompt submit hook for Cursor
# Injects plan context on every user message.

BASE_DIR="doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

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
  plan_id="$(printf '%s' "${prompt_text}" | sed -nE 's/.*\[(计划|plan)[[:space:]]*:[[:space:]]*([a-zA-Z0-9._-]+)\].*/\2/p' | head -n 1)"
  echo "${plan_id}"
}

switch_active_if_needed() {
  local plan_id="${1:-}"
  if [ -z "${plan_id}" ]; then
    return
  fi

  local plan_dir="${BASE_DIR}/${plan_id}"
  if [ ! -d "${plan_dir}" ]; then
    echo "[planning-with-files] 提示中指定的计划不存在，忽略切换: ${plan_id}" >&2
    return
  fi

  echo "${plan_id}" > "${ACTIVE_FILE}"
  echo "[planning-with-files] 已根据提示切换 ACTIVE: ${plan_id}" >&2
}

PROMPT_FROM_STDIN="$(extract_prompt_from_stdin)"
PLAN_ID_FROM_PROMPT="$(parse_plan_id_from_prompt "${PROMPT_FROM_STDIN}")"
switch_active_if_needed "${PLAN_ID_FROM_PROMPT}"

ACTIVE_DIR=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_DIR="$(tr -d ' \r\n\t' < "${ACTIVE_FILE}")"
fi

PLAN_FILE="${BASE_DIR}/${ACTIVE_DIR}/task_plan.md"
FINDINGS_FILE="${BASE_DIR}/${ACTIVE_DIR}/findings.md"
PROGRESS_FILE="${BASE_DIR}/${ACTIVE_DIR}/progress.md"

if [ -f "${PLAN_FILE}" ]; then
  echo "[planning-with-files] ACTIVE PLAN (${ACTIVE_DIR}) — current state:"
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
# planning-with-files: Pre-tool-use hook for Cursor

BASE_DIR="doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

ACTIVE_DIR=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_DIR="$(tr -d ' \r\n\t' < "${ACTIVE_FILE}")"
fi

PLAN_FILE="${BASE_DIR}/${ACTIVE_DIR}/task_plan.md"
if [ -f "${PLAN_FILE}" ]; then
  head -30 "${PLAN_FILE}" >&2
fi

echo '{"decision": "allow"}'
exit 0
EOF

cat > "${HOOKS_DIR}/post-tool-use.sh" <<'EOF'
#!/bin/bash
# planning-with-files: Post-tool-use hook for Cursor

BASE_DIR="doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

ACTIVE_DIR=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_DIR="$(tr -d ' \r\n\t' < "${ACTIVE_FILE}")"
fi

PLAN_FILE="${BASE_DIR}/${ACTIVE_DIR}/task_plan.md"
PROGRESS_FILE="${BASE_DIR}/${ACTIVE_DIR}/progress.md"

if [ -f "${PLAN_FILE}" ]; then
  echo "[planning-with-files] Update ${PROGRESS_FILE} with what you just did. If a phase is now complete, update ${PLAN_FILE} status."
fi
exit 0
EOF

cat > "${HOOKS_DIR}/stop.sh" <<'EOF'
#!/bin/bash
# planning-with-files: Stop hook for Cursor

BASE_DIR="doc/plans"
ACTIVE_FILE="${BASE_DIR}/ACTIVE"

ACTIVE_DIR=""
if [ -f "${ACTIVE_FILE}" ]; then
  ACTIVE_DIR="$(tr -d ' \r\n\t' < "${ACTIVE_FILE}")"
fi

PLAN_FILE="${BASE_DIR}/${ACTIVE_DIR}/task_plan.md"
if [ ! -f "${PLAN_FILE}" ]; then
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

if [ "${COMPLETE}" -eq "${TOTAL}" ] && [ "${TOTAL}" -gt 0 ]; then
  echo "{\"followup_message\": \"[planning-with-files] ALL PHASES COMPLETE (${COMPLETE}/${TOTAL}) for plan '${ACTIVE_DIR}'. If the user has additional work, add new phases to ${PLAN_FILE} before starting.\"}"
else
  echo "{\"followup_message\": \"[planning-with-files] Task incomplete (${COMPLETE}/${TOTAL} phases done) for plan '${ACTIVE_DIR}'. Update doc/plans/${ACTIVE_DIR}/progress.md, then read ${PLAN_FILE} and continue working on remaining phases.\"}"
fi
exit 0
EOF

cat > "${PLANS_DIR}/new-plan.sh" <<'EOF'
#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLANS_DIR="${ROOT_DIR}/doc/plans"

PLAN_ID="${1:-}"
if [[ -z "${PLAN_ID}" ]]; then
  echo "用法: ./doc/plans/new-plan.sh <plan-id>" >&2
  exit 1
fi
if [[ ! "${PLAN_ID}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "plan-id 非法：仅允许字母、数字、点号、下划线、连字符。" >&2
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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLANS_DIR="${ROOT_DIR}/doc/plans"
ACTIVE_FILE="${PLANS_DIR}/ACTIVE"
NEW_PLAN_SCRIPT="${PLANS_DIR}/new-plan.sh"

usage() {
  cat <<'EOT'
用法:
  ./doc/plans/plan.sh list
  ./doc/plans/plan.sh use <plan-id>
  ./doc/plans/plan.sh new <plan-id>
EOT
}

is_valid_plan_id() {
  local plan_id="${1:-}"
  [[ "${plan_id}" =~ ^[a-zA-Z0-9._-]+$ ]]
}

read_active() {
  if [[ -f "${ACTIVE_FILE}" ]]; then
    tr -d ' \r\n\t' < "${ACTIVE_FILE}"
  fi
}

cmd_list() {
  local active
  active="$(read_active)"
  local found=0
  echo "计划列表（目录: ${PLANS_DIR}）"
  if [[ -n "${active}" ]]; then
    echo "当前 ACTIVE: ${active}"
  else
    echo "当前 ACTIVE: （未设置）"
  fi
  echo
  local dir
  for dir in "${PLANS_DIR}"/*; do
    [[ -d "${dir}" ]] || continue
    local plan_id
    plan_id="$(basename "${dir}")"
    [[ "${plan_id}" == "." || "${plan_id}" == ".." ]] && continue
    found=1
    if [[ "${plan_id}" == "${active}" ]]; then
      echo "* ${plan_id} (ACTIVE)"
    else
      echo "* ${plan_id}"
    fi
  done
  if [[ "${found}" -eq 0 ]]; then
    echo "（暂无计划目录）"
  fi
}

cmd_use() {
  local plan_id="${1:-}"
  if [[ -z "${plan_id}" ]]; then
    echo "错误: 缺少 plan-id。" >&2
    usage >&2
    exit 1
  fi
  if ! is_valid_plan_id "${plan_id}"; then
    echo "错误: plan-id 非法，仅允许字母、数字、点号、下划线、连字符。" >&2
    exit 1
  fi
  local plan_dir="${PLANS_DIR}/${plan_id}"
  if [[ ! -d "${plan_dir}" ]]; then
    echo "错误: 计划不存在: ${plan_id}" >&2
    exit 1
  fi
  echo "${plan_id}" > "${ACTIVE_FILE}"
  echo "已切换当前激活计划: ${plan_id}"
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
