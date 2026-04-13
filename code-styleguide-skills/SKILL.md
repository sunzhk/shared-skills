---
name: code-styleguide-skills
description: >
  Use when you need a single entry skill for code style guidance, router-based
  delegation, or project initialization via `/code-styleguide-skills init`.
---

<!--
UpdatedAt: 2026-04-13 09:46:41 +0800
LatestChange: 新增顶层入口技能，支持 `/code-styleguide-skills init` 写入 AGENTS.md，并将默认请求委托给 styleguide-router。
-->

# code-styleguide-skills

## 目标

提供一个统一入口，支持“单 skill + 子命令参数”的使用方式：

- `/code-styleguide-skills init`
- `/code-styleguide-skills <代码风格问题>`

默认职责：

- 负责接收代码风格相关请求。
- 在非 `init` 场景下委托给 `styleguide-router`。
- 保持 styleguide 子技能体系不变，仅统一入口与初始化方式。

## 子命令

### `init`

当用户显式要求 `/code-styleguide-skills init` 时：

1. 运行 `scripts/init-code-styleguide-skills.sh`。
2. 在当前项目根目录创建或更新 `AGENTS.md` 中的 `code-styleguide-skills` 说明块。
3. 返回实际写入的目标文件路径。

执行命令：

```bash
bash /path/to/shared-skills/code-styleguide-skills/scripts/init-code-styleguide-skills.sh [project-root]
```

### 默认动作

当子命令不是 `init` 时：

1. 读取 `styleguide-router/SKILL.md`。
2. 由 router 识别语言、文件类型或上下文。
3. 再分发到对应 `styleguide-*` 子技能。

## 输出约束

- 风格问题保持“结论优先 + 最小示例 + 不改语义”。
- `init` 只负责写或更新 `AGENTS.md`，不修改业务代码。
