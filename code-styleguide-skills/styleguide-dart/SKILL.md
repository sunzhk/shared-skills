---
name: styleguide-dart
description: Use when writing or reviewing dart code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-03-23 16:33:29
LatestChange: 质量精修：去除重复语义参考链接，统一参考来源到官方主链接。
-->

# Dart Code Style Skill

## 目标

基于 Effective Dart，为 Dart 代码提供可执行、可审计、可落地的风格约束，用于：

- Code Review：快速识别命名、文档、用法和 API 设计中的风格问题。
- 风格统一：在不改变业务语义前提下减少写法漂移，提升团队协作效率。
- 输出建议：将规范落到“检查点 + 最小示例 + 执行步骤”，避免空泛原则。

## 规范来源与优先级

1. 项目/团队既有约定（`analysis_options.yaml`、formatter、lint、CI 规则）。
2. 本 Dart skill（本文）。
3. Effective Dart（官方最佳实践）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（Effective Dart 对齐，可执行）

### Style（风格）

- **DO** 使用 `dart format`，并尽量把代码写成 formatter 友好形态。
- **DO** 对所有流程控制语句使用大括号。
- **PREFER** 行宽不超过 80（不能拆分的字面量/URL 例外）。
- **DO** 命名遵循：类型 `UpperCamelCase`、其他标识符 `lowerCamelCase`、文件/目录 `lowercase_with_underscores`。
- **DO** 导入顺序为 `dart:` → `package:` → 相对路径，分段后按字母序。
- **DON'T** 对非私有标识符使用前导下划线。
- **PREFER** 常量使用 `lowerCamelCase`（与 Effective Dart 一致）。
- **DON'T** 显式命名 library（避免过时样板）。

### Documentation（文档）

- **DO** 使用 `///` 编写文档注释，不用块注释做文档。
- **PREFER** 为公共 API 编写文档注释，首句为单句摘要并单独成段。
- **DO** 在文档注释中用方括号引用作用域内标识符（如 `[Future]`、`[Stream]`）。
- **AVOID** 与上下文重复的冗余注释，注释聚焦“为什么/约束”而非“代码翻译”。
- **DO** 把文档注释放在元数据注解之前。
- **DON'T** 同时为 getter 和 setter 重复写同义文档。

### Usage（用法）

- **PREFER** 用字符串插值，而不是 `+` 号拼接；无必要不写 `{}` 包裹插值标识符。
- **DO** 使用集合字面量；**DON'T** 用 `.length` 判断空集合（用 `isEmpty`/`isNotEmpty`）。
- **AVOID** `Iterable.forEach()` + 匿名函数，优先 `for` 循环增强可读性与调试性。
- **PREFER** `async/await`，**DON'T** 在无收益场景滥用 `async`。
- **AVOID** 无 `on` 子句的宽泛 `catch`；需要重抛时使用 `rethrow`。
- **DON'T** 把错误静默吞掉；捕获异常必须说明处理策略。
- **DO** 对 `FutureOr<T>` 歧义场景做 `Future<T>` 判定。
- **DON'T** 显式把变量初始化为 `null`，也不要给参数显式 `= null` 默认值。

### Design（设计）

- **PREFER** 公开声明默认私有化（先私有后公开）。
- **PREFER** 字段和顶层变量使用 `final`，减少可变状态。
- **AVOID** 位置布尔参数（可读性差），优先命名参数。
- **DO** 为函数声明写返回类型与参数类型；避免不完整泛型类型。
- **AVOID** `dynamic`，仅在明确要关闭静态检查时使用。
- **DO** 异步无返回值成员使用 `Future<void>`。
- **AVOID** 返回可空 `Future`/`Stream`/集合类型（优先返回非空容器 + 空集合）。
- **DO** 覆盖 `==` 时同步覆盖 `hashCode` 并满足等价关系规则。

## 工程化落地（Workflow）

- **本地命令**：`dart format .`、`dart analyze`、`dart test` 作为提交前最小检查。
- **CI 校验一致**：CI 使用与本地同版本 SDK 和同套分析规则。
- **规则变更可追踪**：调整 `analysis_options.yaml` 时在 PR 说明影响范围与迁移策略。
- **风格改动独立提交**：批量格式化与功能改动拆分，提升审查效率。

## 常见冲突与处置

- **冲突 1：团队常量想用 `UPPER_SNAKE_CASE`**  
  处置：项目约定优先；若保留该约定，需在文档中标明“偏离 Effective Dart”并保持全仓一致。
- **冲突 2：为了兼容旧代码使用宽泛 `catch`**  
  处置：先加 `on` 子句收窄范围，再分阶段治理遗留异常路径。
- **冲突 3：本地通过、CI 失败**  
  处置：先对齐 SDK 版本与分析规则，再排查 `analysis_options.yaml` 差异。
- **冲突 4：风格改动引发大 diff**  
  处置：拆分“纯风格提交”和“业务提交”，避免审查噪音。

## 执行清单（给开发者）

1. 运行 `dart format .` 统一格式。
2. 运行 `dart analyze` 修复主要告警。
3. 运行 `dart test` 确认行为未回归。
4. 检查本次改动是否包含无关的大面积格式化；若有则拆分提交。
5. 若改了 `analysis_options.yaml`，在 PR 里写清影响与迁移方案。

## 最小示例

### DO：命名与导入顺序

```dart
import 'dart:async';

import 'package:meta/meta.dart';

import '../models/user.dart';

class UserRepository {
  Future<User?> findById(String userId) async => null;
}
```

### PREFER：插值与 `for` 循环

```dart
String buildMessage(String name, int count) {
  var total = 0;
  for (final value in [1, 2, 3]) {
    total += value;
  }
  return 'User $name has $count items, total=$total';
}
```

### DO/AVOID：异常处理与 `rethrow`

```dart
Future<void> loadUser() async {
  try {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  } on TimeoutException {
    rethrow;
  }
}
```

## 工程化命令（本地/CI）

- 本地：`dart format . && dart analyze`
- CI：`dart format --output=none --set-exit-if-changed . && dart analyze`

## 本 skill 的回答方式（输出模板）

当用户给出 Dart 代码、风格问题或审查请求时，按以下结构输出：

1. **适用范围判定**：Style/Documentation/Usage/Design 涉及点。
2. **结论（3-10 条检查点）**：按 DO/DON'T/PREFER/AVOID 分级，先高风险后低风险。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **执行步骤**：给出本地可直接执行的命令（format/analyze/test）。
5. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Effective Dart（官方）](https://dart.dev/effective-dart)
- [dart format（官方工具）](https://dart.dev/tools/dart-format)
- [Dart lints（官方）](https://dart.dev/tools/linter-rules)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
