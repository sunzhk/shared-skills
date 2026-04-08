<!--
UpdatedAt: 2026-04-03 17:20:50 +0800
LatestChange: 口令示例增加「按双轨开需求，功能如下：…」，执行细节以 bridge 技能 SKILL.md 为准。
-->

# planning-with-files-zh + lean-spec-planning-with-files-bridge + LeanSpec 协作文档

本文说明如何在同一仓库内同时使用 **LeanSpec**（规格与项目视图）、**planning-with-files-zh**（对话纪律与三文件心智模型）、**lean-spec-planning-with-files-bridge**（Cursor 落地：规则、hooks、`doc/plans/` 多计划与双轨强制）。LeanSpec 的定位与能力可参考官方中文指南：[什么是 LeanSpec？ | LeanSpec](https://www.lean-spec.dev/zh-Hans/docs/guide/) 与仓库 [codervisor/lean-spec](https://github.com/codervisor/lean-spec)。

---

## 1. 三者各管什么（一句话）

| 组件 | 职责 | 典型产物 |
|------|------|----------|
| **LeanSpec** | 「**做对的事**」：目标、场景、验收、非目标、元数据；**规格状态流转**（`draft → planned → in-progress → complete`，`archived` 为独立终态）；可看板/统计/Web UI；AI 可通过 MCP/CLI 检索规格。 | `specs/` 下带 frontmatter 的 Markdown（如 `specs/001-xxx/README.md`） |
| **planning-with-files-zh** | 「**怎么在对话里不丢上下文**」：先计划、写盘、两动作记发现、决策前重读、错误进表、外部原文不进易被 hook 反复注入的 `task_plan.md`。 | 心智模型与技能说明；可选 `session-catchup` 等（视安装方式而定） |
| **lean-spec-planning-with-files-bridge** | 「**在仓库里工程化落地双轨**」：`.cursor/rules`、`hooks`、`doc/plans/<plan-id>/`、ACTIVE / SUB_ACTIVE、脚本 `plan.sh`，并强制 `specs/` 与 SpecRef/ExecutionPlan。 | `doc/plans/…` 三文件 + Cursor 钩子 |

**原则**：LeanSpec 是规格的**对外真相源**；`doc/plans/<plan-id>/` 是**单次/并行执行**的真相源。不要用「全自动覆盖脚本」把两边糊成一个大文件，避免破坏手工维护的阶段与错误记录。

---

## 2. 推荐目录布局（并存、低耦合）

```
your-project/
├── specs/                          # LeanSpec（lean-spec init 等）
│   └── <编号或名称>/README.md      # 示例见 LeanSpec 文档
├── doc/plans/                      # 执行轨（本技能 bootstrap）
│   ├── ACTIVE                      # 当前全局 plan-id（一行）
│   ├── planning-paths.sh           # bootstrap 生成，供 hooks source
│   ├── plan.sh / new-plan.sh
│   └── <plan-id>/                  # 一至两段路径，如 feat-a 或 feat-a/T1
│       ├── task_plan.md
│       ├── findings.md
│       ├── progress.md
│       └── （按需）SUB_ACTIVE、子计划目录…
├── .cursor/
│   ├── rules/planning-with-files.mdc
│   ├── hooks.json
│   ├── hooks/*.sh
│   └── skills/planning-with-files-zh/   # bootstrap 可选安装
└── …
```

- **不要**再单独用 `docs/plan/` 放三文件（除非团队刻意不用本约定）；与 **本技能默认的 `doc/plans/`** 保持一致，hooks 才能正确注入。
- LeanSpec 文档强调 Spec 宜小（&lt; 约 2000 Token）、结构化、[与 AI 协作](https://www.lean-spec.dev/zh-Hans/docs/guide/) —— 与「总纲简短、细节进子计划 / findings」一致。

---

## 3. 初始化顺序（新项目）

1. **LeanSpec**（按官方快速开始）：例如全局 `lean-spec` 或 `npx lean-spec init`，得到 `specs/` 等结构。参见 [指南 - 快速开始](https://www.lean-spec.dev/zh-Hans/docs/guide/)。
2. **lean-spec-planning-with-files-bridge**：在**项目根**执行 shared-skills 中的 `lean-spec-planning-with-files-bridge/bootstrap.sh`（可指定目标目录、可选 `--no-install-planning-with-files-zh`）。生成 `.cursor` 规则与 hooks、`doc/plans/` 脚本，并复制协作文档。
3. **planning-with-files-zh**：由 bootstrap **可选**复制/软链到 `.cursor/skills/planning-with-files-zh/`；复杂任务前 Agent 应对照技能全文中的矩阵与安全边界。

可视化与检索（可选但推荐）：`lean-spec board`、`lean-spec stats`、`lean-spec ui`（见 [LeanSpec 指南](https://www.lean-spec.dev/zh-Hans/docs/guide/)）。

---

## 4. 五步协作工作流

1. **定规格（LeanSpec）**  
   在 `specs/…` 写清目标、关键场景、验收标准、非目标；**frontmatter 须含 `created: YYYY-MM-DD`**（与 [LeanSpec 指南「一个简单示例」](https://www.lean-spec.dev/zh-Hans/docs/guide/) 一致）。新建 Spec 时将 `status` 初始化为 `draft`（规格撰写中）。另常用 `priority`、`tags`，以及依赖关系字段（如 `depends_on` / `related`，以官方文档为准）。

2. **开执行计划（执行轨）**  
   `./doc/plans/plan.sh new <plan-id>`，或 `./doc/plans/plan.sh new-numbered <计划名称>`（扫描顶层 `^数字-` 目录取最大编号 +1，与 `specs/NNN-…` 编号习惯对齐时省得手算序号）；仅需预览 id 时用 `./doc/plans/plan.sh next-numbered-id <计划名称>`。也可用 `new-plan.sh <plan-id>` 直接初始化。

3. **轻量桥接（双向引用，不重写）**  
   - 在 **effective 的 `task_plan.md` 顶部**增加一行引用，例如：`SpecRef: specs/001-user-auth/README.md`。  
   - 在 **对应 Spec** 末尾增加：`ExecutionPlan: doc/plans/<plan-id>/`（或同等说明）。  
   规格变更时：**人工**调整 `task_plan.md` 的阶段/验收映射；执行发现规格问题时：**先写 `findings.md`**，再改 Spec。

4. **执行与防漂移（zh + 本技能 hooks）**  
   - 当 Spec 已审阅通过、范围冻结且可进入执行时，将 Spec `status` 从 `draft` 更新为 `planned`。  
   - 当首次开始实际实施（进入编码/改仓库文件）时，将 Spec `status` 从 `planned` 更新为 `in-progress`。  
   - 重大决策前：重读 **effective** 的 `task_plan.md` + **对应 Spec**。  
   - 约每两次检索/阅读：结论进 **effective** 的 `findings.md` 或 `progress.md`。  
   - **不可信外部原文**只进 `findings.md`；`task_plan.md` 只保留消化后的结论（防 hook 反复注入带来的提示注入风险，见 planning-with-files-zh）。  
   - 同一问题多次失败：按技能中的「三次失败协议」处理并记入 `progress.md` / 错误表。

5. **阶段完成**  
   对照 LeanSpec 中的验收项自检；更新 **effective** `task_plan.md` 状态与 `progress.md`；若验收或范围变化，**更新 Spec** 并记下变更说明（可在 `findings.md` 留一条「规格变更记录」摘要）。  
   合并闭环时，`progress.md` 单条条目须同时包含执行结果与 Spec 对照结论；无偏差时不开独立自检会话。  
   最后一个阶段的完成还包括**双轨收尾**：将 Spec `status` 从 `in-progress` 更新为 `complete`（MCP `update` 或文件修改）、运行 `validate`、执行轨与规格轨一致性简述——与 `lean-spec-planning-with-files-bridge/README.md` **收尾步骤**合并执行，不另开会话。  
   `archived` 为**独立终态**：当需求取消/不再相关时，可从任意状态将 Spec 标为 `archived`，不强行走完主流程。

---

## 5. 父计划 + 子计划（执行轨）与 LeanSpec 的用法

- **一个 Spec** 可对应 **一个父 plan**（`doc/plans/<父>/` 总纲 + `## 子计划索引表`）及多个 **子目录**（`<父>/<子>/` 各自三文件）。  
- **总纲 `task_plan.md`**：大纲 + 子计划索引 + 各子完成判据（一句话）；**不要把大块 Phase 细节塞进总纲**，避免 pre-hook 反复 `head` 注入过载。  
- **子计划**：详细 Phase、实现细节在子目录 `task_plan.md`。  
- **SUB_ACTIVE** 由 Agent 维护；`plan.sh use` / `[计划: …]` **不**清除 `SUB_ACTIVE`（与合并技能 `SKILL.md` 一致）。

---

## 6. AI 集成侧（可选）

- **LeanSpec MCP**（规格轨推荐）：配置见 [MCP 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/usage/mcp-integration)；代理对 **`specs/`** 的检索、视图、状态更新、依赖、校验与项目健康（`list` / `search` / `view` / `update` / `deps` / `validate` / `board` / `stats` 等，以 [MCP 服务器参考](https://www.lean-spec.dev/zh-Hans/docs/reference/mcp-server) 为准）**优先走 MCP**，与 **`SpecRef` 一行引用**互补——前者减少路径依赖与手改 frontmatter，后者保证仓库内直接可跳转。  
- **执行轨不变**：**`doc/plans/` 三文件**仍用读写文件 + 本技能安装的 hooks；MCP **不**替代执行轨，**禁止**用 MCP/脚本整文件覆盖 `task_plan.md`「从 LeanSpec 同步任务列表」。  
- **planning-with-files**：依赖 Cursor hooks + 规则自动提醒读计划、写 progress；与 LeanSpec MCP **并行不冲突**；上下文里优先 **当前 effective** 三文件 +（若已配置 MCP 则同时可用 MCP 拉取 **当前 SpecRef** 对应 Spec 内容）。

---

## 7. 反模式（避免）

| 不要 | 建议 |
|------|------|
| 用脚本整文件覆盖 `task_plan.md`「同步」LeanSpec 任务列表 | 用 SpecRef + 人工增量对齐；或仅生成「附录」草稿，不覆盖主计划 |
| 把网页/API 长原文贴进 `task_plan.md` | 原文进 `findings.md`，计划里只写摘要 |
| 规格与执行计划分两套目录且互不引用 | 至少保留 SpecRef / ExecutionPlan 双向一行引用 |
| 在非 `doc/plans/` 约定路径下放三文件 | 统一用 `doc/plans/`，否则 Cursor hooks 不会生效 |

---

## 8. 文档维护（本文件）

- **更新时间**：文首 HTML 注释中的 `UpdatedAt` 应使用**命令行**获取的当前时间（例如 `date "+%Y-%m-%d %H:%M:%S"`）。  
- **最近变更**：在 `LatestChange` 用一句话记录本次修改要点。  
- 修订本协作文档时，请同步更新上述两行。

---

## 9. 参考链接

- [LeanSpec 中文指南（概述 / 快速开始 / AI 集成）](https://www.lean-spec.dev/zh-Hans/docs/guide/)  
- [LeanSpec GitHub 仓库](https://github.com/codervisor/lean-spec)  
- 本仓库：`shared-skills/lean-spec-planning-with-files-bridge/SKILL.md`、`README.md`、`bootstrap.sh`  
- 本协作文档（本文）源路径：`shared-skills/lean-spec-planning-with-files-bridge/planning-with-files-and-lean-spec-collaboration.md`  
- 技能：`planning-with-files-zh`（`SKILL.md` 全文，含安全边界与模板路径）

---

## 10. 自动化协调：技能 + 可选脚本（降低心智负担）

完全「无人值守」地把 LeanSpec 与 `task_plan.md` 深度合并（例如整文件覆盖同步）**不推荐**（见第 7 节）。推荐用下面方式把**操作顺序固化**，由代理执行、用户只表达意图：

| 方式 | 作用 | 说明 |
|------|------|------|
| **Cursor 技能** `lean-spec-planning-with-files-bridge` | 触发后代理按固定清单：确认已落地 → 建/对齐 `specs/` → `plan.sh new` 或 `plan.sh new-numbered` → 写入 `SpecRef` / `ExecutionPlan` → 填 Phase 骨架 | 目录：`shared-skills/lean-spec-planning-with-files-bridge/SKILL.md`；安装方式：软链或复制到 `~/.cursor/skills/` 或项目 `.cursor/skills/` |
| **`bootstrap.sh`** | 一键写入 hooks/rules/脚本，并把**本协作文档**复制到目标仓库 `doc/plans/COORDINATION_LEANSPEC.md` | 一体化脚本（原分拆的 ext / bridge bootstrap 已合并；shared-skills 内旧目录已移除） |

**标准术语：双轨协作** — **规格轨**（`specs/`）与 **执行轨**（`doc/plans/`）并行，用 `SpecRef` / `ExecutionPlan` 轻量对齐；`planning-with-files-zh` 的纪律落在执行轨。**不要用「三件套」命名本工作流**：在 planning-with-files 语境下，「三件套」几乎总是指 **`task_plan` / `findings` / `progress` 三文件**，用作桥接口令会系统性误导 Agent。

**推荐用户口令示例**（按不易误解程度排序）：

1. **最明确**：「用 **lean-spec-planning-with-files-bridge**：为 `<功能名>` 建 **`specs/…` 规格** + **`doc/plans/<id>/` 计划**，并写 **SpecRef 与 ExecutionPlan**。」  
2. **最短（推荐日常）**：`按双轨开需求，功能如下：「<功能简述>」` — 由代理读取该技能 `SKILL.md` 自动执行（含 `plan.sh new-numbered` 等），用户不必粘贴命令。  
3. **简短（备选）**：「**按双轨**给 `<功能名>` 建 spec 和 plan，plan-id 用 `<id>`。」（若执行轨用自动编号：「…用 `./doc/plans/plan.sh new-numbered "<计划名称>"`」。）  
4. **同义说法**：「**双轨开需求** `<功能名>`，plan `<id>`。」「**规执双轨**：…」（规=规格轨，执=执行轨。）

代理应读取桥接技能并执行其中「代理标准流程」；若用户只说要「文件规划、不要 specs」，则走 **planning-with-files-zh** 单独使用，**不要**用本技能执行规格轨步骤。

**与 LeanSpec MCP**：若已配置 [AI 集成](https://www.lean-spec.dev/zh-Hans/docs/guide/) 中的 MCP，检索/更新 spec 可走 MCP；`doc/plans/` 三文件仍走文件与本技能 hooks。

### 10.1 业务项目用 README 声明、一条命令落地（推荐）

跨项目共享 **shared-skills** 时，不要在各仓库手抄 `cursor_skill_links`：**默认块已写在 shared-skills 仓库根 `README.md`**；仅在需要覆盖开关或技能列表时，再在**业务项目根 `README.md`** 加入同名块（键名见 `shared-skills/README.human.md`「README 驱动一键配置」）。然后在项目根执行：

```bash
bash .cursor/shared-skills/configure-from-readme.sh
```

脚本会先加载 shared-skills 根 README 中的默认块，再与业务 README 块合并；按**合并后**开关执行 `lean-spec-planning-with-files-bridge/bootstrap.sh`（一体化双轨）、**解析** `cursor_skill_links`（如聚合包展开为 router）、校验 `SKILL.md` 并将路径写入 **`AGENTS.md`**（不创建 `.cursor/skills` 软链）。**启用项 = 默认块 ∪ 业务 README 覆盖**（与 `AGENTS.md` 路由列表互补）。
