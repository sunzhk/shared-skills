<!--
UpdatedAt: 2026-03-18 15:51:51
LatestChange: 实现：基于 Google TypeScript Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

## 目标

基于 Google TypeScript Style Guide，为 TypeScript 代码提供**可执行**的风格约束，用于：

- Code Review：快速识别模块边界、imports/exports、类型系统用法、注释与危险特性方面的问题。
- 风格统一：在不改变业务语义的前提下统一书写习惯，降低维护成本与迁移成本。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目已有 ESLint/Prettier/tsconfig 约束与统一规范，以其为准）。
2. 本 TypeScript skill（本文）。
3. Google TypeScript Style Guide（官方原文）。

当冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心检查清单（可执行）

### 源文件基础（Source file basics）

- **编码**：UTF-8。
- **空白字符**：除换行外只允许 ASCII 空格（0x20）；字符串字面量中的其它空白字符需转义。
- **转义**：使用标准转义序列（如 `\n`、`\t`），禁止 legacy 八进制转义。
- **非 ASCII**：可打印字符优先直接使用；不可打印字符用 escape 并配合说明性注释。

### 文件结构（Source file structure）

按以下顺序排列（存在则出现），章节间**恰好 1 个空行**分隔：

1. 版权信息（若有，使用 JSDoc 置顶）
2. `@fileoverview` JSDoc（若有，wrapped 行不缩进）
3. imports（若有）
4. 实现代码

### Imports / Exports

- 只使用 **ES module** 语法（`import ... from` / `export ...`）。
- **禁止**：
  - `namespace Foo { ... }`（除非为了对接第三方代码且无替代方案）
  - `/// <reference .../>`
  - `import x = require('...')`（以及其他 require 风格）
- **exports**：
  - 统一使用 **named exports**；避免 default export（仅在不得不对接外部代码时使用）。
  - 尽量最小化导出 API 面积。
  - 禁止 `export let`（可变导出）。如需对外可变状态，改为导出 getter 或封装函数。
- **container classes**：不要为了命名空间创建“全 static 的容器类”；用文件级导出常量/函数替代。

#### import type / export type

- 仅作为类型使用时可用 `import type {...}`；跨文件转译/isolatedModules 场景下也能提升稳定性。
- 仅转出类型时用 `export type {...}`。

### 变量与声明（Local variable declarations）

- 只用 `const` / `let`，默认 `const`；禁止 `var`。
- 一次声明一个变量：禁止 `let a = 1, b = 2;`。
- 禁止“先用后声明”。

### 字面量与集合（Array/Object literals）

- 禁止 `Array()` 构造器（含 `new` 与不带 `new`）；用 `[]` 或合适的构造/`from`。
- 数组不定义非数字属性（除 `length`）；需要映射结构用 `Map`/`Record`。
- object 禁止 `Object` 构造器；用 `{}`。
- `for (... in ...)` 慎用：必须过滤 `hasOwnProperty` 或改用 `Object.keys/values/entries` + `for...of`。
- spread：
  - 数组只 spread iterable；对象只 spread object；
  - 不 spread `null/undefined` 与原始值；
  - 避免 spread 非 `Object` 原型（类实例/函数等），行为不直观。
- 解构：
  - 参数解构保持简单（单层、shorthand、默认值写在左侧）；optional 解构默认 `{}`/`[]`。
  - 需要语义名时优先对象解构而非数组解构。

### 类（Classes）

- 类**声明**不以分号结束；类**表达式语句**需要分号结束。
- 方法之间 1 个空行（保持可读性）。
- 构造调用必须带 `()`：`new Foo()`。
- 不使用 `#private` 私有字段；使用 TS 的 `private/protected`。
- 优先使用 `readonly` 标记“构造后不再重赋值”的属性。
- 推荐参数属性（parameter properties）简化样板（并用 `@param` JSDoc 描述）。
- 尽量在字段声明处初始化；避免构造结束后再新增/删除字段（影响 VM shape 优化）。
- 属性在类外被模板/反射等使用时不要标 `private`（例如 Angular 模板可用 `protected`）。
- accessor：
  - 允许 getter/setter，但 getter 必须纯函数（无副作用，不改变可观察状态）。
  - 不用 `Object.defineProperty` 定义 accessor（影响重命名/工具链）。

### 函数（Functions）

- 顶层命名函数优先使用 `function` 声明。
- 禁止一般的 function expression（优先 arrow function）；仅在必须动态重绑定 `this` 或 generator 场景例外。
- callback 参数传递优先用箭头函数显式转发，避免签名不匹配（典型坑：`['11','5','10'].map(parseInt)`）。
- arrow concise body 仅在返回值会被使用时使用；否则用 block body 或 `void` 显式丢弃返回值。
- rest 参数替代 `arguments`；禁止命名局部变量/参数为 `arguments`。
- generator：`function* foo()` 与 `yield* iter`（`*` 紧贴关键字）。
- 函数体开头/结尾不放空行；内部空行用于稀疏分组即可。

