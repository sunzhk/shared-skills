<!--
UpdatedAt: 2026-03-24 17:05:31
LatestChange: 新建 eng-practices 参考索引，覆盖全站 14 个页面并按角色汇总关键要点。
-->

# Google eng-practices 参考索引（Code Review）

## 说明

- 来源：Google Engineering Practices Documentation（eng-practices）
- 许可：CC-BY 3.0（https://google.github.io/eng-practices/LICENSE）
- 使用方式：本文件用于快速查阅每个页面的核心观点与原文入口；执行时以 `SKILL.md` 为主、以本文件为深读补充。

## 站点路径清单（递归核查）

以下是从 `https://google.github.io/eng-practices/` 递归抓取得到的页面集合（共 14 页）：

1. https://google.github.io/eng-practices/
2. https://google.github.io/eng-practices/review/
3. https://google.github.io/eng-practices/review/developer/
4. https://google.github.io/eng-practices/review/developer/cl-descriptions.html
5. https://google.github.io/eng-practices/review/developer/handling-comments.html
6. https://google.github.io/eng-practices/review/developer/small-cls.html
7. https://google.github.io/eng-practices/review/emergencies.html
8. https://google.github.io/eng-practices/review/reviewer/
9. https://google.github.io/eng-practices/review/reviewer/comments.html
10. https://google.github.io/eng-practices/review/reviewer/looking-for.html
11. https://google.github.io/eng-practices/review/reviewer/navigate.html
12. https://google.github.io/eng-practices/review/reviewer/pushback.html
13. https://google.github.io/eng-practices/review/reviewer/speed.html
14. https://google.github.io/eng-practices/review/reviewer/standard.html

结论：当前公开文档仅包含 code review 主线，不需要拆分多个 skill。

## 根页面

### 首页

- URL: https://google.github.io/eng-practices/
- 重点：
  - 文档聚焦 Google 通用工程实践，目前公开主题为代码评审。
  - 术语：`CL`（changelist）、`LGTM`（Looks Good To Me）。
  - 对外开放许可为 CC-BY 3.0。

### Review 总览

- URL: https://google.github.io/eng-practices/review/
- 重点：
  - 代码评审关注设计、功能、复杂度、测试、命名、注释、风格与文档。
  - 选最合适且能及时响应的 reviewer；可分文件找不同评审人。
  - 结对编程或当面评审在满足条件时可视作有效评审。

### Emergencies

- URL: https://google.github.io/eng-practices/review/emergencies.html
- 重点：
  - 仅在真正紧急场景下放宽质量门槛并强调速度。
  - 典型“非紧急”场景（普通赶进度、周五下班前合入等）不应套用紧急流程。
  - 紧急 CL 事后应补做更完整审查。

## Reviewer 路线（6 页）

### The Standard of Code Review

- URL: https://google.github.io/eng-practices/review/reviewer/standard.html
- 重点：
  - 核心标准：只要 CL 明确提升系统整体 code health，即可倾向批准，无需追求完美。
  - 技术事实和数据高于个人偏好；风格争议以 style guide 为准。
  - 冲突先求共识，必要时线下沟通或升级处理，不让 CL 长期卡住。

### What to Look For in a Code Review

- URL: https://google.github.io/eng-practices/review/reviewer/looking-for.html
- 重点：
  - 首看设计与功能，再看复杂度、测试、命名、注释、风格、文档。
  - 防止过度工程；鼓励解决“当下真实问题”，而非假设性未来问题。
  - 尽量逐行审查并结合上下文；对隐私/安全/并发等领域确保有合适 reviewer。

### Navigating a CL in Review

- URL: https://google.github.io/eng-practices/review/reviewer/navigate.html
- 重点：
  - 三步法：先看整体与描述，再看主干改动，最后按顺序覆盖其余文件。
  - 如发现方向性问题或重大设计问题，应尽早反馈以减少返工。
  - 反馈时保持礼貌并给出可执行替代建议。

### Speed of Code Reviews

- URL: https://google.github.io/eng-practices/review/reviewer/speed.html
- 重点：
  - 关注“响应速度”而非只看总周期；通常一个工作日内需回应。
  - 正在深度编码时可在合理断点后再回评，平衡中断成本。
  - 可用 “LGTM with comments” 降低跨时区与小问题引起的额外延迟。

### How to Write Code Review Comments

- URL: https://google.github.io/eng-practices/review/reviewer/comments.html
- 重点：
  - 评论聚焦代码，不针对人；保持礼貌并解释理由。
  - 在“指出问题”与“给具体指导”之间做平衡。
  - 可标记严重级别（如 `Nit` / `Optional` / `FYI`）以减少误解。

### Handling Pushback in Code Reviews

- URL: https://google.github.io/eng-practices/review/reviewer/pushback.html
- 重点：
  - 先判断作者是否有道理；合理则采纳，不合理则继续基于 code health 解释。
  - “以后再清理”通常不可靠；非紧急场景应尽量在当前 CL 清理。
  - 若长期无法达成一致，按标准页给出的冲突处理路径升级。

## Developer 路线（3 页）

### Writing Good CL Descriptions

- URL: https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- 重点：
  - 描述必须回答“改了什么”和“为什么改”，并可服务未来检索。
  - 首行应短、完整、可独立理解，后续正文补充背景与取舍。
  - 提交前复查描述是否仍与最终代码一致。

### Small CLs

- URL: https://google.github.io/eng-practices/review/developer/small-cls.html
- 重点：
  - 小而自洽的 CL 更快、更稳、更易审查与回滚。
  - 一般建议一个 CL 聚焦一个自包含变更并携带相关测试。
  - 可通过堆叠、横向/纵向拆分、先重构再功能等策略降低单次变更体量。

### How to Handle Reviewer Comments

- URL: https://google.github.io/eng-practices/review/developer/handling-comments.html
- 重点：
  - 不把评论个人化，先理解 reviewer 的建设性意图。
  - 优先改代码和注释，而不是只在评审工具里解释。
  - 有分歧时协作讨论，先求共识，再按标准流程升级。

## 外部入口

- 文档站点：https://google.github.io/eng-practices/
- 官方仓库（便于后续 diff 增量）：https://github.com/google/eng-practices
