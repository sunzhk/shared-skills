<!--
UpdatedAt: 2026-04-08 16:50:03 +0800
LatestChange: 新增 open-spec-cn 技能，统一 OpenSpec 中文规范写作与 -cn 命令包装流程。
-->

# open-spec-cn

## 目标

为 OpenSpec 提供可跨项目复用的中文规范与命令包装，确保以下约束长期稳定生效：

- 规格文档以中文为主，保持人类可读性。
- Requirement 语句必须包含 `MUST` 或 `SHALL`（推荐：`必须（MUST）` / `应当（SHALL）`）。
- `Purpose` 不允许保留 `TBD` 占位文本。
- 归档前后自动校验，减少在 `archive` 阶段被阻塞的返工。

## 触发时机

当用户提到以下意图时应优先使用本技能：

- “OpenSpec 中文规范如何固化”
- “要让 spec 可读且可校验”
- “给 openspec 命令套一层 wrapper”
- “跨项目统一 OpenSpec 文档标准”

## 规范（强制）

### 1) 写作语言

- `openspec/changes/*/specs/**/spec.md` 与 `openspec/specs/**/spec.md` 的正文默认使用中文。
- 标题建议中文化（如 `Requirement` 标题可写中文语义标题）。

### 2) 规范关键词

- 每条 Requirement 必须显式出现 `MUST` 或 `SHALL`。
- 推荐句式：
  - `系统必须（MUST）...`
  - `系统应当（SHALL）...`

### 3) Purpose 约束

- `## Purpose` 下不得出现 `TBD` 占位文本。
- 必须写清能力目标与边界（1-3 句即可，简洁优先）。

### 4) 归档前自检（最小）

```bash
rg "MUST|SHALL" openspec/changes/<change>/specs
rg "TBD - created by archiving|^TBD$" openspec/specs
```

## 命令包装（-cn）

本技能提供 `scripts/install-open-spec-cn.sh`，会在 `~/.local/bin` 下生成 `openspec` 顶层命令对应的 `-cn` 包装命令（例如 `openspec-archive-cn`、`openspec-validate-cn`）。

包装命令执行逻辑：

1. 调用 `scripts/openspec-cn-run.sh`。
2. 在关键写操作（如 `archive`）前后触发 `scripts/openspec-cn-guard.sh` 校验。
3. 再调用原生 `openspec` 命令。

## 安装与使用

### 安装命令包装

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh
```

若 `~/.local/bin` 未在 PATH，请自行加入 shell 配置。

### 使用示例

```bash
openspec-new-cn change "improve-xxx"
openspec-instructions-cn proposal --change "improve-xxx" --json
openspec-archive-cn "improve-xxx"
```

## 输出要求（给 Agent）

- 结论优先：先说明是否符合规范，再给修复建议。
- 最小改动：默认不改业务语义，只修订文档结构与规范文本。
- 校验透明：明确告知执行了哪些校验命令与结果。
