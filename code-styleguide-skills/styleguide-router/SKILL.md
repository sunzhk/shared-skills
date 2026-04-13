---
name: styleguide-router
description: Use when routing code style requests to the correct language-specific styleguide skill.
---

<!--
UpdatedAt: 2026-04-10 16:11:26 +0800
LatestChange: 子 skill 默认路径改为 shared-skills，.cursor 路径降级为兼容说明。
-->

# Code Style Router Skill

本文件通常由顶层入口 `code-styleguide-skills/SKILL.md` 委托调用；若用户显式使用 `/code-styleguide-skills init`，应优先执行顶层 skill 的初始化逻辑，而不是直接进入本 router。

## 目标

基于 [Google Style Guides](https://google.github.io/styleguide/) 的总体思想，为团队在不同项目中提供**一致、可执行**的代码风格指导，并将具体问题**分发到对应语言的子 skill**。

本 skill 是“入口/路由器（router）”：它不替代各语言规范，而是负责：

- 统一解释与裁决原则（当规范冲突时如何取舍）。
- 识别用户当前问题所属语言/文件类型。
- 指示调用哪个子 skill（或组合多个子 skill）。
- 约束输出结构，让“风格建议”可落地为行动清单。

## 适用范围

- 代码风格：命名、格式化、注释、文件组织、API 设计约定、常见可读性问题。
- 覆盖语言：与 styleguide 页面列出的语言/文档相对应（见“分发规则”）。

## 不做什么（边界）

- 不会在没有代码上下文时输出大段“背规范”；优先给可执行的检查点。
- 不会凭空引入与 Google styleguide 无关的强约束；如需“团队/项目约定”，应放到项目侧覆写（或在回答中明确来源与优先级）。

## 冲突裁决（优先级）

当规则冲突时，按以下优先级取舍（从高到低）：

1. 项目明确约定（项目内文档/代码审查共识/构建或 lint 强制规则）。
2. 团队共享规范（本仓库 skill 的明确条目）。
3. Google Style Guides 原文。
4. 个人偏好。

若无法确定优先级，默认选择**更可读、更一致、更接近现有代码库风格**的一侧，并显式说明原因。

## 分发规则（语言/文件类型 → 子 skill）

根据用户提供的上下文（文件路径、代码片段、问题描述）判断语言并分发：

- AngularJS → `styleguide-angularjs`
- Common Lisp → `styleguide-common-lisp`
- C++ → `styleguide-cpp`
- C# → `styleguide-csharp`
- Go → `styleguide-go`
- HTML/CSS → `styleguide-html-css`
- JavaScript → `styleguide-javascript`
- Java → `styleguide-java`
- JSON → `styleguide-json`
- Markdown → `styleguide-markdown`
- Objective-C → `styleguide-objective-c`
- Python → `styleguide-python`
- R → `styleguide-r`
- Rust → `styleguide-rust`
- Shell → `styleguide-shell`
- Swift → `styleguide-swift`
- TypeScript → `styleguide-typescript`
- Vim script → `styleguide-vimscript`

组合分发（常见场景）：

- 前端页面：HTML/CSS + JavaScript/TypeScript
- 工程配置：JSON + Shell（脚本）+（必要时）语言本身
- 文档：Markdown +（必要时）Shell（示例命令）

## 交互与输出模板（必须遵循）

当用户提出“风格相关”问题时，按以下结构输出：

1. **语言/文件类型判定**：给出判定依据（例如后缀名、语法特征）。
2. **适用规范来源**：指出将参考的指南（Google styleguide + 团队/项目约定），并说明优先级。
3. **结论（可执行）**：用 3–10 条检查点输出，不要超过必要长度。
4. **示例（最小化）**：只给最小代码示例/反例；示例需贴近用户代码风格。
5. **落地建议**：如果需要 formatter/linter，给出“建议选项清单”，但不强制引入依赖或改构建。

## 子 skill 依赖约定

本仓库各语言子 skill 目录约定：

- 默认位置：`shared-skills/code-styleguide-skills/<skill-name>/SKILL.md`（或仓库内相对路径 `code-styleguide-skills/<skill-name>/SKILL.md`）
- 兼容位置：`.cursor/shared-skills/code-styleguide-skills/<skill-name>/SKILL.md`（仅历史项目兼容，非默认流程）
- 命名：`styleguide-<language>`（必要时使用更明确的后缀，例如 `html-css`、`objective-c`）。
