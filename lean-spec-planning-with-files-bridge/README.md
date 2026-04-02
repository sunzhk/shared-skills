<!--
UpdatedAt: 2026-04-02 16:49:40 +0800
LatestChange: 补全双轨流程中的 Spec 状态流转：将 draft 与 in-progress 纳入主流程，并明确 archived 为独立终态。
-->

# lean-spec-planning-with-files-bridge

一体化双轨协作技能：将 **LeanSpec**（`specs/` 规格轨）与 **planning-with-files**（`doc/plans/` 执行轨）合为一体。一键落地 Cursor 规则、hooks（含 **SpecRef 感知**）、计划脚本与协作文档；规格轨推荐配置 **LeanSpec MCP**。

## 目录内容

- `SKILL.md`：**Cursor Agent 技能**入口（双轨标准流程、DoD、阶段闭环策略、MCP 工具时机表、与 `planning-with-files-zh` 的关系）。
- `bootstrap.sh`：一键把模板写入目标项目（含 hooks、rules、脚本、协作文档）。
- `planning-with-files-and-lean-spec-collaboration.md`：权威协作文档（bootstrap 会复制到 `doc/plans/COORDINATION_LEANSPEC.md`）。
- `README.md`：本文件——人类可读的目录说明、安装方式、MCP 配置与双轨使用流程。

---

## 安装

### 作为 Cursor 技能

- **个人全局**：将本目录复制或软链到 `~/.cursor/skills/lean-spec-planning-with-files-bridge/`（目录内须含 `SKILL.md`）。
- **单仓库**：复制或软链到该仓库的 `.cursor/skills/lean-spec-planning-with-files-bridge/`。

### 多项目共享 shared-skills（推荐）

业务项目根 `README.md` 加入 `<!-- shared-skills-config` … `lean_spec_planning=1` … `-->`，并执行 shared-skills 根目录的 `configure-from-readme.sh`（典型：`bash .cursor/shared-skills/configure-from-readme.sh`）。详见上级目录 `README.human.md`「README 驱动一键配置」。

### 单项目直接执行 bootstrap

```bash
bash /path/to/lean-spec-planning-with-files-bridge/bootstrap.sh
# 或显式指定目标根目录：
bash /path/to/lean-spec-planning-with-files-bridge/bootstrap.sh /path/to/target/repo
# 如不希望自动安装 planning-with-files-zh：
bash /path/to/lean-spec-planning-with-files-bridge/bootstrap.sh /path/to/target/repo --no-install-planning-with-files-zh
```

### 落地产物

- `.cursor/rules/planning-with-files.mdc`
- `.cursor/hooks.json` 与 `.cursor/hooks/*.sh`（含 SpecRef 感知）
- `doc/plans/new-plan.sh`、`doc/plans/plan.sh`、`doc/plans/planning-paths.sh`
- `doc/plans/COORDINATION_LEANSPEC.md`（协作文档副本）
- （可选）`.cursor/skills/planning-with-files-zh/SKILL.md`

### 注意

- 默认三文件工作流（`task_plan.md`/`findings.md`/`progress.md`）。
- `execution_brief.md` 为按需输出，不强制创建。
- 默认检查本机 `~/.agents/skills/planning-with-files-zh/SKILL.md`，若存在则自动安装。
- **若目标项目已有 `.cursor/hooks.json`**：脚本做**字节级比对**；**完全一致**则继续；**不一致则立即退出**并打印 diff。

---

## LeanSpec MCP 配置说明

