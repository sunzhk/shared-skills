<!--
UpdatedAt: 2026-04-01 15:08:55
LatestChange: planning-with-files-ext 与 planning-with-files-lean-spec-bridge 合并为 lean-spec-planning-with-files-bridge；更新路由规则、冷启动流程与 AGENTS.md 示例。
-->

# shared-skills（给 AI 看的运行规则）

本文档面向 Agent，用于保证技能触发稳定、路由一致、输出可执行。

## 0. 冷启动自动配置（新项目首次接入）

当 Agent 在一个**尚未配置 shared-skills 的项目**中工作时，执行以下检测与配置流程，**无需等待用户明确指令**：

### 0.1 触发条件（满足任一即触发）

- 用户提及「配置 shared-skills」「接入共享技能」「初始化项目」等
- Agent 发现 `.cursor/shared-skills/` 目录存在但 `AGENTS.md` 中没有 shared-skills 路径声明
- 用户要求使用某个 shared-skills 内的技能，但当前项目尚未配置

### 0.2 自动配置流程

**步骤 1：检测 submodule 状态**

```bash
ls .cursor/shared-skills/configure-from-readme.sh
```

- 若文件存在 → 继续步骤 2
- 若目录不存在或为空 → 提示用户先初始化 submodule：
  ```bash
  git submodule update --init --recursive
  ```
  初始化后继续步骤 2

**步骤 2：业务 README 中的配置块（可选）**

- `configure-from-readme.sh` 会**先**读取 `.cursor/shared-skills/README.md`（即 shared-skills 根 README）中的默认 `<!-- shared-skills-config -->`（已含 `cursor_skill_links`），**再**用业务项目根 `README.md` 中的同名块覆盖。
- 若业务项目无 `README.md`、或 README 中无该块 → **无需补写**，直接执行步骤 3 即可得到完整 AGENTS.md 与 bootstrap。
- 仅当需要关闭 `lean_spec_planning`、调整 `cursor_skill_links` 等时，再在业务 `README.md` 中加入配置块覆盖对应键。

**步骤 3：执行 configure-from-readme.sh**

```bash
cd <项目根>
bash .cursor/shared-skills/configure-from-readme.sh
```

该脚本会：
- 写入 `.cursor/rules/`、hooks、`doc/plans/` 等（按配置块决定）
- **解析** `cursor_skill_links`：`code-styleguide-skills` → `code-styleguide-skills/styleguide-router`，`unit-test-guide-skills` → `unit-test-guide-skills/unit-test-router`；再校验各解析后路径在 shared-skills 中存在且含 `SKILL.md`（不创建 `.cursor/skills` 软链）
- **写入或追加 `AGENTS.md`**（将 `.cursor/shared-skills/<解析后路径>/SKILL.md` 写入，路径可含 `/`，使 Agent 后续能自动路由）

**步骤 4：验证**

检查 `AGENTS.md` 中是否已包含 skill 路径声明，向用户确认配置完成。

### 0.3 AGENTS.md 写入规范

`configure-from-readme.sh` 写入 `AGENTS.md` 的格式：

```markdown
## Shared Skills（由 configure-from-readme.sh 生成，勿手动删除此行）

- `.cursor/shared-skills/lean-spec-planning-with-files-bridge/SKILL.md`
- `.cursor/shared-skills/eng-practices/SKILL.md`
- `.cursor/shared-skills/code-styleguide-skills/styleguide-router/SKILL.md`
- `.cursor/shared-skills/unit-test-guide-skills/unit-test-router/SKILL.md`
```

- 若 `AGENTS.md` 已存在且包含 `## Shared Skills` 节 → 更新该节内容，不影响其他节
- 若 `AGENTS.md` 不存在 → 新建并写入
- 若 `AGENTS.md` 已存在但无 `## Shared Skills` 节 → 在文件末尾追加

### 0.4 冷启动后的路由

配置完成后，Agent 在后续会话中：
1. 读取 `AGENTS.md` → 获知 skill 路径
2. 按 §3 路由规则 → 选择正确 skill
3. 直接读取 `.cursor/shared-skills/<skill>/SKILL.md` → 执行

