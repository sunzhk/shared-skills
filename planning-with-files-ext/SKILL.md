---
name: planning-with-files-ext
description: >
  为新项目一键落地基于文件的 planning-with-files 工作流：生成 Cursor 规则、hooks 与
  doc/plans 辅助脚本；支持路径 id（父/子至多两层）、SUB_ACTIVE 与 effective_dir、多计划目录与
  ACTIVE 指针、task_plan/findings/progress 三文件及按需 execution_brief。在用户要求初始化规划工具、
  安装 planning hooks、bootstrap 文件规划、从模板创建计划目录时使用。触发词：落地 planning、安装 hooks、
  bootstrap、文件规划模板、多计划切换、子计划、planning-with-files。
---

<!--
UpdatedAt: 2026-03-31 14:42:49
LatestChange: configure-from-readme 示例路径改为 .cursor/shared-skills。
-->

# planning-with-files-ext（Cursor 工程落地）

## 与 `planning-with-files-zh` 的关系

- **概念与纪律**：阶段化计划、先写盘再执行、外部内容进 `findings.md`、`task_plan.md` 防注入等，与 **`planning-with-files-zh`**（Manus 风格文件规划系统）一致；若已安装该技能，执行复杂任务前可对照其全文中的规则、矩阵与安全边界。
- **本包差异**：面向 **Cursor 仓库内落地**——生成 `.cursor/rules`、`hooks.json`、shell hooks，以及 `doc/plans/` 下的 `new-plan.sh` / `plan.sh` / **`planning-paths.sh`**；计划目录为 **`doc/plans/<plan-id>/`**，其中 **plan-id** 为相对 `doc/plans/` 的路径 id（**一至两段**：`父` 或 `父/子`，每段仅 `[a-zA-Z0-9._-]+`，禁止 `..` 等）。**`doc/plans/ACTIVE`** 存全局激活路径；当 ACTIVE 为**父**且存在 **`doc/plans/<父>/SUB_ACTIVE`**（一行子目录名）时，hooks 将 **effective** 解析为 `父/子` 并读写子目录三文件（否则读写 ACTIVE 对应目录）。**`SUB_ACTIVE` 由 Agent 维护**，`plan.sh use` / `[计划: …]` **不会**清除父目录下的 `SUB_ACTIVE`。

## 何时启用本技能

- 用户要在**新项目/新仓库**里启用「文件规划 + hooks 提醒」。
- 用户提到 **bootstrap、安装 hooks、复制 planning 模板、多计划** 等。
- 需要代理按固定步骤**写入**规则与脚本，而不是口头描述怎么做。

## 一键落地（代理执行）

**多项目共享 shared-skills 时（推荐）**：让业务项目在根 `README.md` 写入 `<!-- shared-skills-config -->` 并设 `planning_with_files_ext=1`（及 `planning_with_files_ext_no_install_pwfz` 等），再在项目根执行 `bash .cursor/shared-skills/configure-from-readme.sh`。约定与键名见 `shared-skills/README.human.md`「README 驱动一键配置」。

**单项目直接执行**：

1. **定位本技能目录**（含 `bootstrap.sh` 的目录；若在 monorepo 中多为 `shared-skills/planning-with-files-ext/`）。
2. 在**目标项目根目录**执行（或将项目根作为第一个参数传入）：

```bash
bash /绝对路径/到/planning-with-files-ext/bootstrap.sh
# 或
bash /绝对路径/到/planning-with-files-ext/bootstrap.sh /path/to/target/repo
# 如不希望自动安装 planning-with-files-zh：
bash /绝对路径/到/planning-with-files-ext/bootstrap.sh /path/to/target/repo --no-install-planning-with-files-zh
```

3. 落地后检查：
   - `.cursor/rules/planning-with-files.mdc`
   - `.cursor/hooks.json` 与 `.cursor/hooks/*.sh`
   - `doc/plans/new-plan.sh`、`doc/plans/plan.sh`、`doc/plans/planning-paths.sh`（脚本已 `chmod +x`；`planning-paths.sh` 供 source，无需手跑）
    - （可选）`.cursor/skills/planning-with-files-zh/SKILL.md`（若本机存在 `~/.agents/skills/planning-with-files-zh/SKILL.md`，bootstrap 默认会自动安装；优先软链，失败则复制）

4. **若目标仓库已存在 `.cursor/hooks.json`**：`bootstrap.sh` 会先与模板期望内容做 **字节级比对**。与模板**完全一致**时才会继续写入（重复执行安全）；**不一致则立即退出（exit 1）**，在 stderr 打印 **unified diff** 与处理建议，**不会覆盖**现有文件。需合并时请手工编辑后再运行，或暂移走 `hooks.json` 后重试。

## 使用者后续操作（简述）

- 新建计划并设为 ACTIVE：`./doc/plans/plan.sh new <plan-id>`（或 `./doc/plans/new-plan.sh <plan-id>`），支持路径 id（例：`feat-a`、`feat-a/T1`）。
- 列出/切换计划：`./doc/plans/plan.sh list`（缩进表示子计划）、`./doc/plans/plan.sh use <plan-id>`（**不会**改写任何 `SUB_ACTIVE`）。
- 在对话中用 **`[计划: <plan-id>]`** 或 **`[plan: <plan-id>]`** 可在 user prompt hook 中自动切换 ACTIVE（`user-prompt-submit.sh` 内为一至两段路径校验）。

## 代理在规划任务中的行为要点

- 复杂任务开始前：确保 **effective** 目录（见规则 `.mdc`：`ACTIVE` + 可选 `SUB_ACTIVE`）下存在 **`task_plan.md`**（及 `findings.md`、`progress.md`），并正确设置 **`doc/plans/ACTIVE`**。父+子拆解时总纲的 **`## 子计划索引表`** 与 **`SUB_ACTIVE`** 按规则维护。
- 不要把不可信外部原文大块写入 `task_plan.md`；证据与摘录放 **`findings.md`**，计划在 `task_plan.md` 只保留**消化后的结论与决策摘要**。
- 工具写入/编辑后：按规则与 post-hook 提示更新 **`progress.md`** 与阶段状态。

## 不包含的内容

- 本包**不内置** `planning-with-files-zh` 插件中的 `session-catchup.py`、`check-complete` 等脚本；若需要「跨会话自动对齐」，可在项目中另行接入或手写轻量流程。

## 维护说明

- 修改嵌入在 `bootstrap.sh` 中的规则、**hooks.json 模板**或 hook 逻辑后，应同步更新本 `SKILL.md` 中「落地产物」与「注意事项」描述；已落地项目若需升级 hooks，需与仓库内现有 `hooks.json` 手动合并（因不一致时脚本会拒绝覆盖）。
