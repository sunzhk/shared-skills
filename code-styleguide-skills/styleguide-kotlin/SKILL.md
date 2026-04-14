---
name: styleguide-kotlin
description: Use when writing or reviewing kotlin code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-04-14
LatestChange: 补充 Kotlin/Java 混编空值安全规则，要求未标注 Java 返回值在 Kotlin 边界处显式收敛。
-->

## 目标

基于 Android 官方 Kotlin Style Guide，为 Kotlin 代码提供**可执行**的风格约束，用于：

- Code Review：快速定位格式与命名偏差。
- 重构/改动：在不改变业务语义的前提下统一风格。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目有明确格式化或命名规范，以其为准）。
2. 本 Kotlin skill（本文）。
3. Android Kotlin Style Guide（官方原文）。

当发生冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心检查清单（可执行）

### 源文件（Source files）

- **编码**：源文件必须是 UTF-8。
- **空白字符**：除换行外，只允许 ASCII 空格（0x20）。
  - 不使用 Tab 缩进。
  - 字符串/字符字面量中的其它空白字符应使用转义。
- **转义**：对有专用转义序列的字符优先使用专用转义（如 `\n`、`\t`），避免无意义的 `\uXXXX`。
- **非 ASCII 字符**：允许直接使用可读的 Unicode 字符（如 `∞`），但若不可打印字符必须用 escape 并酌情注释。

### 文件结构（Structure）

文件按以下顺序排列，并且各段之间**恰好 1 个空行**分隔：

1. 版权/许可证头（可选，多行注释）
2. 文件级注解（`@file:...`）
3. `package`
4. `import`
5. 顶层声明（types/functions/properties/typealias）

其他要点：

- **`package` / `import` 不换行**（不受列宽限制）。
- **import 单组列表 + ASCII 排序**；**禁止通配符 import**（`import foo.*`）。
- **文件聚焦单一主题**：不相关顶层声明应拆分到不同文件；公开声明应尽量少且聚合。
- **类成员顺序**：保持逻辑顺序，可解释；不要“按添加时间顺序”堆在文件末尾。

### 格式化（Formatting）

- **列宽**：代码列宽上限 **100**。
  - 例外：KDoc 里无法避免的长 URL；`package`/`import`；可复制的 shell 命令行。
- **缩进**：每进入一层 block/block-like construct，缩进 **+4 空格**；结束后回退。
- **一行一语句**：每条语句以换行结束；不使用分号。

#### 大括号（Braces）

- `if/else` 作为表达式时：仅当**整段表达式能放在一行**，才允许省略大括号。
- 其他情况下：`if/for/when` 分支、`do/while` 等，**即便只有一条语句也应使用大括号**。
- 非空 block 使用 K&R（Egyptian brackets）：
  - `{` 前不换行；`{` 后换行；`}` 前换行；
  - `}` 后是否换行取决于它是否结束语句/函数/命名类等（例如 `} else {` 不在 `}` 后换行）。
- 空 block 仍使用 K&R 风格（不要 `} catch (...) {}` 这种紧凑写法）。

#### 换行与断行（Line wrapping）

断行首要原则：**优先在更高语法层级断行**。同时：

- 在操作符/中缀函数名处断行：**断在操作符之后**。
- 在 `.` / `?.` 处断行：**断在符号之前**（让点号出现在新行行首）。
- 在成员引用 `::` 处断行：**断在符号之前**。
- 方法/构造函数名与后面的 `(` 绑定（不拆开）。
- `,` 与前一 token 绑定；lambda `->` 与参数列表绑定。
- 目标是**更清晰**，不是最少行数。

#### 函数（Functions）

- **签名超长**：每个参数单独一行，缩进 +4；`)` 与返回类型单独一行，且不额外缩进。
- **表达式函数**：仅含单一表达式可写成 `fun f() = expr`。

#### 属性（Properties）

