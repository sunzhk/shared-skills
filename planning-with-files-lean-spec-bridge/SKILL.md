---
name: planning-with-files-lean-spec-bridge
description: >
  ⚠️ 已废弃：本技能已合并至 lean-spec-planning-with-files-bridge。请使用新技能。
  路径：shared-skills/lean-spec-planning-with-files-bridge/SKILL.md
---

<!--
UpdatedAt: 2026-04-01 15:08:55
LatestChange: 已废弃——合并至 lean-spec-planning-with-files-bridge（一体化双轨协作技能）。
-->

> **⚠️ 已废弃**：本技能已合并至 **`lean-spec-planning-with-files-bridge`**。
> 新路径：`shared-skills/lean-spec-planning-with-files-bridge/SKILL.md`
> 新目录的 `bootstrap.sh` 已整合原 ext 的全部产物与本桥接技能的协作文档复制。

---

<!-- 以下为历史内容，仅供参考 -->


# planning-with-files + LeanSpec 桥接技能

## 术语：双轨协作（推荐口令用此名）

- **双轨协作**：**规格轨** — LeanSpec（`specs/`）；**执行轨** — planning-with-files-ext（`doc/plans/<plan-id>/`、hooks）；**纪律** — planning-with-files-zh（外部进 `findings.md`、防注入等）。桥接动作核心是 **`SpecRef` / `ExecutionPlan` 双向一行引用**。  
- **「三件套」**：在 planning-with-files / 团队口语里多指 **`task_plan.md` / `findings.md` / `progress.md` 三文件**，与本技能的 LeanSpec 桥接**不是同一概念**；文档与口令中**不要用「三件套」指代双轨协作**，以免 Agent 只建执行轨、漏掉 `specs/`。  
- 若用户只要文件规划、不要规格，应走 **planning-with-files-zh / ext**，**不要**用本技能冒充已完成规格轨。

## 目标

把 **LeanSpec**（`specs/` 规格真相源）与 **planning-with-files-ext**（`doc/plans/<plan-id>/` 执行真相源）的协作**程序化**：由代理按本技能执行，用户只需说意图（例如「**按双轨**为 auth 开新需求，plan-id `feat-auth`」），不必自己记顺序与字段名。

**planning-with-files-zh** 的纪律（外部内容进 `findings.md`、`task_plan.md` 防注入、两动作记发现等）在桥接流程中**一律遵守**；若仓库已安装该技能，复杂任务中应对照其全文。

## 前置条件（不满足则先说明再补做）

