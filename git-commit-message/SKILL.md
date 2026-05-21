---
name: git-commit-message
description: >
  Use when generating, checking, rewriting, or explaining Git commit messages
  that must follow the project format `<type><subject>`. Trigger when the user
  asks about commit message format, commit title wording, commit type selection,
  or staged-change commit messages.
---

# git-commit-message

## 目标

规范 Git commit message 的首行格式，帮助用户生成、检查或改写提交信息。

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
| `test` | 增加或调整测试 |
| `chore` | 构建过程或辅助工具变动 |
| `sdk` | 第三方库变动，`subject` 必须注明库名和版本号 |

### 3) subject

- 默认优先使用中文 `subject`；只有当用户明确要求英文，或项目历史明显统一使用英文时，才使用英文。
- 用简短描述说明本次 commit 的目的。
- 优先描述“做了什么”，避免空泛词，如“修改代码”“优化问题”。
- 不以句号结尾。
- 保持单一意图；如果一个提交同时包含多类不相关变更，建议拆分提交。
- `sdk` 类型必须写清第三方库名称和版本号，例如 `<sdk><升级 okhttp 到 4.12.0>`。

## 生成流程

1. 如果用户提供了变更内容，直接据此选择 `type` 和 `subject`。
2. 如果用户要求基于当前仓库生成，并且允许执行命令，优先查看 staged diff；没有 staged diff 时再查看 working tree diff。
3. 若无法判断唯一类型，先给出最可能的 commit message，并说明可选类型差异。
4. 默认优先生成中文 `subject`；若用户明确要求英文，或项目历史明显统一使用英文，则沿用英文。

## 检查流程

检查已有 commit message 时：

1. 验证是否匹配 `<type><subject>`。
2. 验证 `type` 是否在允许列表内。
3. 验证 `subject` 是否为空、过泛、与 `type` 明显不匹配。
4. 对 `sdk` 类型额外验证是否包含第三方库名称和版本号。
5. 输出“是否通过 + 问题 + 建议改写”，不要自动修改提交历史，除非用户明确要求。

## 示例

```text
<feat><新增车辆告警筛选>
<fix><修复登录令牌刷新处理>
<docs><更新部署检查清单>
<style><格式化仪表盘布局代码>
<refactor><简化告警状态映射>
<test><补充轨迹解析器覆盖>
<chore><更新发布构建脚本>
<sdk><升级 retrofit 到 2.11.0>
```
