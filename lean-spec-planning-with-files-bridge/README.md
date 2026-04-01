<!--
UpdatedAt: 2026-04-01 15:08:55
LatestChange: 合并 planning-with-files-ext 与 planning-with-files-lean-spec-bridge 为一体化双轨技能；新增阶段验收检查单与常见偏差修正。
-->

# lean-spec-planning-with-files-bridge

一体化双轨协作技能：将 **LeanSpec**（`specs/` 规格轨）与 **planning-with-files**（`doc/plans/` 执行轨）合为一体。一键落地 Cursor 规则、hooks（含 **SpecRef 感知**）、计划脚本与协作文档；规格轨推荐配置 **LeanSpec MCP**。

## 目录内容

- `SKILL.md`：**Cursor Agent 技能**入口（双轨标准流程、DoD、MCP 工具时机表、与 `planning-with-files-zh` 的关系）。
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

下面按「**创建计划 → 审阅 → 切换计划 → 分阶段实施 → 阶段验收 → 收尾**」给出可直接改写的提示词；将占位符换成你的功能名与 `plan-id`（如 `feat-auth`，须符合路径规则）。

**前提（一次性）**：目标仓库已执行本技能的 `bootstrap.sh`（存在 `doc/plans/plan.sh`、`ACTIVE` 等）；已按上文配置 **LeanSpec MCP**（推荐）；仓库已有或可创建 **`specs/`**。

| 步骤 | 你要做的事 | 提示词示例（发给 Agent） |
|------|------------|-------------------------|
| 1. 开双轨 | 一次性建立 Spec + 执行计划 + 双向引用 + 阶段骨架 | `按双轨协作为「<功能简述>」开需求：plan-id 用 <plan-id>。请先通过 LeanSpec MCP 做 search/list 避免重复 spec；再建或对齐 specs/ 下对应 README（含目标、场景、验收、非目标，frontmatter 含 created: YYYY-MM-DD）；再执行 ./doc/plans/plan.sh new <plan-id>；在 effective 的 task_plan.md 顶部写 SpecRef，在 Spec 里写 ExecutionPlan；把验收项映射成若干 Phase，调研长文只进 findings.md。` |
| 2. 审计划 | 你打开 `doc/plans/<plan-id>/task_plan.md` 与对应 Spec，改到满意 | （自行编辑保存，无需固定句式。） |
| 3. 切换当前计划 | 让执行轨对准本次目录 | `[计划: <plan-id>]` 或：`将 ACTIVE 设为 <plan-id>，我要在该计划上工作。` |
| 4. 实施阶段 1 | Agent 按 `task_plan.md` 做阶段 1 | `当前 effective 计划是 <plan-id>。请执行 task_plan.md 中的阶段 1；工具编辑后更新 progress.md；需要对照验收时通过 SpecRef 或 LeanSpec MCP view 读取 spec，勿把长原文贴进 task_plan.md。` |
| 5. 阶段验收与推进 | 对照 Spec 验收 + 审查实现，再进入下一阶段 | `阶段 1 的开发工作已按你的理解完成。请对照 Spec 中与阶段 1 相关的验收项做自检，更新 progress.md 与 task_plan 中阶段状态；若通过，准备执行阶段 2。若有偏差，先在 findings.md 记一笔再改 spec 或计划。` |
| 6. 重复 4～5 | 直到所有阶段完成 | 将提示词里的「阶段 1 / 阶段 2」依次数递增。 |
| 7. 收尾 | 规格状态 + 结构校验 + 执行侧闭环 | `双轨计划 <plan-id> 各阶段已完成并通过审查。请：用 LeanSpec MCP 或 CLI 将对应 Spec 标为合适终态（如 complete）、运行 validate；确认 doc/plans 下 progress.md 与 task_plan 阶段状态已闭合；简述规格与执行轨是否一致。` |

**说明**：`validate` / MCP 校验的是 **Spec 与项目约定**；**业务是否满足验收**仍依赖测试与你的审查。

---

## 阶段验收检查单

每个阶段完成时，Agent 按 DoD（Definition of Done）依次执行：

| # | 检查项 | 怎么做 |
|---|--------|--------|
| 1 | `task_plan.md` 状态标记 | 当前 Phase → `complete`，下一 Phase → `in_progress` |
| 2 | `progress.md` 日志 | 追加完成时间、关键产出、影响文件 |
| 3 | SpecRef 自检 | 若含 `SpecRef:`，读取 Spec 对应验收项逐条确认 |
| 4 | 偏差处理 | 若发现偏差，记 `findings.md` 并修正 |
| 5 | Hook 提示响应 | hooks 会自动输出 SpecRef 提醒，Agent 需遵从 |

---

## 常见偏差与修正

| 偏差现象 | 原因 | 修正方式 |
|---------|------|---------|
| Agent 只建了 `doc/plans/`，没建 `specs/` | 口令未触发双轨 | 使用「按双轨」/「双轨开需求」等触发词 |
| `task_plan.md` 无 `SpecRef:` 行 | 跳过了桥接步骤 | 手动在顶部补 `SpecRef: specs/.../README.md` |
| 阶段完成但未对照 Spec 验收 | Hook 提醒被忽略 | 显式要求「对照 Spec 验收项自检」 |
| 外部长原文被塞进 `task_plan.md` | 违反安全边界 | 移到 `findings.md`，`task_plan.md` 只留摘要 |
| MCP 调用失败 | 配置问题 | 核对 `.mcp.json`、`npx` 可用性、`specs/` 位置 |

---

## 权威协作文档

与本技能同目录：`planning-with-files-and-lean-spec-collaboration.md`。bootstrap 会将其复制到 `doc/plans/COORDINATION_LEANSPEC.md`。

更完整的代理规则、DoD、MCP 工具时机表与禁止项见同目录 **`SKILL.md`**。
