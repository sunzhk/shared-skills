# shared-skills

本仓库维护一组面向 Claude / Codex 的共享技能。当前唯一推荐的安装和管理路径是 `skills.sh` / `npx skills add`；不再通过脚本写入业务项目 `AGENTS.md`。

## Installation

安装仓库内所有技能：

```bash
npx skills add sunzhk/shared-skills --skill '*'
```

如需同时安装到所有支持的 agent，可使用 `--all`：

```bash
npx skills add sunzhk/shared-skills --all
```

也可以按入口技能安装：

```bash
npx skills add sunzhk/shared-skills --skill eng-practices
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
npx skills add sunzhk/shared-skills --skill unit-test-guide-skills
npx skills add sunzhk/shared-skills --skill open-spec-cn
npx skills add sunzhk/shared-skills --skill git-commit-message
```

## Updates

更新已安装技能：

```bash
npx skills update
```

只更新指定技能：

```bash
npx skills update git-commit-message
```

限定更新范围：

```bash
npx skills update -p
npx skills update -g
```

## Available Skills

| Skill | Purpose |
| --- | --- |
| `eng-practices` | 代码评审流程、评论方式、Required/Nit/Optional 分级、冲突处理。 |
| `code-styleguide-skills` | 多语言代码风格建议，入口会委托 `styleguide-router` 分发到具体语言。 |
| `unit-test-guide-skills` | 单元测试规范建议，入口会委托 `unit-test-router` 分发到 Android / iOS / 微信小程序子技能。 |
| `open-spec-cn` | OpenSpec 中文规范、Requirement 关键词约束、`Purpose` 占位清理，以及 `/opsx-*-cn` 命令生成。 |
| `git-commit-message` | 生成、检查或改写 `<type>: <subject>` 格式的 Git commit message。 |

## Usage Notes

- 风格问题优先使用 `code-styleguide-skills`。
- 代码评审流程、评论策略与冲突处理优先使用 `eng-practices`。
- 单元测试规范与补测策略优先使用 `unit-test-guide-skills`。
- OpenSpec 中文规范与命令生成优先使用 `open-spec-cn`。
- 提交信息规范优先使用 `git-commit-message`。

`open-spec-cn` 额外保留领域任务脚本：

```bash
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh [project-root]
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh --all-targets [project-root]
bash /path/to/shared-skills/open-spec-cn/scripts/install-open-spec-cn.sh --codex-prompts [project-root]
```

该脚本用于生成 OpenSpec 中文命令文件，不用于安装 skill 自身。

## Repository Structure

```text
code-styleguide-skills/
eng-practices/
unit-test-guide-skills/
open-spec-cn/
git-commit-message/
```

每个入口 skill 至少包含：

- `SKILL.md`：技能触发和执行说明。
- `agents/openai.yaml`：如存在，用于技能展示元数据。

## Deprecated Paths

以下路径和机制不再支持：

- submodule / subtree / 直接拷贝分发
- npm 私包同步链路
- `.cursor` 历史路径
- 旧配置键，如 `cursor_skill_links`、`lean_spec_*`、`planning_with_files_ext*`
- `configure-from-readme.sh`
- `/xxx init`
- 只负责写入业务项目 `AGENTS.md` 的 `scripts/init-*.sh`

## Maintainer Checks

发布前建议检查：

1. 所有 `SKILL.md` frontmatter 可以通过 `quick_validate.py`。
2. 除 `Deprecated Paths` 章节外，文档中没有残留旧安装路径、`configure-from-readme`、`shared_skill_links` 或 `/xxx init`。
3. `open-spec-cn` 的命令生成脚本仍可按需运行。

示例校验命令：

```bash
for skill in \
  code-styleguide-skills \
  eng-practices \
  unit-test-guide-skills \
  open-spec-cn \
  git-commit-message
do
  python3 /path/to/skill-creator/scripts/quick_validate.py "$skill"
done

rg 'configure-from-readme|shared_skill_links|shared-skills-config|/[^` ]+ init|init-[a-z-]+\.sh' . --glob '!README.md'
```

## Rollback

如发布后发现问题，使用 git 回退到旧版本标签或提交；当前版本不保留旧安装链路的兼容开关。
