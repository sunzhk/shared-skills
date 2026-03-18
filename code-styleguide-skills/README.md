<!--
UpdatedAt: 2026-03-18 15:44:59
LatestChange: 初版：补充在各项目中接入与使用本仓库 skills 的说明。
-->

## 这是什么

本目录包含一组“代码风格”skills，用于在 Cursor 中按语言提供可执行的风格建议（面向 Code Review / 重构时的风格统一）。

- **总纲入口**：`styleguide-router`（负责识别语言/文件类型、冲突裁决、分发到子 skill、统一输出模板）。
- **语言子 skill**：`styleguide-<language>`（按具体语言落地规则；部分语言可能仍为空实现占位）。

规范来源主要来自：

- Google Style Guides 索引：`https://google.github.io/styleguide/`
- 具体语言的官方风格指南（例如 Java、Kotlin 等）。

## 在项目中如何接入（团队共享 + 多项目复用）

推荐把本仓库作为“共享规范仓库”，然后在各业务项目以“引用”的方式接入。  
常见三种方式：

### 方式 A：Git submodule（推荐）

适合团队希望**锁定版本**、按项目节奏升级。

- **放置路径建议**：业务项目的 `.cursor/skills-shared/code-styleguide-skills/`
- **优点**：版本可控、升级明确；**缺点**：需要团队成员理解 submodule 的基本操作。

### 方式 B：Git subtree

适合团队不想引入 submodule 心智负担，但仍希望能同步上游变更。

- **放置路径建议**：同方式 A。
- **优点**：对多数人更友好；**缺点**：同步/回灌操作相对繁琐。

### 方式 C：直接拷贝（不推荐，除非试验阶段）

适合短期试验或极小团队。缺点是规范更新难以传播、容易漂移。

## 项目侧覆写（每个项目怎么定制但不分叉）

建议每个业务项目只保留“很薄的项目层”，用来补充项目特有约束，而不要直接改共享 skill：

- 在业务项目内新增：`.cursor/skills/<project>-style-overrides/`
- 内容建议：
  - 项目特有命名约束（包名、模块名、资源命名等）
  - 项目约定的例外（例如历史包袱、特定模块暂缓改造范围）
  - 与构建/工具链绑定的规则（formatter、lint 的强制项与例外）

**冲突优先级建议**（与 `styleguide-router` 一致）：

1. 项目明确约定（项目内文档、review 共识、构建/lint 强制规则）。
2. 团队共享规范（本仓库 skills）。
3. 官方指南原文（Google styleguide / Android Developers 等）。
4. 个人偏好。

## 日常使用方式（建议工作流）

### 1）从总纲入口开始

先在在AGENTS.md中增加对`styleguide-router`的说明，AI会优先使用 `styleguide-router` 来处理问题，它会：

- 判断语言/文件类型（根据文件路径、代码片段、问题描述）。
- 选择对应子 skill（必要时组合多个子 skill）。
- 给出统一格式的输出（检查点 + 最小示例 + 落地建议）。

### 2）遇到具体语言细节，再下钻到子 skill

例如：

- Java：`styleguide-java`
- Kotlin：`styleguide-kotlin`
- Shell：`styleguide-shell`
- Markdown：`styleguide-markdown`

### 3）输出约束（为了可执行）

建议所有“风格建议”尽量满足：

- **结论优先**：3–10 条检查点即可，不背诵全文。
- **最小示例**：仅给必要的 before/after 或正确/错误对照。
- **不改变语义**：默认只做风格层面的调整，除非明确要求语义重构。

## 目录结构约定

每个 skill 位于：

- `<skill-name>/SKILL.md`

其中：

- 入口：`styleguide-router`
- 子 skill：`styleguide-<language>`（如 `styleguide-java`、`styleguide-kotlin`）

## 版本管理建议

- 共享仓库使用 tag/release 标记版本（例如 `v0.1.0`）。
- 各业务项目锁定到明确版本，按需升级。
- 规范变更走 PR 审核，避免“某人随手改导致所有项目受影响”。

