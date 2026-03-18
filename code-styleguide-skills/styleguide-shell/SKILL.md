<!--
UpdatedAt: 2026-03-18 15:59:10
LatestChange: 实现：基于 Google Shell Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

## 目标

基于 Google Shell Style Guide，为 Shell（以 **bash** 为主）的脚本提供**可执行**的风格约束，用于：

- Code Review：快速识别可读性、可移植性与常见坑（引用/数组/管道子 shell 等）。
- 风格统一：在不改变脚本语义的前提下减少歧义与潜在 bug。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（仓库内已有脚本规范、lint 或 CI 约束时优先）。
2. 本 Shell skill（本文）。
3. Google Shell Style Guide（官方原文）。

当冲突或无法确定时，默认选择：**更安全、更易读、更接近现有脚本库风格**的一侧，并说明理由。

## 适用范围与边界

- 本规范主要针对 **bash** 脚本。
- Shell 只适合小工具/简单包装脚本；脚本超过 ~100 行或控制流复杂时，优先考虑更结构化的语言（否则维护成本会指数上升）。

## 核心检查清单（可执行）

### Shell 选择与 shebang

- 可执行脚本必须使用 bash：
  - 以 `#!/bin/bash` 开头（flags 最少化）。
  - 使用 `set` 来设置 shell options，而不是在 shebang 上堆 flags（保证 `bash script.sh` 运行行为一致）。
- library 脚本必须以 `.sh` 结尾且不应可执行；可执行脚本可用 `.sh` 或无扩展名（取决于部署方式）。
- 禁止 SUID/SGID（安全风险）。

### 输出：STDOUT vs STDERR

- 错误信息输出到 **STDERR**。
- 推荐封装 `err()` 统一打印带时间戳的错误日志（便于排障）。

### 注释（Comments）

- 文件头必须有“文件用途概述”注释（版权/作者可选）。
- 不明显或较长的函数必须写函数头注释（library 里所有函数都必须写）。
  - 注释包含：用途、Globals、Arguments、Outputs（stdout/stderr）、Returns。
- TODO 格式：`TODO(name): ...`（带最有上下文的人标识，可附 bug）。
- tricky/非直观逻辑必须写实现注释，但不要为每行废话式注释。

### 格式化（Formatting）

- 缩进：**2 空格**，不使用 Tab（唯一例外：`<<-` 的 here-doc body 可用 tab 缩进）。
- 行宽：**80**。
  - 例外：不可拆的长路径/URL/长单词可单独成行；否则优先用 here-doc 或嵌入换行。
- pipeline：若不能一行放下，则拆为每段一行，`|` 放到换行处，并用 `\` 做续行标记：

  - `command1 \`
  - `  | command2 \`
  - `  | command3`
- 控制流：`if/for/while/until/select` 的 `; then` / `; do` 与语句同一行；`else` 独占一行；`fi/done` 与开头对齐。
- `case`：
  - 分支缩进 2 空格；
  - 一行分支：`)` 后与 `;;` 前各 1 空格；
  - 多行分支：pattern、actions、`;;` 分行；避免 `;&`/`;;&`。

### 变量展开与引用（Variable expansion & quoting）

核心原则（按优先级）：

1. 保持与文件既有风格一致。
2. **总是引用**：凡是包含变量、命令替换、空格或 shell 元字符的字符串，默认都要加双引号。
3. 一般变量优先 `"${var}"`（而不是 `"$var"`）以减少歧义与拼接错误。

具体规则：

- 位置参数与特殊参数：
  - 单字符特殊参数（如 `$1`、`$?`、`$$`、`$#`、`$!`）一般不强制加 `{}`，但在 `10+` 位置参数时必须写 `${10}`。
- **`"${var}"` 不是引用的替代品**：花括号不是 quoting，仍需要双引号。
- `[[ ... ]]` 中：
  - 优先用 `[[ ... ]]`，避免 `[ ... ]`/`test`（减少 pathname expansion/word splitting 的坑）。
  - 正则匹配 `=~` 的 RHS 不要加引号（否则变成字面匹配）。