1. 目标仓库已运行 **planning-with-files-ext** 的 `bootstrap.sh`（存在 `doc/plans/plan.sh`、`doc/plans/ACTIVE` 机制、`.cursor/hooks` 等）。若未安装：先引导用户执行 ext 的 bootstrap，再继续桥接。
2. **LeanSpec**：仓库已有或可创建 `specs/`（`lean-spec init` 或等价结构）。若用户未装 CLI，可用 `npx lean-spec init` 或手工按 [LeanSpec 指南](https://www.lean-spec.dev/zh-Hans/docs/guide/) 建最小 spec 文件。
3. **（推荐）LeanSpec MCP**：若用户已在 Cursor/IDE 中配置 LeanSpec MCP（见下节），代理对**规格轨**优先通过 MCP 工具检索/更新 Spec；未配置时仍用**读文件 + CLI** 完成桥接，不阻塞流程。

## LeanSpec MCP（规格轨，推荐启用）

**定位**：在已配置 [MCP 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/usage/mcp-integration) 的前提下，代理对 **`specs/`** 的**发现、阅读、更新、校验、依赖与项目健康视图**优先通过 **LeanSpec MCP** 完成。与 **`SpecRef` / `ExecutionPlan` 一行引用**并存：MCP 减轻记路径、手改 frontmatter、按主题检索的负担；**一行引用**保证仓库内人类与无 MCP 场景仍能直接跳转。

**工作目录**：MCP 的 **cwd 须指向含 `specs/` 的 LeanSpec 项目根**。monorepo 时若规格在子包，应把 MCP 工作目录对准该子项目根，而非误指无 `specs/` 的仓库顶层。

**配置示例（Cursor `.mcp.json`）**（包名与参数以 [MCP 服务器参考](https://www.lean-spec.dev/zh-Hans/docs/reference/mcp-server) 为准，有变更时按官方文档调整）：

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

**工具分工（按场景选用）**

| 类别 | 典型工具 | 用途 |
|------|----------|------|
| 发现 | `list`、`search`、`deps` | 过滤列表、全文/语义检索、依赖与阻塞 |
| 查看 | `view`、`files`、`board`、`stats` | Spec 正文、子文件、看板与统计 |
| 修改 | `create`、`update`、`archive` | 新建 Spec、更新状态/优先级/标签等、归档 |
| 验证 | `validate`、`check` | 结构与质量、序列号等 |

**与执行轨的边界**：**`doc/plans/<plan-id>/`** 下的 **`task_plan.md` / `findings.md` / `progress.md`** 仍只通过**读写文件 + ext hooks** 维护；MCP **不**替代执行轨，也**不**用 MCP 整文件覆盖同步 `task_plan.md`（与下文「明确不做的事」一致）。

**嵌入代理流程的要点**

- **定规格 / 查重**：优先 `search` / `list`，避免重复建 Spec；新建可用 MCP `create` 或 CLI / 手工，再与 **`SpecRef`** 路径对齐。  
- **映射验收到 Phase 前**：用 `view`（或等价）拉取验收段落，减少漏项。  
- **阶段推进**：阶段开始前可用 `deps` 确认依赖；阶段结束若需反映规格状态用 `update`；里程碑或合并前可 `validate`。  
- **收尾**：可选用 `board` / `stats` 与执行轨 `progress.md` 对照「规格侧完成度」；CLI 的 `lean-spec ui` 等仍可按官方指南使用。

**注意**：`validate` 校验的是 **Spec 与项目约定**，**不**等同于业务层验收已全部通过；业务验收仍须测试/审查并与 Spec 验收条款对照。

## 一键落地协作文档（可选，降低查阅成本）

**推荐（多项目共享）**：在业务项目根 `README.md` 的配置块中设 `lean_spec_bridge_doc=1`，并执行 shared-skills 根目录的 `configure-from-readme.sh`（见 `README.human.md`「README 驱动一键配置」），无需单独记本脚本路径。

**单独执行**（将路径换成本机 monorepo 中本技能目录）：

```bash
bash /path/to/shared-skills/planning-with-files-lean-spec-bridge/bootstrap-bridge.sh
# 或显式指定项目根：
bash .../bootstrap-bridge.sh /path/to/target/repo
```

作用：在 `doc/plans/COORDINATION_LEANSPEC.md` 写入（复制）权威协作文档副本，便于人类与代理在仓库内就近阅读。**不修改** `.cursor/rules` 或 hooks，避免与已有 `hooks.json` 冲突。

## 代理标准流程（用户要 **LeanSpec + doc/plans 联动** 开功能时执行）

按顺序完成；每步可简短向用户确认规格名 / plan-id（或由用户提示给出）。

1. **确定标识**  
   - `plan-id`：符合 ext 规则的一至两段路径（如 `feat-auth` 或 `feat-auth/T1`）。  
   - Spec 路径：如 `specs/001-feat-auth/README.md`（以仓库实际 LeanSpec 约定为准）。

2. **规格（LeanSpec）**  
   - 若已配置 MCP：先用 `search` / `list` 查是否已有相关 Spec，避免重复。  
   - 若尚无对应 spec：创建或调用 `lean-spec specify …` / MCP `create` / 手工建立 `specs/…` 文件，包含目标、场景、验收、非目标；**frontmatter 须含 `created`**，日期格式为 **`YYYY-MM-DD`**（与 [LeanSpec 指南示例](https://www.lean-spec.dev/zh-Hans/docs/guide/) 一致，如 `created: 2025-11-07`）。另可按需设 `status`、`priority`、`tags`、`depends_on` 等，以官方文档为准。

3. **执行计划（ext）**  
   - 运行 `./doc/plans/plan.sh new <plan-id>`（或等价），保证 **effective** 目录下存在 `task_plan.md`、`findings.md`、`progress.md`。  
   - 将 `ACTIVE` 设为本次 `plan-id`（`plan.sh new` 通常会设置）。

4. **双向轻量引用（核心桥接，禁止整文件覆盖同步）**  
   - 在 **effective** 的 `task_plan.md` **顶部**增加一行（路径按实际调整）：  
     `SpecRef: specs/.../README.md`  
   - 在 **对应 Spec 文件** 内增加一节或一行：  
     `ExecutionPlan: doc/plans/<plan-id>/`

5. **填充执行骨架**  
   - 在 `task_plan.md` 中把 LeanSpec 的验收项**映射**为 Phase/检查项（复制摘要即可，验收原文仍以 spec 为准）；若已配置 MCP，拉取验收段落时优先 `view`（或 `search`）而非仅凭记忆。  
   - 大块调研与外部原文只写入 `findings.md`。

6. **收尾**  
   - 提醒用户可选用：`lean-spec board`、`lean-spec ui` 做项目视图；已配置 MCP 时可用 MCP 的 `board` / `stats` 与 CLI 互补。执行中持续更新 `progress.md` 与阶段状态；规格状态变更可用 MCP `update` 与 Spec 正文人工修订配合。

## 明确不做的事（避免增加心智负担以外的风险）

- **不要用脚本覆盖重写**整个 `task_plan.md`「从 LeanSpec 同步任务列表」——会破坏错误表、决策记录与 hook 友好结构。  
- **不要把不可信长原文**贴进 `task_plan.md`。  
- **不要**在未合并的情况下改写用户已有的 `.cursor/hooks.json`。

## 维护说明

修改本 `SKILL.md` 时：更新文首 HTML 注释中的 `UpdatedAt`（用命令行 `date "+%Y-%m-%d %H:%M:%S"`）与 `LatestChange`。