- 初始化表达式超长：在 `=` 之后断行并缩进。
- 带 `get`/`set`：各自独占一行，缩进 +4，按函数规则格式化。
- 只读属性可用单行 `val x get() = ...`。
- **显式支持字段（Explicit backing fields，Kotlin 2.3.0+）**：当项目启用 `-Xexplicit-backing-fields` 且需要“内部实现类型与对外暴露类型不一致”的场景时，应**优先使用** `field =` 语法，替代传统的 backing property 双属性模式。
  - 语法：`val 属性: 对外类型 field = 实现类型实例`（例如 `val city: StateFlow<String> field = MutableStateFlow("")`）。
  - 好处：消除 `_xxx` / `xxx` 双属性、支持在属性作用域内智能转换、减少样板代码。
  - 典型场景：`MutableStateFlow` / `StateFlow`、`ArrayList` / `List`、内部可变集合对外只读暴露等。

### Kotlin/Java 混编空值安全（Nullability interop）

- **未标注 Java 返回值**：Kotlin 调用未标注 nullability 的 Java API 时，返回值视为不可信平台类型（`T!`），不得直接当作非空业务值继续传播。
- **边界处显式收敛**：平台类型必须在首次接收处完成以下之一，再进入后续业务逻辑：
  - 显式声明为可空类型：`val name: String? = javaApi.getName()`。
  - 立即失败并说明上下文：`val name = requireNotNull(javaApi.getName()) { "javaApi.getName() returned null" }`。
  - 提供默认值或降级策略：`val name = javaApi.getName() ?: ""`。
  - 转换为领域对象、`Result` 或 sealed state，避免平台类型跨层透传。
- **优先修源头**：自研 Java API 应补齐 `@Nullable` / `@NonNull`（或项目统一的 nullability 注解）；第三方或遗留 Java API 应优先用 Kotlin facade/wrapper 在边界层消化空值风险。
- **限制 `!!`**：禁止无说明地对 Java 平台类型使用 `!!`；确需断言非空时，优先使用带错误信息的 `requireNotNull` / `checkNotNull`。
- **避免可空性污染**：不要求所有后续链路都按 nullable 传播；推荐在 repository/adapter/gateway/SDK wrapper 等边界层收敛成明确的 `T` 或 `T?`。

### 空白（Whitespace）

#### 垂直空白（Vertical）

- 类成员之间通常 1 个空行。
  - 例外：连续属性之间可选空行，用于逻辑分组或与 backing property 关联。
- 语句之间按需插入空行以形成逻辑分段；多空行不鼓励但允许。

#### 水平空白（Horizontal）

除语言要求外，只在这些位置使用**单个** ASCII 空格（不强制行首/行尾）：

- 关键字（`if/for/catch/...`）与后面的 `(` 之间：`if (`。
- `} else` / `} catch`：`}` 与关键字之间。
- `{` 之前：`if (...) {`。
- 二元运算符两侧：`a + b`。
  - lambda `->` 两侧：`{ x -> ... }`。
  - 但 `::`、`.`、`..` 这类符号周围**不加空格**：`Any::toString`、`it.toString()`、`1..4`。
- `:` 的空格：
  - 类声明指定父类/接口：`class Foo : Runnable`
  - `where` 约束：`where T : Comparable<T>`
  - 其他 `:`（如 `val a: Int`）按 Kotlin 常规格式（`a: Int`，冒号后 1 空格）。
- `,` 与 `:` 之后：`listOf(1, 2)`、`a: Int`。
- `//` 行尾注释：`code // comment`（双斜杠两侧至少 1 空格）。

### 枚举（Enum classes）

- 无函数且常量无文档：可选单行：`enum class Answer { YES, NO }`。
- 常量分多行时：常量之间通常不需要空行；若某常量带 body，则可用空行分隔。

### 注解（Annotations）

- 类型/成员注解通常放在被注解构造的**上一行**。
- 无参注解可写成同一行多个（如 `@JvmField @Volatile`）。
- 单个无参注解也可与声明同一行（如 `@Volatile var x = ...`）。
- `@[...]` 仅用于有 use-site target 的场景，且合并 2 个以上无参注解。

### 命名（Naming）

#### 标识符字符集

- 仅使用 ASCII 字母与数字；少量场景可用下划线（见后文）。
- 避免 `mName`、`s_name`、`kName` 这类匈牙利前后缀风格（backing property 例外）。

