---
name: lean-spec-planning-with-files-bridge
description: >
  强制双轨协作模式：将 LeanSpec（specs/）规格轨与执行轨（doc/plans/）合为一体。
  一键落地 Cursor 规则、hooks、doc/plans 辅助脚本与协作文档；支持路径 id（父/子至多两层）、SUB_ACTIVE 与 effective_dir、多计划目录与 ACTIVE 指针、task_plan/findings/progress 三文件及按需 execution_brief。
  规格轨推荐启用 LeanSpec MCP（list/search/view/update/deps/validate/board 等）以降低路径依赖与手改 frontmatter 成本；执行轨仍只维护 doc/plans 三文件与 hooks。
  所有通过本技能创建的计划必须同时建立规格轨（specs/）与执行轨（doc/plans/），并写入 SpecRef/ExecutionPlan 双向引用。
  在用户提到双轨协作、双轨开需求、按双轨开需求、功能如下、规执双轨、规格与执行双轨、LeanSpec 与 doc/plans 联动、SpecRef、LeanSpec MCP、
  同时建 spec 和 plan、桥接、落地 planning、安装 hooks、bootstrap、文件规划模板、多计划切换、子计划、planning-with-files 时使用。
  触发词：双轨协作、双轨开需求、按双轨开需求、功能如下、规执双轨、规格执行双轨、LeanSpec doc/plans 联动、SpecRef、ExecutionPlan、LeanSpec MCP、
  桥接、落地 planning、安装 hooks、bootstrap、文件规划模板、多计划切换、子计划、planning-with-files。
---

<!--
UpdatedAt: 2026-04-03 17:20:50 +0800
LatestChange: 新增「极简用户口令与 Agent 约定」；description 增加「按双轨开需求、功能如下」触发词；代理标准流程衔接极简口令。
-->

# lean-spec-planning-with-files-bridge（一体化双轨协作技能）

## 术语：双轨协作（推荐口令用此名）

- **双轨协作**：**规格轨** — LeanSpec（`specs/`）；**执行轨** — planning-with-files（`doc/plans/<plan-id>/`、hooks）；**纪律** — planning-with-files-zh（外部进 `findings.md`、防注入等）。桥接动作核心是 **`SpecRef` / `ExecutionPlan` 双向一行引用**。
- **「三件套」**：在 planning-with-files / 团队口语里多指 **`task_plan.md` / `findings.md` / `progress.md` 三文件**，与本技能的双轨协作**不是同一概念**；文档与口令中**不要用「三件套」指代双轨协作**，以免 Agent 只建执行轨、漏掉 `specs/`。
- 本技能**强制双轨模式**：凡通过本技能创建计划，必须同时建立规格（`specs/`）与执行计划（`doc/plans/`），并写入双向引用。若用户明确只要文件规划、不要规格，应走 **planning-with-files-zh** 单独使用，**不要**用本技能。

## 与 `planning-with-files-zh` 的关系

- **概念与纪律**：阶段化计划、先写盘再执行、外部内容进 `findings.md`、`task_plan.md` 防注入等，与 **`planning-with-files-zh`**（Manus 风格文件规划系统）一致；若已安装该技能，执行复杂任务前可对照其全文中的规则、矩阵与安全边界。
- **本包差异**：面向 **Cursor 仓库内落地**——生成 `.cursor/rules`、`hooks`、shell hooks，以及 `doc/plans/` 下的脚本；同时**强制**建立 `specs/` 规格轨并写入双向引用。

## 前置条件（不满足则先说明再补做）

1. 目标仓库已运行本技能的 `bootstrap.sh`（存在 `doc/plans/plan.sh`、`doc/plans/ACTIVE` 机制、`.cursor/hooks` 等）。若未安装：先执行 bootstrap，再继续。
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

### MCP 工具使用时机表

