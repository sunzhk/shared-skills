---
name: unit-test-wechat-miniprogram
description: >
  微信小程序项目单元测试子技能：围绕业务逻辑、数据转换与 wx API 边界，
  给出 Jest 语境下可执行的测试策略与覆盖建议。由 unit-test-router 分发进入。
---

<!--
UpdatedAt: 2026-03-26 16:54:25
LatestChange: 以微信开放文档官方单元测试页面为基线重写规则，补充 miniprogram-simulate 与自动化测试边界。
-->

# unit-test-wechat-miniprogram（子技能）

## 目标

在微信小程序语境下输出可执行的单元测试规范，重点覆盖：

- 以官方“自定义组件单元测试”能力为核心建立可执行基线。
- 业务逻辑函数与数据转换逻辑验证。
- 平台能力边界（`wx` API、组件运行环境）下的可控测试方案。

## 关联关系

- 主入口：`../unit-test-router/SKILL.md`
- 风格规范：`../../code-styleguide-skills/styleguide-router/SKILL.md`（若已接入）
- 官方基线：
  - `https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/unit-test.html`
  - `https://developers.weixin.qq.com/miniprogram/dev/devtools/minitest/autotest.html`
  - `https://github.com/wechat-miniprogram/miniprogram-simulate`

## 官方基线（必须优先遵循）

- **单元测试官方入口**：微信开放文档明确支持对自定义组件进行单元测试，并推荐结合 Node.js + DOM 环境执行。
- **工具基线**：官方测试工具集 `miniprogram-simulate`，用于在 Node.js 单线程环境模拟组件运行。
- **框架基线**：可使用 Jest 或 mocha + jsdom 等能兼顾 Node.js 与 DOM 的框架。
- **能力边界**：测试工具中的 `wx` 对象与内置组件不保证完整真实功能；特殊场景需自行覆盖/替身。
- **覆盖边界**：部分组件特性在工具中可能尚未完整支持，需明确“单测覆盖不到”的范围并补充自动化测试。

## 执行规则

- 优先把可测试逻辑下沉到纯函数/服务层，减少页面实例强耦合。
- 组件单测优先采用 `miniprogram-simulate`（`load`/`render`/`attach` 等模式）验证渲染与交互。
- 对 `wx.request`、`wx.getStorage` 等平台 API 统一 Mock 或替身，避免环境偶发差异。
- 单测聚焦业务分支与数据契约，不替代真机自动化回归。
- 异步测试必须有明确完成条件，避免悬挂测试。
- 失败断言需包含业务语义，便于快速定位。
- 涉及复杂交互、上传、真机能力时，转入微信开发者工具云测自动化能力（Monkey/录制回放/自定义）。

## 微信小程序单元测试检查点（按需输出 3~7 条）

- 关键业务函数是否已从页面逻辑拆分并可独立测试？
- 数据转换与参数校验是否覆盖正常/边界/异常输入？
- 自定义组件测试是否采用 `miniprogram-simulate` 并正确挂载组件树？
- `wx` API 是否通过统一适配层或集中 Mock 管理？
- 网络失败、超时、空数据等异常分支是否有测试？
- 异步流程是否正确等待并断言最终状态？
- 测试命名是否能直接映射到业务场景？
- 是否避免只验证调用次数而忽略业务结果？
- 对工具能力未覆盖场景，是否明确补了自动化测试策略？

## 推荐输出结构

1. 当前测试薄弱点（1~2 句）。  
2. 最高优先级修补项（最多 3 条）。  
3. 本周落地任务（3~5 条）。  

## 变更记录（简）

| UpdatedAt | LatestChange |
| --- | --- |
| 2026-03-26 16:43:36 | 初版：新增微信小程序单元测试规范与检查点。 |
| 2026-03-26 16:54:25 | 以微信开放文档为基线，补充 miniprogram-simulate 与单测/自动化测试边界。 |
