<!--
UpdatedAt: 2026-03-26 16:56:31
LatestChange: router 新增官方文档映射与强制输出官方依据规则，统一三端分发后的权威来源引用。
-->

# unit-test-guide-skills

本目录提供一组“单元测试规范”skills，用于在不同项目类型下输出一致、可执行的单元测试建议。

## Skills 入口

| 角色 | 目录 | 说明 |
| --- | --- | --- |
| **主控 / Router** | `unit-test-router/SKILL.md` | 默认总入口：识别项目类型并分发到对应子技能。 |
| **子技能 · Android** | `unit-test-android/SKILL.md` | Android 项目的单元测试规范与落地建议。 |
| **子技能 · iOS** | `unit-test-ios/SKILL.md` | iOS 项目的单元测试规范与落地建议。 |
| **子技能 · 微信小程序** | `unit-test-wechat-miniprogram/SKILL.md` | 微信小程序项目的单元测试规范与落地建议。 |

## 规则优先级（执行期）

1. 项目内已有规范与 CI 门禁（最高）。
2. 本目录 `unit-test-router` 与 `unit-test-*` 子技能。
3. 平台官方文档与社区通行实践。
4. 个人偏好。

## 官方基线说明

- Android 子技能已对齐 Android Developers 官方测试文档（fundamentals/local-tests/instrumented-tests）。
- iOS 子技能已对齐 Apple 官方测试文档（XCTest / Swift Testing / Xcode Testing）。
- 微信小程序子技能已对齐微信开放文档（自定义组件单元测试 + 自动化测试）。
- router 已强制要求：分发到任一平台后，必须附带该平台官方文档链接清单。

## 目录结构约定

- 每个 skill 放在 `<skill-name>/SKILL.md`。
- 新增平台时，先补子技能，再在 `unit-test-router/SKILL.md` 补映射规则。

## 变更记录（简）

| UpdatedAt | LatestChange |
| --- | --- |
| 2026-03-26 16:43:36 | 初版：新增技能组与三端子技能。 |
| 2026-03-26 16:48:38 | Android 子技能升级为官方基线版，并在 README 补充基线说明。 |
| 2026-03-26 16:54:25 | iOS 与微信小程序子技能升级为官方基线版，并补充来源说明。 |
| 2026-03-26 16:56:31 | router 增加官方文档映射与强制输出规则。 |
