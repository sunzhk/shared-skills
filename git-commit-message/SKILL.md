---
name: git-commit-message
description: >
  Use when generating, checking, rewriting, or explaining Git commit messages
  that must follow the format `<type><subject>`. Trigger when the user asks
  about commit message format, commit title wording, commit type selection,
  or staged-change commit messages.
---

# git-commit-message

## 目标

规范 Git commit message 的首行格式与正文写法，帮助用户生成、检查或改写提交信息。

强制格式：

```text
<type><subject>
```

## 规则

### 1) 格式

- commit message 首行必须严格匹配 `<type><subject>`。
- `type` 和 `subject` 都必须使用英文尖括号包裹。
- 首行不要添加 scope、issue 编号、emoji 或额外前缀，除非用户明确说明项目另有规范。
- 不要使用冒号、空格或其他分隔符替代尖括号格式。
- 若用户只需要首行，只输出一行 commit message。

### 2) type

`type` 只允许使用以下标识：

| type | 含义 |
| --- | --- |
| `feat` | 新功能 |
| `fix` | 修补 bug |
| `docs` | 文档变动 |
| `style` | 格式调整，不影响代码运行 |
| `refactor` | 重构，即不是新增功能，也不是修补 bug 的代码变动 |
| `perf` | 性能优化 |
| `test` | 增加或调整测试 |
| `build` | 构建系统或外部依赖变动（第三方库升级、构建脚本调整） |
| `ci` | CI 配置与脚本变动 |
| `chore` | 其他辅助性杂项（工具、配置、非构建类维护） |
| `revert` | 回滚之前的提交 |
| `sdk` | 公司内部 android-sdk / ios-sdk / web-sdk 三个 SDK 项目的变更，`subject` 必须注明具体 SDK 与变更内容，发版时注明版本号 |

**type 选择依据**：`type` 按变更对象在仓库中的角色判断，而非只看改动形式。

- 在 skill 仓库或库类仓库中，修改本体（`SKILL.md`、源码、规则定义）属于功能变更：新增或增强能力用 `feat`，修正既有规则用 `fix`；`docs` 仅用于 README、CHANGELOG 等说明性文档。
- 同一改动同时包含不同性质（如 `feat` 与 `fix`）时：取主导性质作 `type`，其余在正文说明；若两类变更彼此独立，优先拆分提交。
- 业务仓库按上表语义选择。

### 3) subject

- 用简短描述说明本次 commit 的目的，优先描述“做了什么”，避免空泛词，如“修改代码”“优化问题”。
- 动词开头，如“新增”“修复”“重构”“升级”。
- 必须能凭首行定位改动：subject 应包含变更对象（模块、技能、文件等）并点出具体内容（如新增了哪些类型、修复了什么现象），避免“扩充规则”“更新文档”这类无对象的空泛表述。
- 不超过 50 个字符（中文约一句话）。
- 不以句号结尾。
- 保持单一意图；如果一个提交同时包含多类不相关变更，建议拆分提交。
- 默认优先使用中文 `subject`；若项目历史最近若干条明显统一使用英文，则跟随使用英文，保持仓库日志语言一致。

### 4) 正文（body）

首行之后可以写正文，说明为什么这么改，便于日后追查问题：

- 何时写：变更影响面大、原因不直观、涉及破坏性变更、回滚或迁移时。
- 写什么：
  - 背景与原因：为什么改
  - 改动方式：怎么改
  - 影响范围：涉及哪些模块、是否有破坏性变更
  - 验证方式：如何验证（测试、自测）
  - 关联引用：`Refs #<编号>` / `Fixes #<编号>`（需求、Bug、工单等）
- 模板：

```text
<type><subject>

背景：为什么改
改动：怎么改
影响：涉及哪些模块、是否有破坏性变更
验证：如何验证
关联：Refs #123 / Fixes #456
```

## 生成流程

1. 如果用户提供了变更内容，直接据此选择 `type` 和 `subject`。
2. 如果用户要求基于当前仓库生成，并且允许执行命令，优先查看 staged diff；没有 staged diff 时再查看 working tree diff。
3. 若无法判断唯一类型（含混合性质变更），按仓库角色与主导性质给出最可能的 commit message，并说明可选类型差异。
4. 默认优先生成中文 `subject`；若项目历史最近若干条明显统一使用英文，则沿用英文。
5. 若变更影响面大或原因不直观，按“正文（body）”章节生成正文；否则只生成首行。

## 检查流程

检查已有 commit message 时：

1. 验证是否匹配 `<type><subject>`。
2. 验证 `type` 是否在允许列表内，且与变更对象在仓库中的角色相符（如 skill/库仓库改本体应用 `feat`/`fix` 而非 `docs`）。
3. 验证 `subject` 是否为空、过泛、无变更对象、与 `type` 明显不匹配。
4. 对 `sdk` 类型额外验证是否注明具体 SDK（android/ios/web）与变更内容；发版提交是否注明版本号。
5. 若有正文，验证是否说明原因；涉及破坏性变更时是否标注；关联需求或 Bug 时是否带 `Refs #` / `Fixes #` 编号。
6. 输出“是否通过 + 问题 + 建议改写”，不要自动修改提交历史，除非用户明确要求。

## 示例

```text
<feat><新增车辆告警筛选>
<fix><修复登录令牌刷新处理>
<docs><更新部署检查清单>
<style><格式化仪表盘布局代码>
<refactor><简化告警状态映射>
<perf><优化告警列表渲染性能>
<test><补充轨迹解析器覆盖>
<build><升级 okhttp 到 4.12.0>
<ci><调整发布流水线触发条件>
<chore><更新开发环境配置>
<revert><回滚登录态同步改动>
<sdk><android-sdk 新增登录态同步接口>
<sdk><ios-sdk 修复 token 刷新竞态>
<sdk><web-sdk 发布 2.4.0>
<sdk><升级 android-sdk 到 3.2.0>
```