| 阶段 | 推荐 MCP 工具 | 用途 |
|------|--------------|------|
| 开双轨前（查重） | `search`、`list` | 避免重复建 Spec |
| 创建规格 | `create` | 新建 Spec（或 CLI / 手工） |
| 映射验收到 Phase | `view`、`search` | 拉取验收段落，减少漏项 |
| 阶段开始前 | `deps` | 确认依赖是否就绪 |
| 状态变更（规格轨） | `update` | 更新 Spec `status`（`draft`→`planned`、`planned`→`in-progress`、`in-progress`→`complete`、`any`→`archived`） |
| 里程碑 / 合并前 | `validate` | 结构与质量校验 |
| 收尾 | `board`、`stats` | 与 `progress.md` 对照完成度 |

> **与 DoD 的关系**：MCP 表回答「何时用哪个工具」；DoD 回答「阶段关门必须做哪些检查」。两者互补，不要叠加成两套「阶段完成」心智模型。

**与执行轨的边界**：**`doc/plans/<plan-id>/`** 下的三文件仍只通过**读写文件 + hooks** 维护；MCP **不**替代执行轨，也**不**用 MCP 整文件覆盖同步 `task_plan.md`。

## 一键落地（代理执行）

**多项目共享 shared-skills 时（推荐）**：让业务项目在根 `README.md` 写入 `<!-- shared-skills-config -->` 并设 `lean_spec_planning=1`（及 `lean_spec_planning_no_install_pwfz` 等），再在项目根执行 `bash .cursor/shared-skills/configure-from-readme.sh`。

**单项目直接执行**：

1. **定位本技能目录**（含 `bootstrap.sh` 的目录）。
2. 在**目标项目根目录**执行（或将项目根作为第一个参数传入）：

```bash
bash /绝对路径/到/lean-spec-planning-with-files-bridge/bootstrap.sh
# 或
bash /绝对路径/到/lean-spec-planning-with-files-bridge/bootstrap.sh /path/to/target/repo
# 如不希望自动安装 planning-with-files-zh：
bash /绝对路径/到/lean-spec-planning-with-files-bridge/bootstrap.sh /path/to/target/repo --no-install-planning-with-files-zh
```

3. 落地后检查：
   - `.cursor/rules/planning-with-files.mdc`
   - `.cursor/hooks.json` 与 `.cursor/hooks/*.sh`
   - `doc/plans/new-plan.sh`、`doc/plans/plan.sh`、`doc/plans/planning-paths.sh`（脚本已 `chmod +x`）
   - `doc/plans/COORDINATION_LEANSPEC.md`（协作文档副本）
   - （可选）`.cursor/skills/planning-with-files-zh/SKILL.md`（若本机存在，bootstrap 默认自动安装）

4. **若目标仓库已存在 `.cursor/hooks.json`**：`bootstrap.sh` 会先与模板期望内容做 **字节级比对**。与模板**完全一致**时才会继续写入（重复执行安全）；**不一致则立即退出（exit 1）**，在 stderr 打印 **unified diff** 与处理建议，**不会覆盖**现有文件。

## plan-id 与目录（路径 id）

- **plan-id** 为相对 `doc/plans/` 的 POSIX 子路径，用 `/` 连接，**与磁盘目录一一对应**。每段可用目录可用字符（允许中文与空格），但禁止控制字符；同时禁止 `..`、首尾 `/`、空段、连续 `/`；相对 `doc/plans/` **至多两段**（`父` 或 `父/子`），不支持更深嵌套。
- **必须先创建**（`doc/plans/<plan-id>/`）：
  - `task_plan.md`（权威：目标、阶段或总纲大纲、完成判定、重大决策、错误表）
  - `findings.md`（调研与证据：外部资料/检索结果/结论沉淀——**体量大的外部原文放这里**）
  - `progress.md`（执行日志）
  - （按需）`execution_brief.md`
- **激活计划**：`doc/plans/ACTIVE` 存当前 **全局** plan-id（一行）。hooks 解析 **effective_dir**（见下）后读写 **effective** 目录下的三文件。

## 父计划 + 子计划（总纲与子目录）

