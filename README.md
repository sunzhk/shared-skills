<!--
UpdatedAt: 2026-04-14 16:20:00 +0800
LatestChange: open-spec-cn 命令初始化兼容 `.claude/commands/opsx` 与 `.codex/skills` 目录结构。
-->

# shared-skills 总纲

<!-- shared-skills-config
# configure-from-readme.sh 只接受 shared_skill_links。
shared_skill_links=eng-practices,code-styleguide-skills,unit-test-guide-skills,open-spec-cn
-->

本仓库用于维护一组面向 Claude / Codex 的共享技能。当前版本从仓库层面明确为 **skills.sh 唯一分发路径**，不再推荐或兼容 submodule、subtree、npm 私包、旧键名与历史路径回退。

## Breaking Change

- 分发主路径只有 `skills.sh`。
- `configure-from-readme.sh` 只接受 `shared_skill_links`，遇到旧键或未知键会直接失败。
- `open-spec-cn` 的命令初始化支持 `OPSX_COMMANDS_DIR`、`.claude/commands(/opsx)`、`.codex/commands`、`.codex/skills` 四种目录形态。
- 回滚方式只依赖 git 版本回退，不依赖脚本中的兼容分支。

## 唯一安装路径

以 skills.sh 页面生成的命令为唯一真相源。当前仓库对应安装命令如下：

```bash
npx skills add sunzhk/shared-skills --skill eng-practices
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
npx skills add sunzhk/shared-skills --skill unit-test-guide-skills
npx skills add sunzhk/shared-skills --skill open-spec-cn
```

首发入口技能建议为：

- `eng-practices`
- `code-styleguide-skills`
- `unit-test-guide-skills`
- `open-spec-cn`

## 文档导航

- 人类使用手册：`README.human.md`
- AI 运行规则：`README.ai.md`
- 代码风格技能说明：`code-styleguide-skills/README.md`
- OpenSpec 中文规范：`open-spec-cn/SKILL.md`
- 仓库内 AGENTS 生成脚本：`configure-from-readme.sh`

## 当前技能目录

- `code-styleguide-skills/`
  - 入口：`code-styleguide-skills`
  - 路由：`styleguide-router`
- `eng-practices/`
  - 入口：`eng-practices`
- `unit-test-guide-skills/`
  - 入口：`unit-test-guide-skills`
  - 路由：`unit-test-router`
  - 子技能：`unit-test-android`、`unit-test-ios`、`unit-test-wechat-miniprogram`
- `open-spec-cn/`
  - 入口：`open-spec-cn`
  - 脚本：`open-spec-cn/scripts/install-open-spec-cn.sh`

## configure-from-readme.sh 的定位

`configure-from-readme.sh` 现在只承担一件事：读取仓库根 `README.md` 与业务项目 `README.md` 中的 `<!-- shared-skills-config -->` 块，校验入口技能，并按 `--target claude|codex|both` 写入业务项目 `AGENTS.md` 的 `## Shared Skills` 节。

它不是发布或安装入口；正式分发与安装以 skills.sh 为准。

## 本次提交建议（Commit Message）

```text
refactor(init): make each shared skill self-initializing and remove shared init script
```

可选中文版本：

```text
重构(init): 四个共享技能改为自包含初始化，移除公共 init-shared-skill 脚本
```
