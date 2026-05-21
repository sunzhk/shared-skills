---
name: open-spec-cn
description: Use when you need Chinese guidance for OpenSpec workflows, command setup, and spec-driven delivery tasks.
---

<!--
UpdatedAt: 2026-04-14 17:25:00 +0800
LatestChange: `commands-init` 新增 Codex App prompts 目标（`OPSX_PROMPTS_DIR` / `--codex-prompts`），可生成 `~/.codex/prompts/opsx-*-cn.md`。
-->

# open-spec-cn

## 目标

为 OpenSpec 提供可跨项目复用的中文规范与命令包装，确保以下约束长期稳定生效：

- 规格文档以中文为主，保持人类可读性。
- Requirement 语句必须包含 `MUST` 或 `SHALL`。
- `Purpose` 不允许保留 `TBD` 占位文本。
- 归档前后自动校验，减少在 `archive` 阶段被阻塞的返工。

## 触发时机

当用户提到以下意图时应优先使用本技能：

- “OpenSpec 中文规范如何固化”
- “要让 spec 可读且可校验”
- “给 openspec 命令套一层 wrapper”
- “跨项目统一 OpenSpec 文档标准”

## 子命令

### `commands-init`

当用户显式要求 `/open-spec-cn commands-init` 时：

1. 运行 `scripts/install-open-spec-cn.sh`。
2. 在目标位置生成 `-cn` 版本 OpenSpec 命令（Claude 命令文件、Codex skills、Codex prompts）。
3. 返回所选目录与生成数量。

执行命令：

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh [project-root]
```

如需同一次命令同时初始化 Claude + Codex（若项目中存在对应目录）：

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh --all-targets [project-root]
```

如需仅追加 Codex App 全局 prompts 的 `-cn` 文件（不会影响其他目标选择逻辑）：

```bash
OPSX_PROMPTS_DIR="$HOME/.codex/prompts" \
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh [project-root]
```

或：

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh --codex-prompts [project-root]
```

### 默认动作

当子命令不是 `commands-init` 时，按本文件其余规则执行正常的 OpenSpec 中文规范辅助流程。

## 规范（强制）

### 1) 写作语言

- `openspec/changes/*/specs/**/spec.md` 与 `openspec/specs/**/spec.md` 的正文默认使用中文。
- 标题建议中文化。

### 2) 规范关键词

- 每条 Requirement 必须显式出现 `MUST` 或 `SHALL`。
- 推荐句式：
  - `系统必须（MUST）...`
  - `系统应当（SHALL）...`

### 3) Purpose 约束

- `## Purpose` 下不得出现 `TBD` 占位文本。
- 必须写清能力目标与边界。

### 4) 归档前自检

```bash
rg "MUST|SHALL" openspec/changes/<change>/specs
rg "TBD - created by archiving|^TBD$" openspec/specs
```

## Slash 命令初始化

本技能提供 `scripts/install-open-spec-cn.sh`，仅负责在项目内生成 Slash 命令文件：

- 优先读取环境变量 `OPSX_COMMANDS_DIR`。
- 未设置时按已存在目录选择：`<project-root>/.claude/commands`（兼容 `opsx/` 子目录）-> `<project-root>/.codex/commands` -> `<project-root>/.codex/skills`。
- 若上述目录均不存在，默认创建 `<project-root>/.claude/commands/opsx`。
- Codex prompts 目标独立控制：`OPSX_PROMPTS_DIR`（默认 `~/.codex/prompts`），在设置 `OPSX_PROMPTS_DIR`、传入 `--codex-prompts` 或 `--all-targets` 时启用。
- Claude 命令模式：自动扫描 `opsx-*.md` 或 `opsx/*.md`（排除已带 `-cn` 的文件），生成对应 `<name>-cn.md`。
- Claude 命令模式会为 frontmatter 的 `name:` 与 `description:` 追加 `(CN)`，避免命令面板按同名聚合时隐藏 `-cn` 条目。
- Codex skills 模式：自动扫描 `openspec-*` skill 目录，为每个目录生成 `openspec-*-cn` 副本并更新 `SKILL.md` 元信息。
- Codex prompts 模式：扫描 `opsx-*.md`（排除 `*-cn.md`），生成 `opsx-*-cn.md`；frontmatter 的 `description:` 会追加 `(CN)`（幂等）。

## 命名约定

- Slash 命令统一使用 `/opsx-<action>-cn`
- 终端命令继续使用标准 `openspec <action>`

## 安装与使用

### `commands-init`（仅 Slash 命令）

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh [project-root]
```

初始化动作包含两部分：

- 选择目标目录（优先 `OPSX_COMMANDS_DIR`，否则按 `.claude/commands(/opsx)` -> `.codex/commands` -> `.codex/skills` 选择）。
- 在启用 Codex prompts 目标时（`OPSX_PROMPTS_DIR`/`--codex-prompts`/`--all-targets`），额外生成 `~/.codex/prompts/opsx-*-cn.md`。
- 生成 `-cn` 版本：Claude 下生成 `*.md` 命令文件，Codex 下生成 `openspec-*-cn` skills，Codex App 下生成 `opsx-*-cn.md` prompts。
- 需要并行初始化多个目标时，使用 `--all-targets`。

### 使用示例

```bash
openspec new change "improve-xxx"
openspec instructions proposal --change "improve-xxx" --json
openspec archive "improve-xxx" --no-interactive
```

## 输出要求（给 Agent）

- 结论优先：先说明是否符合规范，再给修复建议。
- 最小改动：默认不改业务语义，只修订文档结构与规范文本。
- 校验透明：明确告知执行了哪些校验命令与结果。