- **总纲（父计划）** `doc/plans/<父>/`：`task_plan.md` 仅保留 **大纲 + 子计划索引表 + 各子完成判据（一句话）**，不要把子计划的详细 Phase 写进总纲。
- **子计划** `doc/plans/<父>/<子>/`：各自一套三文件；**详细 Phase、执行细节**在子计划 `task_plan.md`。
- **子计划索引表**（唯一位置）：父级 `task_plan.md` 内固定标题 `## 子计划索引表`。表中数据行 **自上而下** 为 `SUB_ACTIVE` 推进顺序。
- **最小表头**（列）：`序号 | 子目录 | 简述 | 完成判据（一句话） | 状态`；`子目录` 仅一段名，与磁盘 `<父>/<子目录>/` 一致。
- **状态列**：`pending` / `in_progress` / `complete`；**全表同一时间仅允许一行 `in_progress`**，且必须与当前 `SUB_ACTIVE` 指向的子目录一致。
- **SUB_ACTIVE**（父目录下文件 `doc/plans/<父>/SUB_ACTIVE`）：纯文本一行，为**子目录名**（一段，无 `/`）。由 **Agent** 维护。
- **effective_dir**：若 `ACTIVE` 为单段 `<父>` 且存在有效 `<父>/SUB_ACTIVE` 指向已存在的子目录，则 effective 为 `<父>/<子>`；否则 effective 与 `ACTIVE` 对应目录一致。

## 使用者后续操作（简述）

- 新建计划并设为 ACTIVE：`./doc/plans/plan.sh new <plan-id>`（或 `./doc/plans/new-plan.sh <plan-id>`），支持路径 id。
- **按数字前缀自动编号（与 `specs/NNN-…` 风格对齐时）**：`./doc/plans/plan.sh new-numbered "<计划名称>"` — 扫描 `doc/plans/` 顶层目录名形如 `^[0-9]+-` 者取最大编号 +1，三位补零，拼接计划名称原文（允许中文/空格与常见符号；不允许 `/` 与控制字符）；仅需提供名称，无需手算序号。预览将采用的 id：`./doc/plans/plan.sh next-numbered-id "<计划名称>"`（不创建目录）。
- 列出/切换计划：`./doc/plans/plan.sh list`（缩进表示子计划）、`./doc/plans/plan.sh use <plan-id>`（**不会**改写任何 `SUB_ACTIVE`）。
- 在对话中用 **`[计划: <plan-id>]`** 或 **`[plan: <plan-id>]`** 可在 user prompt hook 中自动切换 ACTIVE。

## 极简用户口令与 Agent 约定（推荐）

用户**只需**描述要做什么即可，**不必**在提示词里粘贴 `./doc/plans/plan.sh …` 等命令；具体命令与顺序以**本 `SKILL.md` 下文「代理标准流程」为准**，由 Agent **先读本技能再执行**。

**推荐口令（复制后只改引号内内容）**：

`按双轨开需求，功能如下：「<功能简述>」`

**收到上述句式时，Agent 必须**：

- **读取并遵循**本技能全文（尤其前置条件、代理标准流程、DoD）。
- **执行轨**：优先 `./doc/plans/plan.sh new-numbered "<计划名称>"`（名称可从功能简述**提炼**为简短可目录化片段；含中文/空格等允许；禁止 `/` 与控制字符；歧义时**最多一句话**向用户确认）；用户已给明确 `plan-id` 时可用 `plan.sh new <plan-id>`。
- **规格轨**：查重、`draft` 规格、`SpecRef` / `ExecutionPlan`、阶段骨架等按标准流程**逐项做完**，不要因用户未写命令而省略。

## 代理标准流程（用户要开功能时执行）

按顺序完成；每步可简短向用户确认规格名 / plan-id（或由用户提示给出）。

**若用户仅发送「极简用户口令」**：省略下文「请用户粘贴脚本」类交互；自行提炼 `计划名称` 或 `plan-id`（见上节），并完整执行本清单。

1. **确定标识**
   - `plan-id`：符合规则的一至两段路径（如 `feat-auth` 或 `feat-auth/T1`）；若与规格目录同为 `NNN-名称` 风格，可先 `./doc/plans/plan.sh next-numbered-id "<计划名称>"` 预览将生成的执行轨 id，再令 `specs/` 目录号与之对齐；或先 `new-numbered` 落执行轨再对齐规格路径。
   - Spec 路径：如 `specs/001-feat-auth/README.md`（以仓库实际 LeanSpec 约定为准）。

