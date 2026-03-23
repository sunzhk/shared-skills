<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# HTML/CSS Code Style Skill

## 目标

基于 Google HTML/CSS Style Guide，为 HTML、CSS（含 Sass/GSS）代码提供可执行的风格约束，用于：

- Code Review：快速识别语义化、可访问性、结构分离、命名与格式问题。
- 风格统一：在不改变页面行为前提下降低样式冲突和维护成本。
- 输出建议：将规范落为“检查点 + 最小示例”，避免抽象口号式建议。

## 规范来源与优先级

1. 项目/团队约定（若已有 formatter、stylelint、模板规范，以其为准）。
2. 本 HTML/CSS skill（本文）。
3. Google HTML/CSS Style Guide（官方原文）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 通用规则（General）

- **资源协议统一 HTTPS**：外链脚本、样式、媒体优先 `https:`，避免 `http:` 或协议省略写法。
- **统一 UTF-8 编码**：HTML 使用 `<meta charset="utf-8">`；文件编码保持 UTF-8（无 BOM）。
- **2 空格缩进**：统一使用空格，不混用 Tab；清除行尾空白。
- **大小写统一小写**：HTML 元素/属性、CSS 选择器/属性/值统一小写（字符串内容除外）。
- **TODO 标记规范**：待办统一使用 `TODO:` 前缀，不使用 `@@` 等自定义标签。

### HTML 结构与语义（HTML semantics）

- **文档类型**：页面首部使用 `<!doctype html>`，避免 quirks mode。
- **语义化元素优先**：按用途选标签（如标题用 `h*`、链接用 `a`），不滥用 `div` 承担语义角色。
- **多媒体可访问性**：图片提供有意义 `alt`；纯装饰图用 `alt=""`；音视频尽量提供字幕/文本替代。
- **结构/表现/行为分离**：避免内联样式与内联行为，HTML 仅承载结构语义。
- **属性引号规范**：HTML 属性值使用双引号。
- **非必要属性省略**：样式和脚本默认类型下省略 `type` 属性。
- **谨慎使用 `id`**：优先 `class`（样式）和 `data-*`（脚本）；必要 `id` 值包含连字符（如 `user-profile`）。

### HTML 格式（HTML formatting）

- **块级/列表/表格换行**：相关元素独立成行，子元素按层级缩进。
- **长行一致换行**：属性过长时采用项目统一换行方案，续行缩进能清晰区分属性与子节点。
- **可选标签策略一致**：若项目选择省略可选标签（如部分闭合标签），应在项目内一致执行。

### CSS 选择器与命名（CSS selectors / naming）

- **类名语义化**：类名表达业务含义或通用职责，避免展示型命名（如 `red-text`）和无意义命名。
- **类名连字符分词**：多词类名使用 `kebab-case`（如 `user-card`），避免下划线或驼峰。
- **避免 ID 选择器**：优先类选择器，降低耦合与选择器冲突风险。
- **避免类型限定类**：非必要不写 `div.error`、`ul.nav` 这类“标签+类”限定。
- **大项目可加前缀**：需要跨系统嵌入时使用应用前缀命名空间（如 `app-`）。

### CSS 声明与格式（CSS declarations / formatting）

- **优先简写属性**：可用简写时优先简写（如 `padding`、`font`、`border`）。
- **零值单位**：`0` 通常不带单位（确有兼容要求除外）。
- **小数前导零**：`0.8` 而非 `.8`。
- **十六进制颜色可缩写则缩写**：如 `#ebc` 优于 `#eebbcc`。
- **避免 `!important`**：通过层级与选择器权重解决覆盖关系。
- **声明格式统一**：`property: value;`，冒号后一个空格，每条声明以分号结束。
- **规则分隔清晰**：规则间空一行；多选择器和多声明分行书写。

## 最小示例

### HTML：结构语义与属性约束

```html
<!doctype html>
<meta charset="utf-8">
<title>Profile</title>

<a href="/recommendations/">All recommendations</a>
<img src="/img/spreadsheet.png" alt="Spreadsheet screenshot.">
<link rel="stylesheet" href="https://example.com/app.css">
<script src="https://example.com/app.js"></script>
```

### HTML：避免内联样式与行为

```html
<!-- Yes -->
<button class="menu-button" data-action="open-menu">Menu</button>

<!-- No -->
<button style="color:red" onclick="openMenu()">Menu</button>
```

### CSS：命名与声明格式

```css
.user-card {
  border-top: 0;
  color: #ebc;
  font: 100%/1.6 palatino, georgia, serif;
  margin: 0;
  padding: 0 1em 2em;
}
```


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 常见冲突与处置

- **规范冲突**：优先级始终为“项目约定 > 本文 > 官方参考”。
- **工具与人工结论冲突**：优先保证可读性与一致性，并在评审中记录取舍理由。
- **增量与全量冲突**：优先保证本次修改范围一致，避免在无关区域引入大规模格式噪音。

## 工程化命令（本地/CI）

- 本地：`prettier -w "**/*.{html,css}"`
- CI：`prettier -c "**/*.{html,css}"`

## 本 skill 的回答方式（输出模板）

当用户给出 HTML/CSS 代码、模板文件或样式问题时，按以下结构输出：

1. **适用范围判定**：HTML/CSS + 涉及点（语义化、可访问性、结构分离、命名、格式、兼容性）。
2. **结论（3-10 条检查点）**：优先指出高风险项（可访问性缺失、内联样式/脚本、ID 过载、`!important` 滥用）。
3. **最小示例**：仅给必要的正确/错误对照或 before/after。
4. **不改变语义声明**：默认仅做风格与可维护性改进，除非用户明确要求行为重构。

## 参考

- [Google HTML/CSS Style Guide（官方）](https://google.github.io/styleguide/htmlcssguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