### this（上下文）

- 只在构造器/实例方法、显式声明 `this` 类型的函数、或允许使用 `this` 的外层作用域内的箭头函数中使用 `this`。
- 不用 `this` 指代 global/`eval`/事件目标等隐式上下文。

### 控制流（Control structures）

- 控制结构（`if/else/for/do/while/...`）一律使用大括号；唯一例外：单行 `if` 可省略 block。
- 避免在控制语句里做赋值；若必须，使用双括号强调意图：`while ((x = f())) { ... }`。
- switch：
  - 必须有 `default` 且在最后；
  - 非空 case 不允许 fall-through（由编译器/约定约束）；空 case 可 fall-through。
- 相等判断：使用 `===`/`!==`；仅对 `null` 字面量允许 `== null`/`!= null` 以覆盖 `undefined`。

### 异常（Exception handling）

- 只 throw `Error`（或其子类）；构造必须 `new Error(...)`。
- catch 块假定捕获的是 `Error`，用 type guard/assert 辅助收窄；除非明确知道某 API 会 throw 非 Error，并在代码中注释说明来源。
- 空 catch 极少正确；若确实需要，必须注释说明理由。
- try 块保持聚焦：尽量只包住可能 throw 的语句，便于读者定位风险点（循环性能例外）。

### 类型断言与非空断言（Type assertions / non-null assertions）

- `as` 与 `!` 都是不安全的“只让编译器闭嘴”的手段，应谨慎使用。
- 优先写运行时检查（`instanceof`、`if (x)` 等）来匹配断言的语义。
- 断言语法必须用 `as`（禁止尖括号断言）。
- 双重断言仅在确有充分理由时使用，并通过 `unknown` 作为中间类型：`x as unknown as Foo`（不要用 `any`）。
- object literal 指定类型：优先用类型标注（`const v: Foo = {...}` 或 `function f(): Foo { return {...}; }`），避免 `as Foo` 遮蔽字段重命名错误。

### 类型系统常见约束（Type system）

- **类型推断**：对明显的字面量/`new` 表达式等不要写冗余类型；对复杂表达式可加类型提升可读性。
- **可空值**：不要在 type alias 中携带 `|null`/`|undefined`；在使用点再加，且尽量就近处理缺省值。
- **可选优先**：接口/参数优先用 `?`，而不是 `|undefined`。
- **结构类型**：对象结构优先用 `interface`，而不是对象字面量 `type` alias（同时提升 IDE 支持与可维护性）。
- **数组类型**：简单类型用 `T[]`/`readonly T[]`；复杂类型用 `Array<T>`/`ReadonlyArray<T>`。
- **Map/Record**：字典类型优先考虑 `Map`；`Record<Keys, T>` 用于“键集合静态已知”的场景。
- **any**：尽量避免；优先更具体类型或 `unknown`。必要使用时在局部压制并写清原因（常见于测试 mock）。
- **避免 `{}`**：多数场景用 `unknown` / `Record<string, T>` / `object` 代替。

### 注释与文档（Comments and documentation）

- 区分两类注释：
  - `/** JSDoc */`：给“使用者”看的文档（尤其是模块顶层导出）。
  - `//`：实现注释。
- 多行实现注释必须使用多行 `//`，不要用 `/* ... */`。
- TS 中 JSDoc 不要重复写类型（不写 `@param {type}`/`@return {type}` 这类冗余），用 TS 类型签名表达；`@param` 仅在需要补充语义时使用。
- 文档应写在 decorator 之前，禁止夹在 decorator 与声明之间。
- 参数名注释（`/* name= */`）仅在调用点难以读懂时使用；优先考虑把参数改为对象并解构以提升可读性。

### 工具链与禁止项（Toolchain requirements / Disallowed）

- 不依赖 ASI：所有语句显式分号。
- 禁止 `const enum`，用普通 `enum`。
- 禁止 `debugger` 进入生产代码。
- 禁止 `eval` / `Function(...string)`（除代码加载器等极少数例外）。
- 禁止 `with`。
- 禁止修改 builtin objects（含 prototype）。
- 不使用 `@ts-ignore` / `@ts-expect-error` / `@ts-nocheck`（测试中极少数场景除外，但仍不推荐）。

## 本 skill 的回答方式（输出模板）

当用户给出 TS 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：TypeScript + 涉及点（模块化/类型断言/any/控制流/注释等）。
2. **结论（3–10 条检查点）**：逐条对应本规范条目，优先指出“高风险/易踩坑”的点（`any`、断言、`export let`、namespace、`@ts-ignore` 等）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：默认只做风格层面的调整（除非用户明确要求语义重构）。

## 参考

- Google TypeScript Style Guide（官方）：https://google.github.io/styleguide/tsguide.html
- Google Style Guides（索引）：https://google.github.io/styleguide/