2. **规格（LeanSpec）**
   - 若已配置 MCP：先用 `search` / `list` 查是否已有相关 Spec，避免重复。
   - 若尚无对应 spec：创建或调用 `lean-spec specify …` / MCP `create` / 手工建立 `specs/…` 文件，包含目标、场景、验收、非目标；**frontmatter 须含 `created`**，日期格式为 **`YYYY-MM-DD`**；并将 `status` 初始化为 `draft`（规格撰写中）。
   - 当 Spec 已审阅通过、范围稳定且可进入执行时，将 `status` 从 `draft` 更新为 `planned`（规格冻结，可开工）。

3. **执行计划（ext）**
   - 运行 `./doc/plans/plan.sh new <plan-id>` 或 `./doc/plans/plan.sh new-numbered <计划名称>`（或等价），保证 **effective** 目录下存在三文件。
   - `new-numbered` 会将 `ACTIVE` 设为生成的 `plan-id`（与 `new` 相同）。

4. **双向轻量引用（核心桥接，禁止整文件覆盖同步）**
   - 在 **effective** 的 `task_plan.md` **顶部**增加一行：`SpecRef: specs/.../README.md`
   - 在 **对应 Spec 文件** 内增加一节或一行：`ExecutionPlan: doc/plans/<plan-id>/`

5. **填充执行骨架**
   - 在 `task_plan.md` 中把 LeanSpec 的验收项**映射**为 Phase/检查项（复制摘要即可，验收原文仍以 spec 为准）；若已配置 MCP，拉取验收段落时优先 `view`。
   - 大块调研与外部原文只写入 `findings.md`。

6. **收尾（默认合并到末尾阶段的 DoD）**
   - 当首次开始实际实施（进入编码/改仓库文件）时，将 Spec `status` 从 `planned` 更新为 `in-progress`（执行已开始）。
   - 若 `task_plan` 末尾阶段含双轨收尾子项，Agent 在该阶段 DoD 中一并完成：Spec 终态（`in-progress` → `complete`，用 MCP `update` 或文件修改）、`validate`、一致性简述。
   - 仅在末尾阶段未涵盖 MCP 操作或需独立确认时，作为单独步骤执行。
   - 提醒用户可选用：`lean-spec board`、`lean-spec ui`；已配置 MCP 时可用 MCP 的 `board` / `stats`。

## Spec 状态流转规则（规格轨）

本技能将 LeanSpec 的 `status` 字段作为**规格轨的真相源**，并与执行轨（`doc/plans/<plan-id>/` 的 Phase 状态）形成互补：

- **主流程**：`draft` → `planned` → `in-progress` → `complete`
- **独立终态**：`archived`（可从任意状态跳转；不强行纳入主流程）

### 状态语义与进入条件

| 状态 | 语义 | 进入条件（推荐） | 退出条件（推荐） |
|------|------|------------------|------------------|
| `draft` | 规格撰写/精炼中，不应进入执行 | 新建 Spec 默认即 `draft` | 规格审阅通过、范围冻结 → `planned` |
| `planned` | 规格冻结，可开工但尚未开始 | 计划已成型、验收可对照、依赖基本明确 | 首次开始实际实施 → `in-progress` |
| `in-progress` | 执行已开始 | 至少一个 Phase 进入执行（或已有代码改动） | 所有 Phase 完成且通过对照验收 → `complete` |
| `complete` | 完成 | 最后阶段双轨收尾完成（含 validate） | （通常不回退；需要时可手工调整） |
| `archived` | 取消/不再相关 | 需求取消、方向变化、被替代等 | （独立终态；需要时可手工恢复到 `draft`/`planned`） |

### Agent 修改 `status` 的规则

- **允许修改的时机**：
  - **新建/对齐 Spec**：初始化为 `draft`
  - **审阅冻结后**：`draft` → `planned`
  - **首次实施开始时**：`planned` → `in-progress`
  - **收尾交付时**：`in-progress` → `complete`（通常与末尾阶段 DoD 合并）
  - **明确取消/不再做**：`any` → `archived`（独立终态，不要求走完主流程）
