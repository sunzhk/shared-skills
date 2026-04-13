---
name: unit-test-router
description: >
  单元测试规范主控入口（router）：识别 Android/iOS/微信小程序场景，
  分发到 unit-test-android / unit-test-ios / unit-test-wechat-miniprogram。
  统一输出结构，确保建议可直接落地。
---

<!--
UpdatedAt: 2026-03-26 16:56:31
LatestChange: 增加分发后的官方文档清单输出要求，确保每次路由都附带平台权威来源。
-->

# unit-test-router（主控 / 路由）

本文件通常由顶层入口 `unit-test-guide-skills/SKILL.md` 委托调用；若用户显式使用 `/unit-test-guide-skills init`，应优先执行顶层 skill 的初始化逻辑，而不是直接进入本 router。

## 目标

本 skill 是 `unit-test-guide-skills` 的总入口，负责：

- 识别用户当前项目类型（Android / iOS / 微信小程序）。
- 分发到对应子 skill，避免把三端细节混在一起。
- 统一输出模板，让建议可执行、可检查、可接入 CI。

## 适用范围

- 用户问“单元测试怎么写/怎么补/怎么落地”。
- 用户需要按平台给测试框架、测试边界、Mock 策略、覆盖策略建议。
- 用户需要将测试建议转成任务清单或验收清单。

## 不做什么（边界）

- 不替代具体业务测试用例设计评审。
- 不输出与项目现状无关的大而全理论。
- 不绕开项目既有测试基建与门禁规则。

## 冲突裁决（优先级）

1. 项目内已有测试规范与 CI 规则。  
2. 本技能组（router + 子 skill）。  
3. 平台官方测试实践。  
4. 个人偏好。  

## 分发规则（场景 → 子 skill）

| 判定依据（关键词 / 路径 / 技术栈） | 子 skill 路径 |
| --- | --- |
| Android（Kotlin/Java、Gradle、`android/`、JUnit、Robolectric） | `../unit-test-android/SKILL.md` |
| iOS（Swift/ObjC、Xcode、XCTest、SPM/CocoaPods） | `../unit-test-ios/SKILL.md` |
| 微信小程序（`miniprogram`、JS/TS、Jest、`wx` API） | `../unit-test-wechat-miniprogram/SKILL.md` |
| 多端同时出现 | 按端分别引用子 skill，最后合并一份统一测试任务清单 |
| 信息不足 | 先补 2~3 个澄清问题，再分发 |

## 官方文档映射（分发后必须附带）

- Android：
  - `https://developer.android.com/training/testing/fundamentals`
  - `https://developer.android.com/training/testing/local-tests`
  - `https://developer.android.com/training/testing/instrumented-tests`
- iOS：
  - `https://developer.apple.com/documentation/xctest`
  - `https://developer.apple.com/documentation/testing`
  - `https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode`
- 微信小程序：
  - `https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/unit-test.html`
  - `https://developers.weixin.qq.com/miniprogram/dev/devtools/minitest/autotest.html`
  - `https://github.com/wechat-miniprogram/miniprogram-simulate`

## 交互输出模板（必须遵循）

1. **场景判定**：给出平台判断依据。  
2. **子 skill 指向**：明确写出下一步应读取的 `unit-test-*/SKILL.md`。  
3. **官方依据**：按平台附上对应官方文档链接（至少 2 条）。  
4. **测试策略结论**：3~7 条可执行检查点。  
5. **落地动作**：给出最小任务清单（本周可完成）。  

## 变更记录（简）

| UpdatedAt | LatestChange |
| --- | --- |
| 2026-03-26 16:43:36 | 初版：新增 router 分发规则与输出模板。 |
| 2026-03-26 16:56:31 | 新增官方文档映射与“分发后必须附带官方依据”输出约束。 |
