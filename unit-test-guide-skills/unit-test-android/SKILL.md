---
name: unit-test-android
description: >
  Android 项目单元测试子技能：围绕 Kotlin/Java 业务层与 ViewModel 层，
  给出可执行的测试边界、Mock 策略与覆盖建议。由 unit-test-router 分发进入。
---

<!--
UpdatedAt: 2026-03-26 16:47:41
LatestChange: 以 Android Developers 官方测试文档为基线重写执行规则，补充 local vs instrumented 边界与依赖约束。
-->

# unit-test-android（子技能）

## 目标

在 Android 语境下输出可执行的单元测试规范，覆盖：

- 基于官方定义区分 local unit test 与 instrumented test。
- 业务逻辑可测试架构（可替换依赖、可隔离验证）。
- 稳定且可维护的测试实现（断言质量、最小 Mock、可重复执行）。

## 关联关系

- 主入口：`../unit-test-router/SKILL.md`
- 风格规范：`../../code-styleguide-skills/styleguide-router/SKILL.md`（若已接入）
- 官方基线：
  - `https://developer.android.com/training/testing/fundamentals`
  - `https://developer.android.com/training/testing/local-tests`
  - `https://developer.android.com/training/testing/instrumented-tests`

## 官方基线（必须优先遵循）

- **测试运行位置**：
  - 本地单元测试：`module/src/test/`，运行在本机 JVM，快，优先用于业务逻辑。
  - 仪器测试：`module/src/androidTest/`，运行在设备/模拟器，慢，仅在必须依赖 Android 框架真实行为时使用。
- **默认策略**：能用 local test 验证的逻辑，不升级为 instrumented test。
- **可测性原则**：业务逻辑避免直接依赖 Android framework；依赖通过接口或注入方式替换。
- **测试隔离原则**：外部依赖使用 test doubles（fake/stub/mock），优先 fake，避免复杂 mock。

## 执行规则

- 优先验证业务规则与状态转换，不把 UI 交互行为当作单元测试主体。
- 每个测试只验证一个业务意图，使用清晰的 Given-When-Then 或 Arrange-Act-Assert 结构。
- 单元测试默认放在 `src/test`，只有涉及真实 framework 行为再放 `src/androidTest`。
- 对网络、数据库、时间、随机数、系统环境等依赖必须隔离并可控。
- 使用 JUnit 作为基础框架；Mock 框架仅用于边界替身，避免过度耦合实现细节。
- 避免 `Thread.sleep` 等不稳定等待；异步逻辑使用可控调度/同步机制。
- 若遇到 `Method ... not mocked`，优先改造代码提升可测性，不依赖 `returnDefaultValues=true` 掩盖问题。

## Android 单元测试检查点（按需输出 3~7 条）

- 测试是否正确放置在 `src/test` 或 `src/androidTest`，且原因清晰？
- 业务核心（计算、判定、状态机）是否覆盖正常/边界/异常三类输入？
- ViewModel/UseCase 是否通过替身依赖验证状态流转，而非依赖真实 framework？
- 是否只在必要处使用 mock，优先 fake/stub 维持可读性？
- 断言是否验证业务结果，不仅是“方法被调用”？
- 异步测试是否稳定可重复（无随机器、无固定睡眠等待）？
- 是否存在“为通过测试而放宽配置”的风险项（如滥用 `returnDefaultValues`）？

## 推荐输出结构

1. 当前测试现状判断（1~2 句）。  
2. 最高优先级风险（最多 3 条）。  
3. 本周可落地任务（3~5 条）。  

## 变更记录（简）

| UpdatedAt | LatestChange |
| --- | --- |
| 2026-03-26 16:43:36 | 初版：新增 Android 单元测试规范与检查点。 |
| 2026-03-26 16:47:41 | 以 Android Developers 官方文档为基线，补充 local/instrumented 分层与官方约束。 |
