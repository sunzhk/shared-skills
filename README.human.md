# shared-skills（给人看的说明）
<!--
UpdatedAt: 2026-04-14 17:05:00 +0800
LatestChange: 修复 open-spec-cn 的命令同名折叠问题，并支持 `--all-targets` 同次初始化 Claude + Codex。
-->

本文档面向开发者与仓库维护者，说明 shared-skills 的用途、安装方式、仓库内验证方式，以及发布前需要完成的检查。

## Breaking Change

当前版本只支持一条主路径：`skills.sh`。

以下内容都已从支持范围中移除：

- submodule / subtree / 直接拷贝分发
- npm 私包同步链路
- 旧配置键（如 `cursor_skill_links`、`lean_spec_*`、`planning_with_files_ext*`）
- 旧路径变量（如 `CURSOR_SHARED_SKILLS_REL`）
- `.cursor` 相关命令目录与路径回退

如果需要回滚，请直接回到旧版本 git 提交，而不是依赖当前版本里的兼容逻辑。

## 包含的技能

### `eng-practices`

- 用途：代码评审流程、评论方式、优先级表达。
- 典型场景：PR/CL 评审、Required/Nit/Optional 分级、冲突处理。

### `code-styleguide-skills`

- 用途：多语言代码风格建议。
- 典型场景：重构风格统一、可读性改进、语言级规范纠偏。
- 入口 skill：`code-styleguide-skills`。
- 初始化：`/code-styleguide-skills init`。

### `unit-test-guide-skills`

- 用途：按平台输出单元测试规范与执行建议。
- 典型场景：补测试、测试分层设计、mock/fake 策略、验收清单。
- 入口 skill：`unit-test-guide-skills`。
- 初始化：`/unit-test-guide-skills init`。

### `open-spec-cn`

- 用途：统一 OpenSpec 中文规范与 Slash 命令生成规则。
- 典型场景：规范 Requirement 文案、清理 `Purpose` 占位文本、生成 `/opsx-*-cn` 命令。

## 唯一安装路径：skills.sh

本仓库按“整包维护、按入口技能安装”的方式发布。当前仓库对应安装命令如下：

```bash
npx skills add sunzhk/shared-skills --skill eng-practices
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
npx skills add sunzhk/shared-skills --skill unit-test-guide-skills
npx skills add sunzhk/shared-skills --skill open-spec-cn
```

建议优先安装的入口技能：

```bash
npx skills add sunzhk/shared-skills --skill eng-practices
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
npx skills add sunzhk/shared-skills --skill unit-test-guide-skills
npx skills add sunzhk/shared-skills --skill open-spec-cn
```

## 日常使用建议

1. 风格问题优先走 `code-styleguide-skills`。
2. 评审流程、评论策略与冲突处理优先走 `eng-practices`。
3. 单元测试规范与补测策略优先走 `unit-test-guide-skills`。
4. OpenSpec 中文规范与命令生成优先走 `open-spec-cn`。

## configure-from-readme.sh 的用途

`configure-from-readme.sh` 不是安装脚本，而是仓库内的配置生成工具。它适合两类场景：

- 在本地检出本仓库后，为业务项目生成 `AGENTS.md` 的 `## Shared Skills` 节。
- 在发布前验证 `shared_skill_links` 是否能被正确解析并写出 Claude / Codex 的入口路径。

### 支持的配置键

只支持：

```markdown
<!-- shared-skills-config
shared_skill_links=eng-practices,code-styleguide-skills,unit-test-guide-skills,open-spec-cn
-->
```

不支持：

- 旧键名
- LeanSpec 规划键
- 任意未知键

出现以上配置时，脚本会直接失败。

### 用法

```bash
bash /path/to/shared-skills/configure-from-readme.sh [--target claude|codex|both] [target_project_root]
```

默认 `target=both`，写入业务项目根目录的 `AGENTS.md`：

- `claude`：`.claude/shared-skills/...`
- `codex`：`.codex/shared-skills/...`
- `both`：同时写入上述两套路径

### 配置块合并规则

1. 先读取 shared-skills 仓库根 `README.md` 里的默认块。
2. 再读取业务项目根 `README.md` 的同名块覆盖。
3. 若两处都没有配置块，脚本失败。
4. 若 `shared_skill_links` 为空或解析后为空，脚本失败。

## open-spec-cn 命令初始化

`open-spec-cn/scripts/install-open-spec-cn.sh` 的目录解析规则为：

1. `OPSX_COMMANDS_DIR`
2. `<project-root>/.claude/commands`（兼容 `<project-root>/.claude/commands/opsx`）
3. `<project-root>/.codex/commands`
4. `<project-root>/.codex/skills`

若以上路径都不存在，脚本会创建 `<project-root>/.claude/commands/opsx`。生成策略如下：

- Claude 命令目录：基于 `opsx-*.md` 或 `opsx/*.md` 生成 `*-cn.md`。
- Codex skills 目录：基于 `openspec-*` 生成 `openspec-*-cn` skills 目录。
- 若需一次初始化多个目标，使用 `--all-targets`。

## 发布前检查

在仓库根目录执行以下检查：

1. `SKILL.md` frontmatter 完整性
2. `configure-from-readme.sh` 的 `default / claude / codex / both` 四组验证
3. `open-spec-cn` 的命令生成验证
4. 文档扫描，确认无 submodule / npm / `.cursor` / 旧键说明残留

建议命令：

```bash
find . -name SKILL.md -type f -print0 | while IFS= read -r -d '' f; do
  fm="$(awk 'NR==1 && $0=="---" {in_fm=1; next} in_fm && $0=="---" {exit} in_fm {print}' "$f")"
  printf '%s\n' "$fm" | grep -q '^name:[[:space:]]*' || echo "$f missing name"
  printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*' || echo "$f missing description"
done
```

## 回滚策略

- 使用 git 回退到旧版本标签或提交。
- 不在当前版本中保留任何向后兼容开关。
- 若发布后发现问题，修复方式应当是新提交或版本回滚，而不是恢复旧兼容分支。
