<!--
UpdatedAt: 2026-03-31 14:42:49
LatestChange: configure-from-readme 示例路径改为 .cursor/shared-skills。
-->

# planning-with-files 项目模板

## 目的

- 将当前仓库已验证的 planning 工作流抽成可复用模板。
- 在其他项目中快速落地相同能力（rules/hooks/计划脚本）。

## 目录内容

- `SKILL.md`：**Cursor Agent 技能**入口（何时触发、如何执行 bootstrap、与 `planning-with-files-zh` 的关系）。
- `bootstrap.sh`：一键把模板写入目标项目。
- `README.md`：人类可读的目录说明与路径示例。

## 作为 Cursor 技能安装

- **个人全局**：将本目录复制或软链到 `~/.cursor/skills/planning-with-files-ext/`（目录内须含 `SKILL.md`）。
- **单仓库**：复制或软链到该仓库的 `.cursor/skills/planning-with-files-ext/`。
- 安装后，由 Agent 在「新项目落地 planning」类需求下读取 `SKILL.md` 并执行其中的 bootstrap 命令；也可在本地手动执行脚本（见下）。

## 使用方式（手动）

### 多项目：README 声明 + `configure-from-readme.sh`（推荐）

业务项目根 `README.md` 加入 `<!-- shared-skills-config` … `planning_with_files_ext=1` … `-->`，并执行 shared-skills 根目录的 `configure-from-readme.sh`（典型：`bash .cursor/shared-skills/configure-from-readme.sh`）。详见上级目录 `README.human.md`「README 驱动一键配置」。

### 单项目：直接跑 `bootstrap.sh`

1. 将本目录放在任意可引用路径（例如本 monorepo 的 `shared-skills/planning-with-files-ext/`，或目标项目下的 `doc/plans/template/`）。
2. 在**目标项目根目录**执行：

```bash
bash /path/to/planning-with-files-ext/bootstrap.sh
# 或显式指定目标根目录：
bash /path/to/planning-with-files-ext/bootstrap.sh /path/to/target/repo
# 如不希望自动安装 planning-with-files-zh：
bash /path/to/planning-with-files-ext/bootstrap.sh /path/to/target/repo --no-install-planning-with-files-zh
```

3. 脚本会创建/覆盖以下文件：
   - `.cursor/rules/planning-with-files.mdc`
   - `.cursor/hooks.json`
   - `.cursor/hooks/user-prompt-submit.sh`
   - `.cursor/hooks/pre-tool-use.sh`
   - `.cursor/hooks/post-tool-use.sh`
   - `.cursor/hooks/stop.sh`
   - `doc/plans/new-plan.sh`
   - `doc/plans/plan.sh`
    - `doc/plans/planning-paths.sh`

## 说明

- 默认采用三文件工作流（`task_plan.md`/`findings.md`/`progress.md`）。
- `execution_brief.md` 为按需输出，不强制自动创建。
- 模板会设置 hooks 与脚本可执行权限（`chmod +x`）。
- 默认会检查本机 `~/.agents/skills/planning-with-files-zh/SKILL.md`，若存在则自动安装到目标仓库 `.cursor/skills/planning-with-files-zh/`（优先软链，失败则复制；若目标已存在不同版本则中断并打印 diff）。
- **若目标项目已有 `.cursor/hooks.json`**：脚本会先与模板内容做**字节级比对**；**完全一致**则继续（可安全重复执行）；**不一致则立即退出**（exit 1），并在 stderr 打印 **unified diff** 与合并/备份建议，不会覆盖原文件。