#### 包名（Package）

- 全小写，单词直接拼接，不使用下划线：`com.example.deepspace`。

#### 类型名（Type）

- PascalCase，通常是名词/名词短语。
- 测试类：`<被测类名>Test` 或 `<被测类名>IntegrationTest`。

#### 函数名（Function）

- camelCase，通常是动词/动词短语。
- 测试函数名允许下划线分隔语义段：`pop_emptyStack`。
- `@Composable` 且返回 `Unit`：按“类型名”风格 PascalCase，当作名词命名（如 `NameTag(...)`）。
- 不使用带空格的反引号函数名（跨平台兼容性问题）。

#### 常量（Constant）

常量使用 **UPPER_SNAKE_CASE**。常量定义条件：

- `val` 且无自定义 `get`；
- 内容“深度不可变”，可观察状态不可变；函数无可检测副作用；
- 标量常量必须用 `const` 修饰。

常量只能定义在 `object` 或顶层；类内部满足条件也不要用常量命名（保持一致性）。

#### 非常量（Non-constant）

- 非常量使用 camelCase：实例属性、局部变量、参数等。
- 集合/数组按语义取名（通常名词/名词短语），不要为了“看起来像常量”而大写。

#### Backing property

- 若项目**未**启用显式支持字段，且需要 backing property：真实属性名一致，前缀加 `_`，如 `_table` / `table`。
- 若项目已启用显式支持字段：优先用 `field =` 显式支持字段语法，不再新增 `_` 前缀的双属性。

#### 泛型类型变量（Type variable）

- 方案 A：单个大写字母，可带 1 位数字（`T`、`E`、`T2`）。
- 方案 B：类名形式 + `T`（`RequestT`）。

#### 驼峰转换（Camel case）

对缩写/特殊构造（如 XML/IPv6/iOS）遵循“可预测”方案：

- 将短语转为 ASCII，去掉撇号；
- 按空格/标点切词（必要时把类似 `AdWords` 再拆分）；
- 全部先小写，再按 camelCase/PascalCase 规则首字母大写拼接。

示例（推荐）：`XmlHttpRequest`、`newCustomerId`、`supportsIpv6OnIos`。

### KDoc（Documentation）

- KDoc 基本格式：
  - 多行：每行 `*` 对齐；段落之间 1 个空行（只有 `*` 的那行）。
  - 单行：仅当整段含标记也能单行且没有 block tags（如 `@return`）时才用。
- block tags 顺序：`@constructor`、`@receiver`、`@param`、`@property`、`@return`、`@throws`、`@see`；不得空描述；换行续行缩进 4。
- Summary fragment：KDoc 开头必须有简短摘要片段。
- 覆写（override）：不强制重复 KDoc（除非需要补充额外语义）。


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 常见冲突与处置

- **规范冲突**：优先级始终为“项目约定 > 本文 > 官方参考”。
- **工具与人工结论冲突**：优先保证可读性与一致性，并在评审中记录取舍理由。
- **增量与全量冲突**：优先保证本次修改范围一致，避免在无关区域引入大规模格式噪音。

## 最小示例

```kotlin
if (isReady) {
    runTask()
}
```

## 工程化命令（本地/CI）

- 本地：`./gradlew ktlintFormat`（或项目等价任务）
- CI：`./gradlew ktlintCheck detekt test`

## 本 skill 的回答方式（输出模板）

当用户给出 Kotlin 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Kotlin + 涉及的构造（如 `if/when`、imports、KDoc、命名等）。
2. **结论（3–10 条检查点）**：逐条对应本规范中的条目。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：强调仅做风格层面的改动（除非用户明确要求重构语义）。

## 参考

- [Android Kotlin Style Guide（官方）](https://developer.android.com/kotlin/style-guide)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
- [Kotlin 2.3.0 What's new（显式支持字段）](https://kotlinlang.org/docs/whatsnew23.html#explicit-backing-fields)
- [Kotlin Coding Conventions（官方）](https://kotlinlang.org/docs/coding-conventions.html)
