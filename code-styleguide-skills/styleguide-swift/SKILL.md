---
name: styleguide-swift
description: Use when writing or reviewing swift code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

## 目标

基于 Google Swift Style Guide（Google Swift），为 Swift 代码提供**可执行**的风格约束，用于：

- Code Review：快速识别文件结构、格式化、命名、注释与常见 Swift 语法实践的偏差。
- 风格统一：在不改变业务语义的前提下统一书写习惯，降低维护成本。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目已统一 SwiftFormat/SwiftLint 等工具与规则，以其为准）。
2. 本 Swift skill（本文）。
3. Google Swift Style Guide（官方原文）+ Apple API Design Guidelines（该指南明确纳入）。

当冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心检查清单（可执行）

### 源文件基础（Source File Basics）

- **文件名**：以 `.swift` 结尾；一般以主要实体命名：
  - 单一类型：`MyType.swift`
  - 给既有类型加协议一致性扩展：`MyType+MyProtocol.swift`
  - 多个扩展/加法：可用 `MyType+Additions.swift` 或更描述性的命名（保持前缀 `MyType+`）。
- **编码**：UTF-8。
- **空白字符**：除换行外只使用 `U+0020` 空格，不用 Tab。
- **转义**：优先使用 `\n/\t/...` 等标准转义；不可见字符必须用 Unicode escape。
- **字符串字面量**：不要在同一字符串中混用“非 ASCII 字符字面量”和 `\u{...}` escape（选一种策略，优先可读）。

### 文件结构（Source File Structure）

- import 是文件中**首个非注释 token**。
- import 分组（组内按字典序），组间**恰好 1 个空行**：
  1. 非测试的 module/submodule imports
  2. 单个声明 imports（`import func ...` 等）
  3. `@testable import ...`（仅测试代码）
- import 不换行。
- 文件/类型成员顺序：必须有**可解释的逻辑顺序**；避免“按添加时间堆末尾”。
- overload 不拆分：同名初始化器/subscript/函数在同一作用域内应连续排列，中间不插入其他代码。
- 允许使用 `// MARK:` 组织成员分组（提升可导航性）。

### 通用格式（General Formatting）

- **列宽**：100 字符。
  - 例外：无法避免的长 URL、import、工具生成代码。
- **大括号**：非空块 K&R 风格；`else` 写成 `} else {`。
  - 空块可写 `{}`。
- **分号**：不使用分号（除非出现在字符串或注释中）。
- **一行一语句**：最多一条语句/行；仅当行末是“包含 0 或 1 条语句的 block”时可单行（如 early return/guard）。

### 换行与断行（Line-Wrapping）

原则：

- 能放一行就放一行。
- 逗号分隔列表只选一种方向：**全横排**或**全竖排**；竖排时每个元素独立一行并按规则缩进。
- continuation line 的缩进规则（核心要点）：
  - 以“不可拆 token 序列”开头的 continuation line：与原行同缩进；
  - 竖排逗号列表的 continuation line：相对原行 **+2**；
  - 多行表达式的第二行：相对原行 **+2**，后续按语法嵌套每层 +2。
- `where` 子句：若与返回类型同行超过列宽，先在 `where` 前断行，`where` 与原行同缩进；仍超长则把约束列表竖排。
- 函数调用断行：每个参数独立一行，缩进 +2；若调用以 `)` 结束，可选择把 `)` 放在末参同行或单独一行。
- trailing closure：
  - 若只有一个闭包且是最后一个参数：优先使用 trailing closure。
  - 若有多个闭包参数：全部写在括号内并标注 label，不使用 trailing closure。
  - 无其他参数时不要写空 `()`：`array.map { ... }`。
  - 控制流语句中可能产生语法歧义时，使用带 label 的闭包参数（例如 `first(where: { ... })`）。

### 空白（Whitespace）

- 二元/三元运算符两侧 1 空格；`.`、`..<`、`...` 两侧不加空格。
- 逗号/冒号规则：
  - 逗号后有空格，前无空格。
  - `:` 后有空格，前无空格（类型标注、字典字面量、协议一致性列表、泛型约束等）。
- 行尾注释：代码与 `//` 之间至少 **2 个空格**，`//` 后**恰好 1 个空格**。
- 数组/字典字面量方括号内侧不加空格：`[1, 2, 3]`，不是 `[ 1, 2, 3 ]`。
- **禁止水平对齐**（alignment），除非明显表格数据；避免因对齐引入维护成本。
- `if/guard/while/switch` 后的顶层表达式不加最外层括号：`if x == 0 {}`，不写 `if (x == 0) {}`。

