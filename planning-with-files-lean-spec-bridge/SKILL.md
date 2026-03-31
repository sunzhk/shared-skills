---
name: planning-with-files-lean-spec-bridge
description: >
  在已使用 planning-with-files-ext（doc/plans、hooks）的前提下，与 LeanSpec（specs/）做一键式桥接与流程编排：
  落地协作文档副本、创建/对齐 Spec 与 plan-id、写入 SpecRef/ExecutionPlan 双向引用、按清单执行而无需用户记步骤。
  本工作流的标准名称是「双轨协作」：规格轨（specs/）与执行轨（doc/plans/）并行，planning-with-files-zh 的纪律贯穿执行侧；勿与口语「三件套」混淆——后者在 planning-with-files 语境下通常指 task_plan/findings/progress 三文件。
  在用户提到双轨协作、双轨开需求、规执双轨、规格与执行双轨、LeanSpec 与 doc/plans 联动、SpecRef、同时建 spec 和 plan、桥接时使用。
  触发词：双轨协作、双轨开需求、规执双轨、规格执行双轨、LeanSpec doc/plans 联动、SpecRef、ExecutionPlan、桥接。
---

<!--
UpdatedAt: 2026-03-31 16:30:42
LatestChange: 规格步骤明确要求 Spec frontmatter 含官方示例中的 created（YYYY-MM-DD），避免协作生成漏字段。
-->

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
   - 若尚无对应 spec：创建或调用 `lean-spec specify …` / 手工建立 `specs/…` 文件，包含目标、场景、验收、非目标；**frontmatter 须含 `created`**，日期格式为 **`YYYY-MM-DD`**（与 [LeanSpec 指南示例](https://www.lean-spec.dev/zh-Hans/docs/guide/) 一致，如 `created: 2025-11-07`）。另可按需设 `status`、`priority`、`tags`、`depends_on` 等，以官方文档为准。

3. **执行计划（ext）**  
   - 运行 `./doc/plans/plan.sh new <plan-id>`（或等价），保证 **effective** 目录下存在 `task_plan.md`、`findings.md`、`progress.md`。  
   - 将 `ACTIVE` 设为本次 `plan-id`（`plan.sh new` 通常会设置）。

4. **双向轻量引用（核心桥接，禁止整文件覆盖同步）**  
   - 在 **effective** 的 `task_plan.md` **顶部**增加一行（路径按实际调整）：  
     `SpecRef: specs/.../README.md`  
   - 在 **对应 Spec 文件** 内增加一节或一行：  
     `ExecutionPlan: doc/plans/<plan-id>/`

5. **填充执行骨架**  
   - 在 `task_plan.md` 中把 LeanSpec 的验收项**映射**为 Phase/检查项（复制摘要即可，验收原文仍以 spec 为准）。  
   - 大块调研与外部原文只写入 `findings.md`。

6. **收尾**  
   - 提醒用户可选用：`lean-spec board`、`lean-spec ui` 做项目视图；执行中持续更新 `progress.md` 与阶段状态。

## 明确不做的事（避免增加心智负担以外的风险）

- **不要用脚本覆盖重写**整个 `task_plan.md`「从 LeanSpec 同步任务列表」——会破坏错误表、决策记录与 hook 友好结构。  
- **不要把不可信长原文**贴进 `task_plan.md`。  
- **不要**在未合并的情况下改写用户已有的 `.cursor/hooks.json`。

## 与 MCP 的关系

若用户已配置 LeanSpec 的 MCP（见 [指南 - AI 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/)），代理检索/更新 spec 时优先用 MCP；**`doc/plans/` 三文件**仍用读写文件 + ext hooks 维护。

## 维护说明

修改本 `SKILL.md` 时：更新文首 HTML 注释中的 `UpdatedAt`（用命令行 `date "+%Y-%m-%d %H:%M:%S"`）与 `LatestChange`。
