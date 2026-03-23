<!--
UpdatedAt: 2026-03-23 14:46:39
LatestChange: 实现：基于 Google Common Lisp Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

# Common Lisp Code Style Skill

## 目标

基于 Google Common Lisp Style Guide，为 Common Lisp 代码提供可执行的风格约束，用于：

- Code Review：快速识别命名、缩进、包组织、宏使用中的风格偏差。
- 风格统一：在不改变业务语义前提下提升代码一致性与可读性。
- 输出建议：将规则落为“检查点 + 最小示例”，避免泛泛而谈。

## 规范来源与优先级

1. 项目/团队约定（若项目已有统一 formatter 或历史强约束，以其为准）。
2. 本 Common Lisp skill（本文）。
3. Google Common Lisp Style Guide（官方原文）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 命名（Naming）

- **统一小写 + 连字符**：标识符使用小写并以单个 `-` 分词（如 `flight-search-engine`）。
- **避免不必要缩写**：优先完整单词（如 `request-count` 优于 `req-cnt`）。
- **谓词后缀**：布尔谓词函数使用 `-p` 后缀（如 `valid-ticket-p`）。
- **特殊变量**：动态绑定变量使用 `*name*` 形式（如 `*db-connection*`）。
- **常量命名**：常量使用 `+name+` 形式（如 `+max-retry+`）。

### 包与符号（Packages / symbols）

- **分层包命名**：包名使用层次结构并保持可读（如 `myapp.parser.core`）。
- **不要在符号名重复包语义**：既然已在 package 中，不再给函数加冗余前缀。
- **显式导出边界**：公共 API 通过 `defpackage` 的 `:export` 明确声明，避免隐式泄漏。

### 格式化（Formatting）

- **缩进**：常规缩进使用 2 空格；嵌套 form 保持对齐与可读。
- **列宽**：单行尽量不超过 100 列；超长表达式优先拆行而非压缩命名。
- **一行一层意图**：复杂表达式拆成多行，优先展现结构而不是最少行数。
- **空白控制**：避免行尾空白与无意义空行；逻辑段之间保留单个空行。

### 控制流与表达式（Control flow / expressions）

- **优先清晰分支**：`if/cond/case` 保持分支结构清晰，避免“挤在一行”。
- **减少深层嵌套**：可通过提取局部函数（`labels`）或辅助函数降低嵌套深度。
- **避免隐式副作用**：函数命名与实现要一致表达是否修改状态。

### 宏与抽象（Macros / abstractions）

- **宏只做必要抽象**：宏用于语法抽象，不用于隐藏普通函数即可表达的逻辑。
- **宏展开可读**：宏参数命名清晰、展开后结构可预测，便于调试与审查。
- **优先函数，其次宏**：能用函数解决的问题，不优先引入宏复杂度。

### 注释与文档（Comments / docs）

- **注释解释“为什么”**：不重复代码字面含义，重点写约束、边界、取舍。
- **docstring 保持简洁可执行**：说明输入、输出、副作用与关键前置条件。
- **TODO 可追踪**：`TODO:` 后附上下文（issue/日期/触发条件），避免“永远待办”。

## 最小示例

### 命名与特殊变量

```lisp
;; Yes
(defparameter *request-timeout* 30)
(defconstant +max-retry+ 5)
(defun order-valid-p (order) ...)

;; No
(defparameter requestTimeout 30)
(defconstant MAXRETRY 5)
(defun isOrderValid (order) ...)
```

### 包与导出边界

```lisp
;; Yes
(defpackage :myapp.parser
  (:use :cl)
  (:export :parse-ticket))

(in-package :myapp.parser)

(defun parse-ticket (input) ...)
```

### 缩进与结构

```lisp
;; Yes
(defun score-flight (flight user)
  (let ((price (flight-price flight))
        (stops (flight-stops flight)))
    (if (preferred-airline-p user flight)
        (- price (* 10 stops))
        (+ price (* 20 stops)))))
```

## 本 skill 的回答方式（输出模板）

当用户给出 Common Lisp 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Common Lisp + 涉及点（命名、包、缩进、控制流、宏、注释）。
2. **结论（3-10 条检查点）**：优先指出高风险项（命名不一致、包边界混乱、宏滥用、不可读嵌套）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：强调默认只做风格层改动，除非用户明确要求语义重构。

## 参考

- [Google Common Lisp Style Guide（官方）](https://google.github.io/styleguide/lispguide.xml)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
