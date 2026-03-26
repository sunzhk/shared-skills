---
name: unit-test-ios
description: >
  iOS 项目单元测试子技能：围绕 Swift/ObjC 业务逻辑与状态管理，
  给出 XCTest 语境下可执行的测试分层、依赖替身与覆盖建议。由 unit-test-router 分发进入。
---

<!--
UpdatedAt: 2026-03-26 16:54:25
LatestChange: 以 Apple 官方 XCTest/Swift Testing 文档为基线重写规则，补充测试金字塔与异步测试规范。
-->

# unit-test-ios（子技能）

## 目标

在 iOS 语境下输出可执行的单元测试规范，重点覆盖：

- 基于 Apple 官方测试框架（XCTest / Swift Testing）的单元测试基线。
- 业务逻辑与状态变更的可验证性。
- 异步测试稳定性与可诊断性。

## 关联关系

- 主入口：`../unit-test-router/SKILL.md`
- 风格规范：`../../code-styleguide-skills/styleguide-router/SKILL.md`（若已接入）
- 官方基线：
  - `https://developer.apple.com/documentation/xctest`
  - `https://developer.apple.com/documentation/testing`
  - `https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode`
  - `https://developer.apple.com/documentation/XCTest/asynchronous-tests-and-expectations`

## 官方基线（必须优先遵循）

- **框架选型**：
  - XCTest：官方成熟方案，覆盖单元/UI/性能测试。
  - Swift Testing（Xcode 16+）：新项目可优先采用；可与 XCTest 共存，但同一测试内不混用 API。
- **测试分层**（Apple 推荐测试金字塔）：
  - 大量快速且隔离良好的单元测试。
  - 少量集成测试。
  - 更少量 UI 测试（高保真但更慢）。
- **异步测试**：
  - 对 `async/await` 代码，测试方法使用 `async` / `async throws`。
  - 非并发模型场景使用 expectation + timeout，避免无界等待。
- **可测性**：通过解耦与依赖替换提高可覆盖率和稳定性。

## 执行规则

- 单元测试聚焦业务层，不在此层验证 UI 像素与布局。
- 采用 XCTest 或 Swift Testing 之一完成同一条测试，不混用两套断言/生命周期 API。
- 异步逻辑优先使用 `async/await` 或 XCTest expectation，不使用不稳定延时。
- 通过协议抽象边界依赖，测试中注入可控替身。
- 断言要体现业务期望，避免仅断言“函数被调用”。
- 新增功能默认至少覆盖一条成功路径与一条失败路径。
- 关键路径可增加性能测试，防止回归。

## iOS 单元测试检查点（按需输出 3~7 条）

- 关键业务类型（UseCase/Service/Reducer）是否存在对应测试文件？
- 是否覆盖输入合法、边界、异常三个维度？
- 异步测试是否使用官方推荐模式（`async/await` 或 expectation + timeout）？
- 对网络、存储、时间等外部依赖是否已解耦并可替换？
- 状态机或 reducer 是否覆盖关键分支与状态转移？
- 测试命名是否体现 Given-When-Then 语义？
- 是否避免过度依赖私有实现细节导致脆弱测试？
- 测试分布是否符合“单元多、UI少”的金字塔原则？

## 推荐输出结构

1. 当前测试成熟度判断（1~2 句）。  
2. 优先补齐的风险点（最多 3 条）。  
3. 可执行任务清单（3~5 条）。  

## 变更记录（简）

| UpdatedAt | LatestChange |
| --- | --- |
| 2026-03-26 16:43:36 | 初版：新增 iOS 单元测试规范与检查点。 |
| 2026-03-26 16:54:25 | 以 Apple 官方测试文档为基线，补充框架选型、测试金字塔与异步测试规则。 |