### 特定构造（Formatting Specific Constructs）

- 实现注释：只用 `//`，不用 `/* ... */`。
- 属性：
  - 局部变量就近声明，缩小作用域；
  - 除 tuple 解构外，`let/var` 一次只声明一个变量。
- switch：
  - `case` 与 `switch` 同缩进；case 内语句缩进 +2。
- enum cases：
  - 默认一行一个 `case`；
  - 只有在“无关联值/无 raw value 且全在一行且无需额外文档”时才可用逗号合并。
  - 不写 `case empty()`（无参 case 不带空括号）。
  - 多个 case 共享实现时用逗号/范围合并，不写“只有 fallthrough”的 case。

### 命名（Naming）

- 遵循 Apple API Design Guidelines（视为本指南的一部分）。
- 不用命名约定做访问控制（优先用 `private/fileprivate/internal`）。
- 全局常量用 lowerCamelCase（不使用 `k`/`g`/全大写常量）。
- initializer 参数名与对应存储属性同名，赋值时显式 `self.` 区分。
- 嵌套优于平铺命名空间：错误类型、flags 等尽量嵌套在相关类型里。
- 用“无 case 的 enum”作为命名空间来分组常量/工具函数（避免 `struct + private init` 容器）。

### 编程实践（Programming Practices）

- 尽量消除编译警告（可接受：短期无法消除的 deprecation）。
- Optional：
  - 避免 sentinel 值（如 -1）；用 `Optional` 表达“无值但非错误”场景。
  - 仅检查是否为 nil 且不使用解包值时，写 `value != nil`，不要写 `if let _ = value`。
- Error：
  - 多错误状态用 `throw` + 自定义错误类型；
  - 一般禁止 `try!`，测试代码与“纯编程错误（REPL 可验证的单表达式字面量）”场景可例外（如 regex 字面量）。
- 强制解包/强制转型：强烈不鼓励；若不是显然安全，必须用注释说明不变量。
- 隐式解包 Optional（`T!`）：尽量避免；UI 生命周期对象（如 `@IBOutlet`）、缺失 nullability 的 ObjC API、测试 fixture 等可例外，但要尽量缩小传播范围。
- access level：不允许在 extension 上写文件级 `public extension`；需要更高可见性时逐成员标注。
- guard 优先用于早退出，减少嵌套；for-where 优先替代“循环体第一句 if 过滤”。
- pattern matching：禁止 `case let .foo(...)` 这种分发式 `let`；对每个绑定显式写 `let/var`。

### 文档注释（Documentation Comments）

- 文档注释必须使用 `///`（每行三斜杠）；禁止 `/** ... */` 形式。
- 文档以“单句摘要”开头并以句号结束；需要更多细节再分段。
- 参数/返回/抛错标签顺序：Parameter(s) → Returns → Throws。
  - 单参用 `- Parameter`；多参用 `- Parameters:` + 子列表。
- `Parameter(s)`/`Returns` 可在“完全不增加信息”时省略，但不要用此作为偷懒借口（读者需要术语解释时必须写清）。


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 常见冲突与处置

- **规范冲突**：优先级始终为“项目约定 > 本文 > 官方参考”。
- **工具与人工结论冲突**：优先保证可读性与一致性，并在评审中记录取舍理由。
- **增量与全量冲突**：优先保证本次修改范围一致，避免在无关区域引入大规模格式噪音。

## 最小示例

```swift
if isReady {
    runTask()
}
```

## 工程化命令（本地/CI）

- 本地：`swiftformat . && swiftlint`（按项目工具链）
- CI：`swiftformat --lint . && swiftlint`

## 本 skill 的回答方式（输出模板）

当用户给出 Swift 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Swift + 涉及点（文件结构/import/断行/命名/Optional/注释等）。
2. **结论（3–10 条检查点）**：逐条对应本规范条目，优先指出“高风险/易踩坑”的点（`try!`、强制解包、隐式解包、alignment、trailing closure 多闭包等）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：默认只做风格层面的调整（除非用户明确要求语义重构）。

## 参考

- [Google Swift Style Guide（官方）](https://google.github.io/swift/)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
- [Swift API Design Guidelines（官方）](https://www.swift.org/documentation/api-design-guidelines/)
