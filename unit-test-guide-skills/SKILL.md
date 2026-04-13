---
name: unit-test-guide-skills
description: >
  Use when you need a single entry skill for unit-test guidance, router-based
  delegation, or project initialization via `/unit-test-guide-skills init`.
---

<!--
UpdatedAt: 2026-04-13 09:46:41 +0800
LatestChange: 新增顶层入口技能，支持 `/unit-test-guide-skills init` 写入 AGENTS.md，并将默认请求委托给 unit-test-router。
-->

# unit-test-guide-skills

## 目标

提供一个统一入口，支持“单 skill + 子命令参数”的使用方式：

- `/unit-test-guide-skills init`
- `/unit-test-guide-skills <单元测试问题>`

默认职责：

- 负责接收单元测试规范相关请求。
- 在非 `init` 场景下委托给 `unit-test-router`。
- 保持 Android / iOS / 微信小程序子技能体系不变，仅统一入口与初始化方式。

## 子命令

### `init`

当用户显式要求 `/unit-test-guide-skills init` 时：

1. 运行 `scripts/init-unit-test-guide-skills.sh`。
2. 在当前项目根目录创建或更新 `AGENTS.md` 中的 `unit-test-guide-skills` 说明块。
3. 返回实际写入的目标文件路径。

执行命令：

```bash
bash /path/to/shared-skills/unit-test-guide-skills/scripts/init-unit-test-guide-skills.sh [project-root]
```

### 默认动作

当子命令不是 `init` 时：

1. 读取 `unit-test-router/SKILL.md`。
2. 由 router 识别平台与上下文。
3. 再分发到对应 `unit-test-*` 子技能。

## 输出约束

- 测试建议保持“场景判定 + 官方依据 + 测试策略 + 落地动作”。
- `init` 只负责写或更新 `AGENTS.md`，不改测试代码或项目配置。
