---
name: styleguide-vimscript
description: Use when writing or reviewing vimscript code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# Vimscript Code Style Skill

## 目标

基于 Google Vimscript Style Guide，为 Vimscript 代码提供可执行的风格约束，用于：

- Code Review：快速识别可移植性、命名作用域、副作用命令与插件结构问题。
- 风格统一：在不改变业务语义前提下减少脚本脆弱性与环境相关故障。
- 输出建议：将规范落到“检查点 + 最小示例”，避免空泛建议。

## 规范来源与优先级

1. 项目/团队既有约定（插件目录约束、兼容版本策略、lint/CI 规则）。
2. 本 Vimscript skill（本文）。
3. Google Vimscript Style Guide（vimscriptguide.xml）。

当冲突或无法确定时，默认选择：更可移植、更少副作用、更接近现有插件结构的一侧，并说明理由。

## 核心检查清单（可执行）

### 可移植性与确定性（Portability / determinism）

- **字符串优先单引号**：默认使用单引号，只有需要转义序列或嵌入单引号时使用双引号。
- **匹配显式大小写策略**：字符串匹配使用 `=~#` 或 `=~?`，避免依赖用户 `ignorecase`/`smartcase` 设置。
- **正则显式 magic/case**：正则前缀显式指定（如 `\m\C`），避免受用户 `magic`/`ignorecase` 影响。
- **避免 fragile 命令**：脚本中避免依赖用户设置的命令行为，优先更稳定函数接口。

### 命令副作用与异常处理（Side effects / exceptions）

- **避免 `:substitute` 脚本化依赖**：`:s` 可能移动光标并产生噪声错误，优先 `search()` 等函数。
- **使用 `normal!` 而非 `normal`**：避免用户映射导致不可预测行为。
- **异常匹配错误码**：`catch` 时按错误码匹配，不按文本匹配（文本可能受 locale 影响）。
- **用户提示克制**：仅在耗时流程启动或发生错误时提示，避免“吵闹脚本”。

### 命名、作用域与类型安全（Naming / scope / type safety）

- **命名风格一致**：函数 `FunctionNamesLikeThis`、命令 `CommandNamesLikeThis`、变量/augroup 使用 `snake_case`。
- **变量必须带作用域前缀**：至少保证 `g:`、`s:`、`a:` 显式；新代码推荐 `l:`、`v:` 也显式。
- **避免全局函数污染**：优先 autoload 函数与脚本局部函数，不创建无命名空间全局函数。
- **严格类型比较**：字符串比较优先 `is#`，必要时显式 `type()` 校验，避免隐式类型陷阱。
- **类型可能变化时清理变量**：在循环等场景需要变更变量语义时使用 `:unlet`。

### 插件布局与组织（Plugin layout）

- **按目录职责拆分**：按 `plugin/`、`autoload/`、`ftplugin/` 组织，而非单文件混杂逻辑。
- **autoload 函数定义规范**：autoload 目录函数使用 `[!]` 与 `[abort]`，确保可重载且遇错即停。
- **命令定义位置明确**：通用命令放 `plugin/commands.vim`，文件类型相关命令放 `ftplugin/`，命令定义不加 `[!]`。
- **autocmd 放入 augroup**：统一放 `plugin/autocmds.vim`，并先 `autocmd!` 清空组以支持重入。
- **映射集中管理**：映射放 `plugin/mappings.vim`，局部 `<Plug>` 映射放 `plugin/plugs.vim`。
- **设置局部化**：优先 `:setlocal` 和 `&l:`，除非确有全局设置需求。

### 空白与格式（Whitespace / formatting）

- **缩进 2 空格**：不使用 Tab。
- **操作符两侧留空格**：命令参数除外，保持可读且一致。
- **行宽控制**：限制 80 列，续行缩进 4 空格。
- **不对齐命令参数**：避免为“视觉对齐”破坏可维护性与 diff 稳定性。

## 最小示例

### 匹配、正则与作用域前缀

```vim
function! myplugin#CheckName(name) abort
  if a:name =~# '\m\C^[a-z_]\+$'
    return v:true
  endif
  return v:false
endfunction
```

### 避免 fragile 命令与映射影响

```vim
function! myplugin#DoAction() abort
  " Good: deterministic behavior, ignores user mappings.
  normal! gg
  let l:found = search('\m\Ctodo', 'n')
  return l:found
endfunction
```

### augroup 与可重入 autocmd

```vim
augroup myplugin_auto_cmds
  autocmd!
  autocmd BufWritePost *.vim call myplugin#LintCurrent()
augroup END
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

- 本地：`vim -Nu NONE -n -es -c "helptags ." -c q`（按项目可替换为更合适检查）
- CI：`vint $(rg --files -g "*.vim")`（若项目启用 vint）

## 本 skill 的回答方式（输出模板）

当用户给出 Vimscript 代码、插件结构或风格问题时，按以下结构输出：

1. **适用范围判定**：可移植性、命名作用域、命令副作用、目录组织、空白格式等涉及点。
2. **结论（3-10 条检查点）**：先高风险（副作用、环境依赖、异常处理）后低风险（命名与格式）。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Google Vimscript Style Guide](https://google.github.io/styleguide/vimscriptguide.xml)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
