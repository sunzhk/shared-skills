<!--
UpdatedAt: 2026-03-26 17:03:28
LatestChange: 下线 ai-project-lifecycle 的人类侧说明与接入示例，保留可实战技能。
-->

# shared-skills（给人看的说明）

本文档面向开发者与项目维护者，重点回答：

- 这些 skill 是做什么的？
- 怎么在项目里接入？
- 日常如何使用？
- 如何维护与升级？

## 包含的 skills

### `code-styleguide-skills/`

- 用途：多语言代码风格建议与审查支持。
- 典型场景：重构风格统一、Code Review 风格争议、命名与可读性建议。
- 入口 skill：`styleguide-router`（按语言分发到具体子 skill）。

### `eng-practices/`

- 用途：代码评审流程与评论策略（基于 Google eng-practices）。
- 典型场景：PR/CL 评审、评论措辞、冲突处理、Small CL 拆分、评审速度优化。
- 入口 skill：`eng-practices/SKILL.md`。

### `unit-test-guide-skills/`

- 用途：按项目类型输出单元测试规范（Android / iOS / 微信小程序）。
- 典型场景：补测试、统一测试分层、确定 mock/fake 策略、形成可执行测试任务清单。
- 入口 skill：`unit-test-guide-skills/unit-test-router/SKILL.md`（按平台分发到子 skill）。
- 子 skill：`unit-test-android`、`unit-test-ios`、`unit-test-wechat-miniprogram`。
- 规则基线：以官方文档为先（Android Developers、Apple Developer、微信开放文档）。

## 如何在项目中接入

推荐将本仓库作为共享规范源，在业务项目中“引用”而非复制粘贴。

### 方式 A：Git submodule（推荐，权威方案）

适用：需要版本锁定和可控升级节奏的团队。

#### A1. 首次接入（在业务项目根目录）

```bash
git submodule add <shared-skills-repo-url> .cursor/skills-shared
git submodule update --init --recursive
```

#### A2. 克隆后初始化（给新同学/CI）

```bash
git submodule update --init --recursive
```

#### A3. 拉取子模块最新提交（跟进上游）

```bash
git submodule update --remote --recursive
```

如果你希望固定到某个 release/tag，建议在子模块目录手动 checkout 到目标 tag，并在主仓库提交子模块指针变更。

#### A4. 常见更新流程（推荐）

1. 在业务项目执行 `git pull`。
2. 执行 `git submodule update --init --recursive`。
3. 如需升级共享技能，再执行 `git submodule update --remote --recursive`。
4. 回归验证后，提交主仓库中“子模块指针”变更。

#### A5. 常见问题排查

- **问题：目录是空的或未检出内容**
  - 处理：执行 `git submodule update --init --recursive`。
- **问题：主仓库更新后本地 submodule 版本没变化**
  - 处理：确认已拉取主仓库最新提交并执行 submodule update。
- **问题：本地误改了 submodule 内容**
  - 处理：先在子模块内处理/清理改动，再回到主仓库更新指针。

### 方式 B：Git subtree

适用：不想引入 submodule 使用心智，但仍希望同步上游。

### 方式 C：直接拷贝（仅试验）

适用：短期 PoC。  
风险：后续升级困难、容易版本漂移。

## submodule 路径约定

- 推荐路径：`.cursor/skills-shared`
- 该路径下的典型结构：
  - `.cursor/skills-shared/code-styleguide-skills/`
  - `.cursor/skills-shared/eng-practices/`
  - `.cursor/skills-shared/unit-test-guide-skills/`

## 项目中如何配置

在业务项目的 `AGENTS.md` 中声明共享 skills，建议示例：

```markdown
## Shared Skills

- `.cursor/skills-shared/code-styleguide-skills/styleguide-router/SKILL.md`
- `.cursor/skills-shared/eng-practices/SKILL.md`
- （推荐）`.cursor/skills-shared/unit-test-guide-skills/unit-test-router/SKILL.md`
- （可选，直达某端）`.cursor/skills-shared/unit-test-guide-skills/unit-test-android/SKILL.md` 等同目录下 `unit-test-ios`、`unit-test-wechat-miniprogram`

使用约定：
- 风格问题优先走 `styleguide-router`。
- 评审流程、评论策略、冲突处理优先走 `eng-practices`。
- 单元测试规范与补测策略优先走 `unit-test-router`；若平台已明确，可直达对应 `unit-test-*` 子 skill。
```

## 日常使用建议

1. 先判断问题类型（风格 / 评审流程 / 单元测试规范）。
2. 选择对应入口（`styleguide-router`、`eng-practices`、`unit-test-router`）。
3. 输出以可执行建议为主，避免泛化描述。
4. 与项目强制规范冲突时，以项目规范为准。

## 维护与升级

- 建议通过 PR 维护共享 skills，避免项目内私有分叉。
- 业务项目升级 shared-skills 时，建议在 PR 中写清：
  - 升级前后子模块提交哈希
  - 本次升级涉及的 skill 变化摘要
  - 是否需要团队迁移动作
- 每次文档更新都应写明：
  - `UpdatedAt`（精确到秒，命令行获取）
  - `LatestChange`（本次更新说明）
- 新增/删除 skill 时，同步更新：
  - `README.md`（总纲）
  - `README.human.md`（人类说明）
  - `README.ai.md`（AI 运行规则）
