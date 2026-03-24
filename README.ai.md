<!--
UpdatedAt: 2026-03-24 17:28:01
LatestChange: 新增路由示例矩阵，细化常见问法到技能入口的映射。
-->

# shared-skills（给 AI 看的运行规则）

本文档面向 Agent，用于保证技能触发稳定、路由一致、输出可执行。

## 1. 目标

- 对用户问题进行稳定路由：风格问题走 styleguide，评审流程问题走 eng-practices。
- 在不破坏项目约束的前提下输出可执行建议。
- 减少重复解释与风格漂移。

## 2. 技能入口

- 风格入口：`code-styleguide-skills/styleguide-router/SKILL.md`
- 评审入口：`eng-practices/SKILL.md`

需要深读时可读取：

- `eng-practices/reference-code-review.md`
- `code-styleguide-skills/README.md`

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

### 3.3 组合调用

同时涉及风格与评审流程时：

1. 先用 `eng-practices` 判断评审结论与优先级（Required/Nit/Optional）
2. 再用 `styleguide-router` 给出语言级具体修改建议

### 3.4 路由示例矩阵

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
