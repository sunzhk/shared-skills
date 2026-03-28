<!--
UpdatedAt: 2026-03-28 11:06:15
LatestChange: 增加 planning-with-files-ext 入口与触发路由（与风格/评审/单测并列为工具类技能）。
-->

# shared-skills（给 AI 看的运行规则）

本文档面向 Agent，用于保证技能触发稳定、路由一致、输出可执行。

## 1. 目标

- 对用户问题进行稳定路由：风格问题走 styleguide，评审流程问题走 eng-practices；单元测试规范问题 **默认走** `unit-test-guide-skills/unit-test-router/SKILL.md`；**文件规划工具落地**（bootstrap、hooks、计划目录）走 `planning-with-files-ext/SKILL.md`。
- **分层原则**：**不要假设一个 skill 解决所有问题**。按“风格 / 评审 / 单元测试 / 规划落地”拆分处理，避免在单个技能中混合过多职责。
- 在不破坏项目约束的前提下输出可执行建议。
- 减少重复解释与风格漂移。

## 2. 技能入口

- 风格入口：`code-styleguide-skills/styleguide-router/SKILL.md`
- 评审入口：`eng-practices/SKILL.md`
- 单元测试规范（主控）：`unit-test-guide-skills/unit-test-router/SKILL.md`
- 单元测试三端子技能：`unit-test-guide-skills/unit-test-android/SKILL.md`、`unit-test-ios`、`unit-test-wechat-miniprogram`
- 文件规划落地：`planning-with-files-ext/SKILL.md`（执行 `bootstrap.sh`、与 `planning-with-files-zh` 方法论对齐）

需要深读时可读取：

- `eng-practices/reference-code-review.md`
- `code-styleguide-skills/README.md`
- `unit-test-guide-skills/README.md`
- `planning-with-files-ext/README.md`

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

### 3.4 路由到 `planning-with-files-ext`

当用户意图是以下任一项：

- 在新项目/仓库中 **bootstrap 文件规划**、安装 planning **hooks**
- 初始化 `doc/plans`、**ACTIVE** 多计划、`task_plan` / `findings` / `progress` 工作流
- 复制/落地本仓库的 **planning-with-files** 模板（含 `hooks.json` 冲突检测）

**执行要点**：读取 `planning-with-files-ext/SKILL.md`，按其中路径对目标项目根目录运行 `bootstrap.sh`；若 `hooks.json` 已存在且与模板不一致，脚本会 **exit 1** 并打印 diff，需人工合并后再试。

### 3.5 组合调用

同时涉及风格与评审流程时：

1. 先用 `eng-practices` 判断评审结论与优先级（Required/Nit/Optional）
2. 再用 `styleguide-router` 给出语言级具体修改建议

### 3.6 路由示例矩阵

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
| “给新项目装 planning-with-files / hooks” | `planning-with-files-ext` | 读 `SKILL.md` 后 `bootstrap.sh`；注意 `hooks.json` 冲突时中断。 |

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
