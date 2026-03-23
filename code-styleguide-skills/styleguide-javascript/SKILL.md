<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

## 重要说明（指南状态）

Google JavaScript Style Guide 已**停止更新**，官方建议迁移到 TypeScript 并遵循 TypeScript 指南。在需要继续维护 JS 代码时，仍可使用本规范对齐“可执行的硬规则”，并尽量避免引入不利于迁移的写法。

## 目标

基于 Google JavaScript Style Guide，为 JavaScript（现代 ES module 优先）代码提供**可执行**的风格约束，用于：

- Code Review：快速识别格式、模块化、命名、JSDoc、危险语言特性的违规点。
- 风格统一：在不改变业务语义的前提下统一书写习惯，降低维护成本。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目已统一使用 TypeScript/Prettier/ESLint 等，以其为准）。
2. 本 JavaScript skill（本文）。
3. Google JavaScript Style Guide（官方原文）。

当冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心检查清单（可执行）

### 源文件基础（Source file basics）

- **文件名**：全小写，可含 `_` 或 `-`，扩展名 `.js`。
- **编码**：UTF-8。
- **空白字符**：除换行外只允许 ASCII 空格（0x20），不使用 Tab 缩进。
- **转义**：对特殊字符优先使用标准转义（如 `\n`、`\t`），禁止 legacy 八进制转义。
- **非 ASCII 字符**：可直接使用 Unicode 字符或转义，原则是**更易读**。

### 模块与文件结构（Source file structure）

- 新文件应为 **ES module**（`import`/`export`）或 `goog.module`（Closure 体系）；优先 ES module。
- 章节顺序（存在则按序出现），各章之间**恰好 1 个空行**：
  1. License/Copyright（若有）
  2. `@fileoverview` JSDoc（若有）
  3. `goog.module`（若是 `goog.module` 文件）
  4. ES `import`（若是 ES module）
  5. `goog.require`/`goog.requireType`
  6. 实现代码

ES module 要点：

- `import` 不换行（可超 80 列）。
- 避免重复 import 同一文件。
- 禁止 default export（统一使用 named export）。
- 避免模块循环依赖（import/export 都可能造成循环）。

### 格式化（Formatting）

- **列宽**：80 字符。
  - 例外：`goog.module`/`goog.require*`/ES `import`/`export from`；无法断行且需要可发现性的长 URL；可复制 shell 命令；需要整体搜索/复制的长字符串等。
- **缩进**：block 缩进 **+2 空格**；断行 continuation line 至少 **+4 空格**（除非属于 block 缩进规则）。
- **一行一语句**：每条语句后换行。
- **分号**：必须写分号；禁止依赖 ASI（automatic semicolon insertion）。

#### 大括号（Braces）

- 所有控制结构都必须使用大括号（`if/else/for/do/while/...`），即便只有一条语句。
- 唯一例外：无 `else` 的简单 `if` 且整句能一行写完、提升可读性时，可省略大括号：`if (cond) foo();`
- 非空 block 使用 K&R（Egyptian brackets）：`{` 不换行，块体换行缩进，`}` 前换行；`else/catch/while` 等跟在 `}` 同行。
- 空 block 可用 `{}`，但 multi-block（`if/else`、`try/catch/finally`）中不允许紧凑空块。

#### 断行（Line-wrapping）

首要原则：**优先在更高语法层级断行**。并遵循：

- 在运算符处断行：通常在符号**之后**断行（注意：与 Java 不同）。
- 方法/构造名与后续 `(` 绑定；`,` 与前一 token 绑定。
- 不在 `return` 与返回值之间插入换行（会改变语义）。
- 必要时优先“提取局部变量/方法”代替复杂断行。

#### 空白（Whitespace）

- 禁止行尾空白。
- 水平空格只在规范位置出现（关键字与 `(`，二元/三元运算符两侧，`,`/`;` 之后，object literal 的 `:` 之后，行尾注释 `//` 两侧等）。
- “水平对齐（alignment）”允许但总体不鼓励；不要为了对齐制造无关 diff。

