<!--
UpdatedAt: 2026-03-18 15:41:42
LatestChange: 实现：基于 Google Java Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

## 目标

基于 Google Java Style Guide，为 Java 代码提供**可执行**的风格约束，用于：

- Code Review：快速识别格式、命名、文件结构、注释的违规点。
- 风格统一：在不改变业务语义的前提下，减少“风格差异”带来的维护成本。
- 输出建议：将规则落为“检查点 + 最小示例/原则”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目内已有强制 formatter/lint/命名规范，以其为准）。
2. 本 Java skill（本文）。
3. Google Java Style Guide（官方原文）。

当冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心检查清单（可执行）

### 源文件基础（Source file basics）

- **文件名**：若文件包含顶层类，则文件名为该顶层类名 + `.java`，且**通常一文件一个顶层类**。
- **编码**：源文件必须是 UTF-8。
- **空白字符**：除换行外，只允许 ASCII 空格（0x20）。
  - Tab 不用于缩进。
  - 其他空白字符仅能在字符串/字符/文本块中并以转义形式出现。
- **转义**：对有专用转义序列的字符优先使用专用转义（如 `\n`、`\t` 等）。
- **非 ASCII 字符**：可直接使用可读 Unicode 字符或等价转义，原则是**更易读**；但在字符串/注释外强烈不建议滥用 Unicode 转义。

### 文件结构（Source file structure）

普通 Java 源文件按以下顺序排列，且存在的各段之间**恰好 1 个空行**分隔：

1. License/Copyright（若有）
2. `package`
3. `import`
4. 顶层类声明（通常**恰好一个**）

`package-info.java`：同上但无类声明。`module-info.java`：无 `package`，以 `module` 声明替代类声明。

#### import 规则

- **禁止通配符 import**（含 static/non-static）。
- **禁止 import 换行**（不受 100 列宽限制）。
- **分组**：
  - static imports 作为一个组；
  - non-static imports 作为一个组；
  - 若两组都存在，用**一个空行**分隔；除此之外 import 区域不出现其他空行。
- **排序**：每个组内部按 ASCII sort 顺序排列（注意：是“导入名称”排序，不必追求“整行文本”排序）。
- **static import 不用于静态嵌套类**：静态嵌套类用普通 import。

#### 类内容顺序（Ordering of class contents）

- 只要求**逻辑顺序**且可解释；不要按“添加时间顺序”堆到末尾。
- **重载方法/构造函数不拆分**：同名方法应连续排列，中间不插入其他成员；构造函数亦同。

### 格式化（Formatting）

- **列宽**：100 字符（Unicode code point 计数）。
  - 例外：无法断行的长 URL/Javadoc，`package`/`import`，text blocks 内容，可复制的 shell 命令行，极少见的超长标识符等（以 `google-java-format` 的产出为参考）。
- **一行一语句**：每条语句后换行。

#### 大括号（Braces）

- `if/else/for/do/while`：**即便只有一条语句**也使用大括号（空体也一样）。
- 非空 block 采用 K&R（Egyptian brackets）：
  - `{` 前不换行（除非用于限制局部变量作用域的“额外 block”场景）；
  - `{` 后换行；`}` 前换行；
  - `}` 后仅在它结束语句/方法/构造/命名类时换行（例如 `} else {` 不在 `}` 后换行）。
- **空 block**：
  - 可写成 `{}` 或标准 K&R 空块；
  - **但**在 multi-block statement（`if/else`、`try/catch/finally`）中，禁止写成紧凑空块（例如 `} catch (...) {}` 是不允许的）。

#### 缩进（Indentation）

- block 缩进为 **+2 空格**（进入 block +2，退出回退）。
- 断行后的 continuation line 至少 **+4 空格**（相对原始行）。

#### 断行（Line-wrapping）

首要原则：**优先在更高语法层级断行**。并遵循：