- 传参：
  - 几乎总是用 `"$@"` 传递参数；
  - `$*` 只用于拼接日志字符串等极少数场景（理解其“合成单参数”的语义）。
- 命令替换：用 `$(...)`，不要用反引号。

### 数组（Arrays）

- 用数组保存“参数列表/元素列表”，避免把多个参数塞进一个 string 再去 `eval`。
- 扩展数组时使用 quoted expansion：`"${array[@]}"`。
- 避免 `files=($(ls ...))` 这类写法（受环境影响 + 空白分割 + 特殊字符问题）。

### 管道与子 shell（Pipes, subshell）

- 警惕 `cmd | while read ...`：pipe 会创建 subshell，循环内修改变量不会回到父 shell。
- 优先使用 process substitution：
  - `while read -r line; do ...; done < <(cmd)`
  - 或 bash4+ 用 `readarray -t` + `for` 遍历。

### 字符串测试与数值比较（Tests / arithmetic）

- 字符串空/非空：优先 `-z`/`-n`，避免 `if [[ "${x}" ]]; then` 这类歧义写法。
- 相等比较：在 `[[ ... ]]` 中用 `==`（避免与赋值混淆）。
- 数值比较：
  - 优先 `(( ... ))` 或 `$(( ... ))`；
  - 不要在 `[[ ... ]]` 里用 `<`/`>` 做数值比较（那是字典序）。
- 算术：禁止 `expr`、`let`、`$[ ... ]`。
- 警惕 `set -e` + `(( i++ ))` 的退出陷阱（表达式结果为 0 会触发退出）；必要时改写或显式处理返回值。

### 避免危险特性（Features and bugs）

- 避免 `eval`（难以审计且会“二次解析”输入）；如果你正在考虑 `eval`，优先换数组/更结构化语言。
- 避免 alias（脚本里用函数替代）。
- wildcard 展开：
  - 用 `./*` 而不是 `*`，避免以 `-` 开头的文件名被当成参数。

### 命名约定（Naming）

- 函数名/变量名：全小写 + 下划线分词；库函数可用 `pkg::func`。
- 常量与导出环境变量：全大写 + 下划线；在文件顶部声明（尽量 `readonly`/`export`）。
- 函数内变量尽量用 `local`，避免污染全局。
  - 若赋值来自命令替换：`local var; var="$(cmd)"`（不要 `local var="$(cmd)"`，否则 `$?` 是 `local` 的返回码）。
- 函数集中放在常量之后；脚本较长时使用 `main` 作为入口，文件末尾 `main "$@"`。

### 调用命令与返回值（Calling commands）

- **总是检查返回值**；失败时给出可诊断的错误信息并退出/返回非 0。
- pipeline 返回值：
  - 只关心整体成功可用 `PIPESTATUS` 简单检查；
  - 需要区分哪段失败时，立刻复制 `PIPESTATUS` 到数组再判断（注意任何后续命令都会覆盖它）。
- 能用 builtin 就别 fork 外部程序（更快更稳），例如用参数展开替代 `sed` 等。

### ShellCheck

- 推荐对所有脚本使用 ShellCheck（尤其是引用、未初始化变量、管道返回值等常见问题）。

## 本 skill 的回答方式（输出模板）

当用户给出 shell 脚本/片段/问题描述时，按以下结构输出：

1. **适用范围判定**：bash / shell + 涉及点（引用/数组/管道/控制流/命名等）。
2. **结论（3–10 条检查点）**：逐条对应本规范，优先指出高风险点（未引用变量、`eval`、pipe-to-while、`*` 展开等）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：默认只做风格与安全性改进，不改变脚本行为（除非用户明确要求）。

## 参考

- Google Shell Style Guide（官方）：https://google.github.io/styleguide/shellguide.html
- Google Style Guides（索引）：https://google.github.io/styleguide/