### 语言特性（Language features）

- **局部变量**：只用 `const`/`let`；默认 `const`；禁止 `var`。
- **每次声明一个变量**：禁止 `let a = 1, b = 2;`。
- **就近声明并尽快初始化**：不要把局部变量习惯性堆在块开头。
- **数组/对象字面量**：
  - 若最后元素/属性与闭合括号/花括号之间换行，必须带 trailing comma。
  - 禁止 variadic `Array` 构造器（`new Array(x1, ...)`）；用字面量。
  - 数组不使用非数字属性（除 `length`）；需要键值结构用 `Map`/`Object`。
  - object literal 不混用 quoted/unquoted keys（struct vs dict 风格要选一种）。
- **类**：
  - 构造函数中定义所有字段；避免构造完成后再增删字段（影响 VM 优化）。
  - 不直接操作 `prototype`（框架代码例外）。
  - 避免 getter/setter（必要场景例外；getter 不得改变可观察状态）。
  - `toString` 可覆盖但必须成功且无副作用。
- **函数**：
  - 嵌套回调优先箭头函数；但要明确 `this` 语义。
  - rest 参数替代 `arguments`；rest 必须是最后一个参数。
  - 可用默认参数；复杂可选参数优先对象解构。
- **相等判断**：默认使用 `===`/`!==`；仅在“同时捕获 null 与 undefined”的场景可用 `== null`。

### 异常与控制流（Exceptions / control structures）

- 抛异常必须是 `Error` 或其子类，禁止抛字符串/任意对象；构造 `Error` 必须用 `new`。
- 空 catch 极少正确；若确实需要，必须写注释解释原因。
- `switch`：
  - 需要 `default`，且必须放最后（即便为空）。
  - fall-through 必须用注释标明（如 `// fall through`）。

### 注释与 JSDoc（Comments / JSDoc）

- 实现注释不使用 JSDoc（`/** ... */`）格式；JSDoc 专用于类型与 API 文档。
- 文件可用 `@fileoverview` 说明用途；wrapped 行不缩进。
- JSDoc 必须结构良好（工具依赖）；常见要求：
  - `@param` 必须独占一行，不可合并；
  - 简单 tag（`@private/@const/@final/@export` 等）可同一行组合，但保持一致；
  - block tag 换行续行缩进 4 空格；
  - 引用代码符号优先用 Markdown 反引号。

### 安全与禁用特性（Disallowed features）

- 禁止 `with`。
- 禁止动态求值：`eval`、`Function(...string)`（代码加载器等极少数例外场景另行说明）。
- 禁止修改内建对象（含 prototype）。
- 禁止 `new Foo;` 省略括号，必须 `new Foo()`。
- 禁止 `new Boolean/Number/String/Symbol` 包装对象（可作为函数用于 coercion）。


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 常见冲突与处置

- **规范冲突**：优先级始终为“项目约定 > 本文 > 官方参考”。
- **工具与人工结论冲突**：优先保证可读性与一致性，并在评审中记录取舍理由。
- **增量与全量冲突**：优先保证本次修改范围一致，避免在无关区域引入大规模格式噪音。

## 最小示例

```javascript
if (isReady) {
  runTask();
}
```

## 工程化命令（本地/CI）

- 本地：`eslint . --fix && prettier -w .`
- CI：`eslint . && prettier -c .`

## 本 skill 的回答方式（输出模板）

当用户给出 JS 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：JavaScript + 涉及点（模块化/格式/命名/JSDoc/危险特性等）。
2. **结论（3–10 条检查点）**：逐条对应本规范条目，优先指出“高风险/会踩坑”的规则（ASI、eval、prototype、循环依赖等）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **迁移提示（可选）**：若与 TS 迁移相关，指出“更利于迁移”的写法（例如避免 default export、避免动态特性）。

## 参考

- [Google JavaScript Style Guide（官方）](https://google.github.io/styleguide/jsguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
- [TypeScript Style Guide（迁移参考）](https://google.github.io/styleguide/tsguide.html)