- **禁止的行为**：
  - 不要因为“创建了执行计划目录”就自动把 Spec 从 `draft` 改为 `planned`
  - 不要把执行轨 Phase 的 `in_progress/pending/complete` 与 Spec 的 `status` 混为一谈（两者语义不同）

## 阶段完成定义（DoD）

每个阶段完成时，Agent **必须**依次检查：

| # | 检查项 | 动作 |
|---|--------|------|
| 1 | `task_plan.md` 当前 Phase 状态已改为 `complete` | 更新状态标记 |
| 2 | `progress.md` 已记录本阶段完成时间与关键产出 | 追加日志 |
| 3 | 若 `task_plan.md` 含 `SpecRef:`，已对照 Spec 中对应验收项自检 | 合并闭环时：一次精读验收要点后在本阶段收尾勾选，而非与实施割裂为第二次全文重读（除非发现不一致或 Spec 有变更） |
| 4 | 若自检发现偏差，已在 `findings.md` 记录并修正 | 写 findings + 修正代码/文档 |
| 5 | 下一 Phase 状态标记为 `in_progress`（若有） | 更新状态标记 |

### 阶段闭环策略（推荐）

- **默认：合并闭环** — 单次会话完成「实施 + Spec 对照自检 + 三文件更新」；不要刻意拆成「先执行再来自检」两次对话。
- **仅在以下情况使用独立自检会话**：存在偏差需修正 / 需求边界有争议 / 需要独立签认（如人工审查后再让 Agent 做 Spec checklist）。独立自检以 **Spec 条款 checklist** 为主，**不默认重复**已做过的静态检索与构建（除非源码或 Spec 在此期间发生了变更）。
- **findings 去重**：同一阶段优先使用**一张表两列**格式（证据列 / Spec 条款对照列），避免「实施摘要」与「自检表」各写一段重复证据。
- **progress 去重**：合并闭环时，`progress.md` 单条条目须**同时包含**执行结果与 Spec 对照结论，而非分两条记录。

## 代理在规划任务中的行为要点

- 复杂任务开始前：确保 **effective** 目录下存在三文件，并正确设置 **`doc/plans/ACTIVE`**。
- 不要把不可信外部原文大块写入 `task_plan.md`；证据与摘录放 **`findings.md`**。
- 工具写入/编辑后：按规则与 post-hook 提示更新 **`progress.md`** 与阶段状态。
- **SpecRef 感知**：hooks 会检测 `task_plan.md` 中的 `SpecRef:` 行；若存在，会在 user-prompt / post-tool / stop 等处输出**语义区分**的提醒（决策对齐、编辑后关门、停前 DoD），合并闭环仍视为满足门禁。

## 明确不做的事（避免增加心智负担以外的风险）

- **不要用脚本覆盖重写**整个 `task_plan.md`「从 LeanSpec 同步任务列表」——会破坏错误表、决策记录与 hook 友好结构。
- **不要把不可信长原文**贴进 `task_plan.md`。
- **不要**在未合并的情况下改写用户已有的 `.cursor/hooks.json`。
- **不要**在用户只要文件规划（不要 specs）时强制建立规格轨——应引导用户使用 `planning-with-files-zh`。
- **不要**用 MCP/脚本整文件覆盖同步 `task_plan.md`（MCP 只用于规格轨）。
- **不要**用 `validate` 结果替代业务层验收——`validate` 校验的是 Spec 结构与项目约定，业务验收仍须测试/审查。

## 不包含的内容

- 本包**不内置** `planning-with-files-zh` 插件中的 `session-catchup.py`、`check-complete` 等脚本；若需要「跨会话自动对齐」，可在项目中另行接入。

## 维护说明

- 修改本 `SKILL.md` 时：更新文首 HTML 注释中的 `UpdatedAt`（用命令行 `date "+%Y-%m-%d %H:%M:%S"`）与 `LatestChange`。
- 修改嵌入在 `bootstrap.sh` 中的规则、**hooks.json 模板**或 hook 逻辑后，应同步更新本 `SKILL.md` 中描述；已落地项目若需升级 hooks，需与仓库内现有 `hooks.json` 手动合并。