**作用**：让 Agent 通过 MCP 检索、查看、更新 `specs/`（如 `list` / `search` / `view` / `update` / `deps` / `validate` 等），减少手抄路径与漏读验收；与 `task_plan.md` 顶部的 **`SpecRef:`** 一行引用**同时使用**。详见 [LeanSpec MCP 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/usage/mcp-integration) 与 [MCP 服务器参考](https://www.lean-spec.dev/zh-Hans/docs/reference/mcp-server)。

**Cursor（项目根 `.mcp.json`）**：在**含 `specs/` 的业务仓库根目录**创建或编辑 `.mcp.json`，例如：

```json
{
  "mcpServers": {
    "lean-spec": {
      "command": "npx",
      "args": ["-y", "@leanspec/mcp"]
    }
  }
}
```

**工作目录**：MCP 进程的工作目录应对准 **LeanSpec 项目根**（该目录下存在 `specs/`）。若使用 **monorepo**，规格在子包时勿把 MCP 指到无 `specs/` 的仓库顶层。

**生效**：保存配置后 **重载窗口或重启 Cursor**。

**可选自检**：发送「列出本仓库 LeanSpec 规格」确认 Agent 能调用 MCP。

---

## 双轨模式使用流程（提示词示例）

下面按「**创建计划 → 审阅 → 切换计划 → 分阶段实施与阶段验收（默认合并闭环）→ 收尾**」给出可直接改写的提示词；将占位符换成你的功能名与 `plan-id`（如 `feat-auth`，须符合路径规则）。

**前提（一次性）**：目标仓库已执行本技能的 `bootstrap.sh`（存在 `doc/plans/plan.sh`、`ACTIVE` 等）；已按上文配置 **LeanSpec MCP**（推荐）；仓库已有或可创建 **`specs/`**。

| 步骤 | 你要做的事 | 提示词示例（发给 Agent） |
|------|------------|-------------------------|
| 1. 开双轨（draft） | 一次性建立 Spec（先置为 draft）+ 执行计划 + 双向引用 + 阶段骨架 | `按双轨协作为「<功能简述>」开需求：plan-id 用 <plan-id>。请先通过 LeanSpec MCP 做 search/list 避免重复 spec；再建或对齐 specs/ 下对应 README（含目标、场景、验收、非目标，frontmatter 含 created: YYYY-MM-DD，status 先设为 draft）；再执行 ./doc/plans/plan.sh new <plan-id>；在 effective 的 task_plan.md 顶部写 SpecRef，在 Spec 里写 ExecutionPlan；把验收项映射成若干 Phase，调研长文只进 findings.md。` |
| 2. 审计划 | 你打开 `doc/plans/<plan-id>/task_plan.md` 与对应 Spec，改到满意 | （自行编辑保存，无需固定句式。） |
| 3. 切换当前计划 | 让执行轨对准本次目录 | `[计划: <plan-id>]` 或：`将 ACTIVE 设为 <plan-id>，我要在该计划上工作。` |
| 4. 启动实施（draft → planned → in-progress） | 在开始编码/落地前，冻结规格为 planned；首次实际开始实施时置为 in-progress | `当前 effective 计划是 <plan-id>。开始实施前请先确认 Spec 已从 draft 置为 planned（表示规格已冻结可执行）；当你准备开始实际实现/改代码时，将 Spec status 更新为 in-progress；然后执行 task_plan.md 中的阶段 1。` |
| 5. 实施+验收阶段 N（默认） | 单次会话完成实施、Spec 自检与三文件更新 | `请执行 task_plan.md 中的阶段 <N>；工具编辑后更新 progress.md；阶段收尾时对照 SpecRef/MCP view 中与本阶段相关的验收项自检，无偏差则一次性更新 progress（含执行结果与 Spec 对照结论）和 task_plan 阶段状态；不要重复已做过的 grep/compile（除非源码或 Spec 有变更）。勿把长原文贴进 task_plan.md。` |
| 4a. 独立验收（可选） | 仅在有偏差/需独立签认时使用 | `阶段 1 存在偏差，请单独对照 Spec 验收项自检；以 Spec 条款 checklist 为主，不重复已做过的静态检索与构建；偏差先记 findings.md 再修正。` |
| 6. 重复 5～4a | 直到所有阶段完成 | 将提示词里的「阶段 1 / 阶段 2」依次数递增；默认用步骤 5 的合并闭环提示词，仅在需要时用独立验收（步骤 4a）。 |
| 7. 收尾（in-progress → complete；通常与末尾阶段合并） | 规格状态 + 结构校验 + 执行侧闭环 | `双轨计划 <plan-id> 各阶段已完成并通过审查。请：用 LeanSpec MCP 或 CLI 将对应 Spec 从 in-progress 更新为 complete、运行 validate；确认 doc/plans 下 progress.md 与 task_plan 阶段状态已闭合；简述规格与执行轨是否一致。` |

**收尾合并**：步骤 7 的操作通常在 `task_plan.md` 最后一个阶段（默认阶段 5）中一并完成。仅在以下情况单独发送步骤 7 口令：

- 末尾阶段未使用 MCP（需补 validate）
- 末尾阶段由不同会话/人员执行，需独立确认
- Spec 终态需审批后再标记

**说明**：`validate` / MCP 校验的是 **Spec 与项目约定**；**业务是否满足验收**仍依赖测试与你的审查。

---

## 阶段验收速查

完整 DoD 见 `SKILL.md`「阶段完成定义（DoD）」。速记：

1. `task_plan.md` 阶段状态 → `complete`
2. `progress.md` 追加（含执行结果 **与** Spec 对照结论，合并闭环时一条写完）
3. 若含 `SpecRef:`：对照 Spec 验收项勾选（合并闭环时在实施收尾一并完成）
4. 偏差 → `findings.md`
5. 若进入实施：Spec 状态应为 `in-progress`；收尾交付：Spec 状态应为 `complete`（`archived` 为独立终态，不纳入主流程）

hooks 会自动输出 SpecRef 提醒，Agent 须遵从；合并闭环（单次会话实施+自检）即满足门禁，无需为验收再开一轮对话（除非步骤 4a）。

---

## 常见偏差与修正

| 偏差现象 | 原因 | 修正方式 |
|---------|------|---------|
| Agent 只建了 `doc/plans/`，没建 `specs/` | 口令未触发双轨 | 使用「按双轨」/「双轨开需求」等触发词 |
| `task_plan.md` 无 `SpecRef:` 行 | 跳过了桥接步骤 | 手动在顶部补 `SpecRef: specs/.../README.md` |
| 阶段完成但未对照 Spec 验收 | Hook 提醒被忽略 | 显式要求「对照 Spec 验收项自检」 |
| 外部长原文被塞进 `task_plan.md` | 违反安全边界 | 移到 `findings.md`，`task_plan.md` 只留摘要 |
| MCP 调用失败 | 配置问题 | 核对 `.mcp.json`、`npx` 可用性、`specs/` 位置 |
| 执行与验收分两次会话，导致重复 grep/compile/progress | 沿用旧提示词 | 使用合并闭环提示词（步骤 4）；仅在偏差时用独立验收（步骤 4a） |

---

## 权威协作文档

与本技能同目录：`planning-with-files-and-lean-spec-collaboration.md`。bootstrap 会将其复制到 `doc/plans/COORDINATION_LEANSPEC.md`。

更完整的代理规则、DoD、MCP 工具时机表与禁止项见同目录 **`SKILL.md`**。
