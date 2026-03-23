<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# R Code Style Skill

## 目标

基于 Google R Style Guide，为 R 代码提供可执行的风格约束，用于：

- Code Review：快速识别命名、依赖引用、赋值方向、返回语义与包文档问题。
- 风格统一：在不改变业务语义前提下减少写法漂移，提升协作可读性。
- 输出建议：将规范落到“检查点 + 最小示例”，避免抽象化口号。

## 规范来源与优先级

1. 项目/团队既有约定（lint、format、包结构、CI 规则）。
2. 本 R skill（本文）。
3. Google R Style Guide（Rguide）。

当冲突或无法确定时，默认选择：更可读、更一致、更便于跨文件检索的一侧，并说明理由。

## 核心检查清单（可执行）

### 命名与可读性（Naming / readability）

- **函数名使用 BigCamelCase**：公开函数命名采用 `BigCamelCase`，便于与对象/变量区分。
- **私有函数以点前缀开头**：内部函数使用 `.BigCamelCase`，显式表达“包内私有”意图。
- **对象命名清晰可检索**：避免历史 `dot.case` 习惯造成 S3 方法歧义。
- **命名表达语义**：减少晦涩缩写，优先可读的领域词汇。

### 赋值与管道（Assignment / pipes）

- **统一左向赋值**：使用 `<-`，避免右向赋值 `->` 破坏“定义位置可检索性”。
- **避免混用多种赋值风格**：同一文件中不要混用 `=`（非参数场景）与 `<-`。
- **管道代码保持可读断行**：长链路按阶段换行，不为“单行紧凑”牺牲可维护性。

### 函数与返回（Functions / returns）

- **显式 `return()`**：函数返回值使用 `return(...)`，不依赖隐式返回。
- **入口参数与边界显式处理**：对缺失值、非法值做明确校验，避免静默失败。
- **单函数单职责**：过长函数拆分为私有辅助函数，降低认知负担。

### 依赖与命名空间（Dependencies / namespace）

- **外部函数显式命名空间**：优先使用 `pkg::fun()`，明确依赖来源。
- **谨慎导入策略**：避免用 roxygen `@import` 大范围引入，降低名称冲突风险。
- **例外需说明**：仅在确有必要时使用 `@importFrom`/包级导入，并在代码中保持一致。

### 常见风险点（Risky patterns）

- **禁止 `attach()`**：避免搜索路径污染与对象遮蔽导致的隐性错误。
- **避免魔法副作用**：函数不应隐式修改全局状态；需要副作用时显式命名与注释。
- **包结构文档完整**：包应提供 `packagename-package.R` 级别文档文件。

## 最小示例

### 命名、赋值与显式返回

```r
ComputeMean <- function(values) {
  if (length(values) == 0) {
    stop("values must not be empty")
  }
  result <- mean(values)
  return(result)
}

.NormalizeVector <- function(values) {
  scale <- max(abs(values))
  if (scale == 0) {
    return(values)
  }
  return(values / scale)
}
```

### 显式命名空间与避免 `attach()`

```r
SummarizePetalWidth <- function() {
  summary_tbl <- dplyr::summarize(
    datasets::iris,
    max_petal = max(Petal.Width)
  )
  return(summary_tbl)
}
```

### 避免右向赋值

```r
# Bad
# datasets::iris %>%
#   dplyr::summarize(max_petal = max(Petal.Width)) -> results

# Good
results <- datasets::iris %>%
  dplyr::summarize(max_petal = max(Petal.Width))
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

- 本地：`Rscript -e "styler::style_dir(".")"`
- CI：`Rscript -e "lintr::lint_dir(".")"`

## 本 skill 的回答方式（输出模板）

当用户给出 R 代码、风格问题或包结构问题时，按以下结构输出：

1. **适用范围判定**：命名、赋值方向、命名空间、返回语义、包文档等涉及点。
2. **结论（3-10 条检查点）**：先高风险（`attach()`、依赖冲突、隐式返回误读）后低风险（命名与格式）。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Google’s R Style Guide](https://google.github.io/styleguide/Rguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
