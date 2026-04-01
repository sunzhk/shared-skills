<!--
UpdatedAt: 2026-04-01 15:08:55
LatestChange: 已废弃——合并至 lean-spec-planning-with-files-bridge（一体化双轨协作技能）。
-->

> **⚠️ 已废弃**：本目录已合并至 **`lean-spec-planning-with-files-bridge`**。
> 新路径：`shared-skills/lean-spec-planning-with-files-bridge/`

---

<!-- 以下为历史内容，仅供参考 -->

# planning-with-files-lean-spec-bridge

在 **planning-with-files-ext** 与 **LeanSpec** 之间做流程编排：由 Cursor 技能触发时代理按清单完成 Spec ↔ `doc/plans/` 桥接；**规格轨推荐配置 LeanSpec MCP**（见下文与 `SKILL.md`）。可选脚本把协作文档复制进仓库 `doc/plans/COORDINATION_LEANSPEC.md`。

## LeanSpec MCP 配置说明

**作用**：让 Agent 通过 MCP 检索、查看、更新 `specs/`（如 `list` / `search` / `view` / `update` / `deps` / `validate` 等），减少手抄路径与漏读验收；与 `task_plan.md` 顶部的 **`SpecRef:`** 一行引用**同时使用**（人类与无 MCP 场景仍可直链文件）。详见 [LeanSpec MCP 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/usage/mcp-integration) 与 [MCP 服务器参考](https://www.lean-spec.dev/zh-Hans/docs/reference/mcp-server)（工具名与包名以官方为准）。

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

**生效**：保存配置后按 Cursor 习惯 **重载窗口或重启**，使 MCP 载入。

**可选自检**：配置完成后，在对话中试发「列出本仓库 LeanSpec 规格」或「用 MCP 搜索与 XXX 相关的 spec」，确认 Agent 能调用 MCP（若失败，核对路径、`npx` 与官方文档中的包名/参数是否更新）。

---

## 双轨模式使用流程（提示词示例）

下面按「**创建计划 → 审阅 → 切换计划 → 分阶段实施 → 阶段验收 → 收尾**」给出可直接改写的提示词；将占位符换成你的功能名与 `plan-id`（如 `feat-auth`，须符合 ext 路径规则）。

**前提（一次性）**：目标仓库已执行 **planning-with-files-ext** 的 `bootstrap.sh`（存在 `doc/plans/plan.sh`、`ACTIVE` 等）；已按上文配置 **LeanSpec MCP**（推荐）；仓库已有或可创建 **`specs/`**。

| 步骤 | 你要做的事 | 提示词示例（发给 Agent） |
|------|------------|-------------------------|
| 1. 开双轨 | 一次性建立 Spec + 执行计划 + 双向引用 + 阶段骨架 | `按双轨协作为「<功能简述>」开需求：plan-id 用 <plan-id>。请先通过 LeanSpec MCP 做 search/list 避免重复 spec；再建或对齐 specs/ 下对应 README（含目标、场景、验收、非目标，frontmatter 含 created: YYYY-MM-DD）；再执行 ./doc/plans/plan.sh new <plan-id>；在 effective 的 task_plan.md 顶部写 SpecRef，在 Spec 里写 ExecutionPlan；把验收项映射成若干 Phase，调研长文只进 findings.md。` |
| 2. 审计划 | 你打开 `doc/plans/<plan-id>/task_plan.md` 与对应 Spec，改到满意 | （自行编辑保存，无需固定句式。） |
| 3. 切换当前计划 | 让执行轨对准本次目录 | `[计划: <plan-id>]` 或说明：`将 ACTIVE 设为 <plan-id>（或 ./doc/plans/plan.sh use <plan-id>），我要在该计划上工作。` |
| 4. 实施阶段 1 | Agent 按 `task_plan.md` 做阶段 1 | `当前 effective 计划是 <plan-id>。请执行 task_plan.md 中的阶段 1；工具编辑后更新 progress.md；需要对照验收时通过 SpecRef 或 LeanSpec MCP view 读取 spec，勿把长原文贴进 task_plan.md。` |
| 5. 阶段验收与推进 | 对照 Spec 验收 + 审查实现，再进入下一阶段 | `阶段 1 的开发工作已按你的理解完成。请对照 Spec 中与阶段 1 相关的验收项做自检，更新 progress.md 与 task_plan 中阶段状态；若通过，准备执行阶段 2。若有偏差，先在 findings.md 记一笔再改 spec 或计划。` |
| 6. 重复 4～5 | 直到所有阶段完成 | 将提示词里的「阶段 1 / 阶段 2」依次数递增。 |
| 7. 收尾 | 规格状态 + 结构校验 + 执行侧闭环 | `双轨计划 <plan-id> 各阶段已完成并通过审查。请：用 LeanSpec MCP 或 CLI 将对应 Spec 标为合适终态（如 complete）、运行 validate；确认 doc/plans 下 progress.md 与 task_plan 阶段状态已闭合；简述规格与执行轨是否一致。` |

**说明**：`validate` / MCP 校验的是 **Spec 与项目约定**；**业务是否满足验收**仍依赖测试与你的审查。若某阶段要求「必须人工点头再往下」，在 `task_plan.md` 该 Phase 的完成条件里写清楚即可。

---

## 安装（Cursor 技能）

- **个人全局**：将本目录复制或软链到 `~/.cursor/skills/planning-with-files-lean-spec-bridge/`。
- **单仓库**：复制或软链到该仓库的 `.cursor/skills/planning-with-files-lean-spec-bridge/`。

更完整的代理规则、工具表与禁止项见同目录 **`SKILL.md`**。

## 脚本（人类或代理执行）

**多项目推荐**：在业务项目 README 配置块中设 `lean_spec_bridge_doc=1`，并执行 `bash .cursor/shared-skills/configure-from-readme.sh`（见 `README.human.md`）。

**单独执行**：

```bash
bash /path/to/planning-with-files-lean-spec-bridge/bootstrap-bridge.sh /path/to/target/repo
```

权威协作文档与本技能同目录：`planning-with-files-and-lean-spec-collaboration.md`。
