<!--
UpdatedAt: 2026-04-14 17:05:00 +0800
LatestChange: 修复 open-spec-cn 的命令同名折叠问题，并支持 `--all-targets` 同次初始化 Claude + Codex。
-->

# shared-skills（给 AI 看的运行规则）

本文档面向 Claude / Codex Agent，用于保证技能触发稳定、路由一致、输出可执行。

## 0. 分发与安装边界

- 唯一推荐分发路径：`skills.sh`
- 不再推荐：submodule、subtree、npm 私包、旧路径回退
- 若用户要安装本仓库技能，优先引导到 skills.sh 页面生成的安装命令

当前仓库对应安装命令：

```bash
npx skills add sunzhk/shared-skills --skill eng-practices
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
npx skills add sunzhk/shared-skills --skill unit-test-guide-skills
npx skills add sunzhk/shared-skills --skill open-spec-cn
```

## 1. 冷启动规则

当用户要求“安装 shared-skills”“接入共享技能”“启用某个入口技能”时：

1. 优先说明本仓库以 skills.sh 为唯一安装路径。
2. 引导用户使用 skills.sh 页面生成的实际安装命令。
3. 不要再推荐 submodule、npm 包或 `.cursor` 历史路径。

只有在用户明确要求“根据 README 生成 `AGENTS.md`”或仓库维护者在本地检出本仓库时，才使用 `configure-from-readme.sh`。

## 2. configure-from-readme.sh 使用规则

脚本用途：根据 `README.md` 中的 `<!-- shared-skills-config -->` 生成业务项目 `AGENTS.md` 的 `## Shared Skills` 节。

### 2.1 允许的配置键

只允许：

- `shared_skill_links`

任何旧键、LeanSpec 键或未知键都视为错误，脚本应快速失败。

### 2.2 执行方式

```bash
bash /path/to/shared-skills/configure-from-readme.sh [--target claude|codex|both] [target_project_root]
```

- `--target claude`：写入 `.claude/shared-skills/...`
- `--target codex`：写入 `.codex/shared-skills/...`
- `--target both`：同时写入 Claude + Codex，两组路径分节输出

### 2.3 配置合并规则

1. 先读 shared-skills 仓库根 `README.md` 的默认块。
2. 再读业务项目 `README.md` 的同名块覆盖。
3. 若两处都无配置块，失败。
4. 若 `shared_skill_links` 为空或解析后为空，失败。

### 2.4 路由展开规则

- 当前四个入口技能均直接解析到各自目录根 `SKILL.md`
- `code-styleguide-skills` 的默认请求再委托给 `styleguide-router`
- `unit-test-guide-skills` 的默认请求再委托给 `unit-test-router`

## 3. 技能路由

### 3.1 `code-styleguide-skills`

触发条件：

- 代码风格统一
- 命名、注释、可读性改进
- 某语言是否符合规范

执行要点：

- 若用户显式要求 `/code-styleguide-skills init`，运行 `code-styleguide-skills/scripts/init-code-styleguide-skills.sh`
- 其他情况先读取 `code-styleguide-skills/SKILL.md`
- 默认由顶层 skill 委托给 `styleguide-router`

### 3.2 `eng-practices`

触发条件：

- PR/CL 评审策略
- review 评论措辞
- 必改项与建议项分级
- 审查冲突与提速策略

### 3.3 `unit-test-guide-skills`

触发条件：

- 单元测试规范
- 按 Android / iOS / 微信小程序给出测试策略
- mock、fake、分层、覆盖率建议

执行要点：

- 若用户显式要求 `/unit-test-guide-skills init`，运行 `unit-test-guide-skills/scripts/init-unit-test-guide-skills.sh`
- 其他情况先读取 `unit-test-guide-skills/SKILL.md`
- 默认由顶层 skill 委托给 `unit-test-router`

### 3.4 `open-spec-cn`

触发条件：

- OpenSpec 中文规范
- Requirement 中 `MUST/SHALL` 约束
- 需要生成 `/opsx-*-cn` 命令

执行要点：

- 若用户显式要求 `/open-spec-cn init`，执行 `open-spec-cn/scripts/init-open-spec-cn.sh`
- 若用户显式要求 `/open-spec-cn commands-init`，执行 `open-spec-cn/scripts/install-open-spec-cn.sh`
- 若用户要求“Claude + Codex 一次同时初始化”，执行 `open-spec-cn/scripts/install-open-spec-cn.sh --all-targets`
- 其他情况读取 `open-spec-cn/SKILL.md`
- 命令初始化目录支持 `OPSX_COMMANDS_DIR`、`.claude/commands(/opsx)`、`.codex/commands`、`.codex/skills`

### 3.5 `configure-from-readme.sh`

触发条件：

- 用户明确要求“按 README 生成 AGENTS.md”
- 仓库维护者在本地验证 `shared_skill_links` 是否可解析

不要在普通安装场景里把它当成 skills.sh 的替代方案。

## 4. 冲突优先级

1. 项目明确约定
2. 本仓库 shared-skills
3. 官方公开指南
4. 个人偏好

## 5. 输出约束

- 结论优先
- 最小充分
- 不改业务语义
- 需要分级时使用 Required / Nit / Optional / FYI

## 6. 自检清单

1. 是否命中正确入口技能？
2. 是否误用了旧链路或旧路径？
3. 如果用了 `configure-from-readme.sh`，是否只使用了 `shared_skill_links`？
4. 如果用了 `open-spec-cn`，是否只使用了允许的命令目录？