### 0.5 LeanSpec CLI 检测（与桥接技能相关）

`configure-from-readme.sh` **不包含** LeanSpec 的安装与 `init`。当满足以下**任一**条件时，Agent **应先检测** LeanSpec 是否可用，**不可默认用户已安装**：

- 刚完成 §0 冷启动且 `AGENTS.md` 中声明了 `lean-spec-planning-with-files-bridge`（默认配置通常会包含）
- 用户意图涉及 **LeanSpec、`specs/`、`SpecRef`、规格与 doc/plans 联动**；或 **双轨协作 / 双轨开需求 / 规执双轨**（见技能 `SKILL.md`）。**不要**把用户说的「三件套」默认路由到桥接——在 planning-with-files 语境下「三件套」多指 **三文件**（§3.4）
- 准备读取并执行 `lean-spec-planning-with-files-bridge/SKILL.md` 中的 CLI 相关步骤

**检测方式**（在项目根或当前工作目录的 shell 中执行，按顺序）：

1. `command -v lean-spec`（或 `which lean-spec`）→ 若找到可执行文件，视为 **CLI 已可用**。
2. 若未找到：执行 `command -v npx`（并确认 `node` 可用）。若 **npx 可用**，可告知用户**无需全局安装**即可使用 `npx lean-spec …`（如 `npx lean-spec init`），并说明首次运行可能需要网络下载。
3. 若 **node / npx 均不可用**：**必须明确提示用户**先安装 Node.js（LTS），再按 **`README.human.md` →「LeanSpec 安装与初始化（须自行完成）」** 与官方指南 [LeanSpec 中文指南](https://www.lean-spec.dev/zh-Hans/docs/guide/) 完成 CLI 或手工 `specs/` 结构；**不要**假装已执行过 `lean-spec init`。

**未就绪时的输出要求**：简要说明「shared-skills 一键配置未包含 LeanSpec 安装」、给出上述文档锚点与官方链接、列出用户可选的下一步（全局安装 / `npx` / 仅手工维护 `specs/`）。若用户暂不安装 CLI，可仍按桥接技能中「手工建立最小 spec 文件」路径协助，但须说明与完整 CLI 工作流的差异。

## 1. 目标

- 对用户问题进行稳定路由：风格问题走 styleguide，评审流程问题走 eng-practices；单元测试规范问题 **默认走** `unit-test-guide-skills/unit-test-router/SKILL.md`；**双轨协作 / 文件规划落地**（bootstrap、hooks、计划目录、规格轨）走 `lean-spec-planning-with-files-bridge/SKILL.md`。
- **分层原则**：**不要假设一个 skill 解决所有问题**。按“风格 / 评审 / 单元测试 / 规划落地”拆分处理，避免在单个技能中混合过多职责。
- 在不破坏项目约束的前提下输出可执行建议。
- 减少重复解释与风格漂移。

## 2. 技能入口

- 风格入口：`code-styleguide-skills/styleguide-router/SKILL.md`
- 评审入口：`eng-practices/SKILL.md`
- 单元测试规范（主控）：`unit-test-guide-skills/unit-test-router/SKILL.md`
- 单元测试三端子技能：`unit-test-guide-skills/unit-test-android/SKILL.md`、`unit-test-ios`、`unit-test-wechat-miniprogram`
- 一体化双轨协作（规格轨 + 执行轨 + hooks）：`lean-spec-planning-with-files-bridge/SKILL.md`（含 `bootstrap.sh`、与 `planning-with-files-zh` 方法论对齐）
- **README 一键配置**：仓库根 `configure-from-readme.sh`（默认块在 shared-skills `README.md`，业务 README 可选覆盖；详见 `README.human.md`）

需要深读时可读取：

- `eng-practices/reference-code-review.md`
- `code-styleguide-skills/README.md`
- `unit-test-guide-skills/README.md`
- `lean-spec-planning-with-files-bridge/README.md`

## 3. 触发与路由规则

### 3.1 路由到 `styleguide-router`

当用户意图是以下任一项：

- 代码风格统一、命名/注释/可读性改进
- 按语言规范纠偏（Java/Kotlin/Go/Python/TS 等）
- “这段代码符不符合规范”类问题

### 3.2 路由到 `eng-practices`

当用户意图是以下任一项：

- PR/CL 评审策略与评论写法
- Reviewer/Author 协作与冲突处理
- Small CL 拆分、评审速度优化、紧急评审边界

### 3.3 路由到 `unit-test-guide-skills`

**默认**使用 `unit-test-guide-skills/unit-test-router/SKILL.md`，由其分发到平台子技能。

当用户意图是以下任一项：

- “单元测试怎么写/怎么补/怎么规范化”
- “按 Android / iOS / 微信小程序给测试策略”
- “测试覆盖怎么补、mock/fake 怎么选”
- “要一份可执行的测试任务清单/验收清单”

**直达子技能**：用户已明确平台且仅需该端细则时，可直接读对应 `unit-test-*/SKILL.md`。

### 3.4 路由到 `lean-spec-planning-with-files-bridge`

当用户意图是以下任一项：

- 在新项目/仓库中 **bootstrap 文件规划**、安装 planning **hooks**
- 初始化 `doc/plans`、**ACTIVE** 多计划、`task_plan` / `findings` / `progress` 工作流
- 复制/落地本仓库的 **planning-with-files** 模板（含 `hooks.json` 冲突检测）
- **双轨协作**（**同时**维护 **`specs/`** 与 **`doc/plans/`**，并写 **`SpecRef` / `ExecutionPlan`**）
- 明确说 **双轨 / 规执双轨 / LeanSpec 与 plan 联动 / 按双轨开需求**

**执行要点**：读取 `lean-spec-planning-with-files-bridge/SKILL.md`，按其中路径对目标项目根目录运行 `bootstrap.sh`；若 `hooks.json` 已存在且与模板不一致，脚本会 **exit 1** 并打印 diff，需人工合并后再试。本技能**强制双轨模式**：创建的计划必须同时建立规格轨与执行轨。

**「三件套」区分**：口语 **「三件套」** 在 planning-with-files 里多指 **`task_plan` / `findings` / `progress` 三文件**，**不等于**双轨协作。若用户只要文件规划、**不要** `specs/`，应走 `planning-with-files-zh` 单独使用，**不要**用本技能。

### 3.5 路由到 `configure-from-readme.sh`（README 驱动落地）

当用户意图是以下任一项：

- 通过 **业务项目 README** 声明 shared-skills 并**一键完成**仓库内配置
- 「按 README 配置 skills」「README 里 shared-skills-config」「自动装 planning hooks / 写入 AGENTS.md 技能列表」
- 「初始化这个项目的 shared-skills」「帮我配好技能入口」（→ 触发 §0 冷启动流程）

**执行要点**：

1. 默认配置（含 `cursor_skill_links`）在 **shared-skills 仓库根 `README.md`** 的 `<!-- shared-skills-config -->`；业务项目 README 中的块**可选**，用于覆盖。无业务块时直接执行即可。
2. 在业务项目根执行（submodule 典型路径示例）：
   - `bash .cursor/shared-skills/configure-from-readme.sh`
   - 或 `SKILLS_ROOT=<shared-skills 根> bash <shared-skills>/configure-from-readme.sh <项目根>`
3. 脚本会按固定顺序调用 `lean-spec-planning-with-files-bridge/bootstrap.sh`（一体化双轨）、**解析并校验** `cursor_skill_links`、**写入 `AGENTS.md`**；失败时按脚本 stderr 处理（如 `hooks.json` 冲突、技能目录不存在或缺少 `SKILL.md`）。

**不要**在未读 shared-skills 默认块与业务 README 合并结果的情况下猜测启用项；有效配置 = 默认块 ∪ 业务块覆盖。

### 3.6 组合调用

同时涉及风格与评审流程时：

1. 先用 `eng-practices` 判断评审结论与优先级（Required/Nit/Optional）
2. 再用 `styleguide-router` 给出语言级具体修改建议

### 3.7 路由示例矩阵

| 用户问法（示例） | 路由 | 执行要点 |
| --- | --- | --- |
| “这段代码符合规范吗？” | `styleguide-router` | 识别语言并输出风格检查点。 |
| “按 Go/Java/Python 规范改一下” | `styleguide-router` | 路由到具体语言子 skill。 |
| “帮我写 review 评论” | `eng-practices` | 先给结论等级，再给理由和建议。 |
| “怎么区分必须改和建议改？” | `eng-practices` | 使用 Required/Nit/Optional/FYI。 |
| “这个 PR 太大怎么拆？” | `eng-practices` | 按 Small CL 策略拆分。 |
| “评审太慢怎么办？” | `eng-practices` | 强调响应时延和流程加速策略。 |
| “这是紧急修复，怎么审？” | `eng-practices` | 先判断 emergency 再套流程。 |
| “既要评审策略又要语言规范” | `eng-practices` + `styleguide-router` | 先流程结论，后语言落地。 |
| “给我一份 Android 单元测试规范” | `unit-test-router` → `unit-test-android` | 按官方文档基线给可执行检查点。 |
| “iOS 单测异步怎么写规范” | `unit-test-router` 或 `unit-test-ios` | 优先 Apple 官方 XCTest/Swift Testing 规则。 |
| “微信小程序组件单测怎么做” | `unit-test-router` → `unit-test-wechat-miniprogram` | 以微信开放文档和 miniprogram-simulate 为准。 |
| “给新项目装 planning-with-files / hooks” | `lean-spec-planning-with-files-bridge` | 读 `SKILL.md` 后 `bootstrap.sh`；注意 `hooks.json` 冲突时中断。 |
| “三件套”（仅指要做规划 / 未提 `specs/`） | **默认按三文件理解** | 多指 `task_plan` / `findings` / `progress` → `planning-with-files-zh`；若用户澄清要 **双轨** 再用合并技能。 |
| “README 里配好 shared-skills，一键落地到仓库” | `configure-from-readme.sh` | 先核对 README 配置块，再执行脚本；见 `README.human.md`。 |
| “LeanSpec 和 doc/plans 联动” / “**按双轨**开需求” / “**双轨协作**” | `lean-spec-planning-with-files-bridge` | 按 §0.5 检测 LeanSpec CLI / npx，未就绪则提示用户参阅 `README.human.md`；再按技能清单建 SpecRef / ExecutionPlan。 |
| “帮我配置 shared-skills / 初始化技能入口” | §0 冷启动流程 | 检测 submodule → 检测 README 配置块 → 执行脚本 → 写 AGENTS.md。 |
| “这个项目还没配置 shared-skills” | §0 冷启动流程 | 同上，Agent 可主动检测并提议执行。 |

## 4. 冲突优先级

遇到规则冲突时按以下优先级裁决：

1. 项目明确约定（项目文档、lint/format、review 共识）
2. 本仓库 shared-skills
3. 官方公开指南
4. 个人偏好

若无法判断，询问用户并显式说明冲突点。

## 5. 输出约束

- 结论优先：先给可执行结论，再给依据。
- 最小充分：避免冗长背景，保留必要上下文。
- 不改语义：未获明确授权时，仅做风格/流程建议，不引入设计外代码。
- 清晰标注：建议分级为 Required/Nit/Optional/FYI（按场景选用）。

## 6. 安全与边界

- 不删除用户注释或“暂存无用代码”，除非用户明确要求。
- 不擅自扩大改动范围；发现关联影响时先说明再处理。
- 文档变更需维护元数据：
  - `UpdatedAt`：命令行获取的秒级时间
  - `LatestChange`：最近变更说明

## 7. 自检清单（执行前）

1. 是否命中正确入口 skill？
2. 是否遵守冲突优先级？
3. 输出是否可执行而非泛泛描述？
4. 是否遵守项目约束与用户偏好？