- 在**非赋值**运算符断行：通常在符号**之前**断行（例如点号 `.`、方法引用 `::` 等也按此处理）。
- 在**赋值**运算符断行：通常在符号**之后**断行（但两种方式都可接受）。
- 方法/构造/record 名与后续 `(` 绑定。
- `,` 与前一 token 绑定。
- lambda/switch rule 的 `->` 附近一般不换行；允许在 `->` 后紧接的内容是“单一无大括号表达式”时在 `->` 后断行。
- 目标是**更清晰**，不是最少行数；必要时优先“提取局部变量/方法”代替复杂断行。

#### 空白（Whitespace）

垂直空白：

- 类的连续成员/initializer 之间通常 1 个空行。
  - 例外：连续字段之间空行可选，用于逻辑分组。
- 其他位置可按可读性插入空行；多空行允许但不鼓励。

水平空白（除字面量/注释/Javadoc 外）：

- 关键字与后续 `(` 之间：`if (`。
- `}` 与 `else/catch` 等关键字之间：`} else`。
- `{` 之前（少数例外见原文）。
- 二元/三元运算符两侧（含 lambda/switch rule 的 `->` 等“operator-like”符号），但 `::` 与 `.` 周围不加空格。
- `,:;` 之后；类型与变量名之间（如 `List<String> list`）。
- 数组初始化花括号内侧可选空格（两种都允许）。
- 不要求也不强制维护“水平对齐（alignment）”；避免为了对齐引入无关变更。

### 命名（Naming）

#### 通用规则

- 标识符只使用 ASCII 字母与数字，少数场景可用下划线（例如常量名）。
- 不使用特殊前后缀（如 `mName`、`s_name`、`kName`）。

#### 具体类型

- 包名/模块名：全小写字母与数字，单词拼接，不用下划线。
- 类名：UpperCamelCase（名词/名词短语）；测试类通常以 `Test` 结尾（如 `HashIntegrationTest`）。
- 方法名：lowerCamelCase（动词/动词短语）；JUnit 测试方法允许用下划线分段（如 `transferMoney_deductsFromSource`）。
- 常量名：`UPPER_SNAKE_CASE`（static final 且深度不可变、无副作用）。
  - 注意：局部变量即便 `final` 也**不视为常量**，不要用常量命名。
- 非常量字段/参数/局部变量：lowerCamelCase。
- 泛型类型变量：`T`/`E`/`T2` 或 `RequestT` 这类“类名 + T”。

#### 驼峰转换（Camel case）

对缩写/特殊构造（如 XML/IPv6/iOS）遵循确定性方案：先切词、统一小写、再按 Upper/LowerCamelCase 合并；避免 `newCustomerID` 这类不一致写法。

### 注释（Comments）与 TODO

- 块注释与行注释均可；多行块注释后续行以 `*` 对齐。
- 不用“星号画框”。
- `TODO` 规范：`TODO:` + 上下文链接（最好是 bug/issue） + ` - ` + 说明。
  - 避免指向个人/团队作为上下文。
  - 若是“未来某时做”，给出明确日期或明确事件触发条件。

### 编程实践（Programming practices）

- `@Override`：只要合法就应使用（例外：父方法被 `@Deprecated` 时可省略）。
- 捕获异常不应忽略：若确实什么都不做，应写注释说明理由。
- static 成员：需要限定时用类名限定，不用实例/表达式限定。
- 不覆盖 `Object.finalize`（finalization 机制计划移除）。

### Javadoc（最小要求）

- 可见（public/protected）API 按需编写 Javadoc；简单明显成员可省略，但不能用“明显”为由省略必要语义。
- override 方法不强制重复 Javadoc（除非需要补充差异语义）。
- Javadoc 开头使用 summary fragment；`@param/@return/@throws/@deprecated` 等按规范顺序与缩进。

## 本 skill 的回答方式（输出模板）

当用户给出 Java 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Java + 涉及点（imports/文件结构/断行/命名/Javadoc 等）。
2. **结论（3–10 条检查点）**：逐条对应本规范条目。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：强调仅做风格层面的改动（除非用户明确要求语义重构）。

## 参考

- Google Java Style Guide（官方）：https://google.github.io/styleguide/javaguide.html
- Google Style Guides（索引）：https://google.github.io/styleguide/

