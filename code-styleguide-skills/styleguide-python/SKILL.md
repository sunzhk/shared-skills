<!--
UpdatedAt: 2026-03-23 15:44:26
LatestChange: 实现：基于 Google Python Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

# Python Code Style Skill

## 目标

基于 Google Python Style Guide，为 Python 代码提供可执行的风格约束，用于：

- Code Review：快速识别导入、命名、异常、注释、类型标注与可维护性问题。
- 风格统一：在不改变业务语义前提下降低“写法漂移”和协作摩擦。
- 输出建议：将规范落到“检查点 + 最小示例”，避免泛化口号。

## 规范来源与优先级

1. 项目/团队既有约定（formatter、lint、type-check、测试框架规范）。
2. 本 Python skill（本文）。
3. Google Python Style Guide（pyguide）。

当冲突或无法确定时，默认选择：更可读、更一致、更利于长期维护的一侧，并说明理由。

## 核心检查清单（可执行）

### 导入与模块结构（Imports / module layout）

- **导入放在文件顶部并分组**：按 future、标准库、第三方、项目内依赖分组并排序。
- **避免同一行多导入**：除 `typing`/`collections.abc` 允许的聚合场景外，一行一个导入。
- **避免相对导入歧义**：优先使用完整包路径，减少运行时路径差异导致的问题。
- **可执行入口显式化**：脚本入口统一放在 `if __name__ == "__main__":` 下。

### 命名与可读性（Naming / readability）

- **命名遵循 snake_case / CapWords**：函数变量用 `snake_case`，类名用 `CapWords`。
- **拒绝晦涩缩写**：除通用短名（如 `i`、`e`、`f`）外，优先语义明确名称。
- **行宽与缩进一致**：默认 80 列、4 空格缩进，不使用 Tab，不用反斜杠续行。
- **单函数聚焦单职责**：函数过长时优先拆分，降低理解与测试成本。

### 异常与控制流（Exceptions / control flow）

- **禁止裸 `except:`**：除“重抛”或明确隔离点外，不捕获所有异常。
- **最小化 `try` 范围**：只包裹可能抛错的关键语句，避免吞掉非预期错误。
- **`assert` 不承载业务逻辑**：前置条件与运行时校验应使用显式条件和异常。
- **空值判断语义准确**：`None` 判断使用 `is None` / `is not None`。

### 注释、文档与 TODO（Comments / docstrings / TODO）

- **公共 API 要有 docstring**：说明用途、参数、返回/产出、异常与关键语义。
- **注释解释“为什么”**：避免复述代码表层行为，重点说明设计意图与约束。
- **TODO 格式统一**：使用 `TODO:` + 可追踪上下文（优先 issue 链接）+ 简短动作说明。
- **标点与语法可读**：注释按完整语句编写，避免含混表达。

### 资源与副作用管理（Resources / side effects）

- **资源显式关闭**：文件、连接、句柄优先 `with` 管理生命周期。
- **避免可变全局状态**：确需使用时限定作用域并清晰注释设计理由。
- **顶层代码克制**：避免导入时执行重逻辑或产生副作用。

### 类型标注与工程约束（Typing / tooling）

- **新增或变更公共接口补类型**：优先给参数和返回值加注解。
- **复杂类型可定义别名**：提升签名可读性，减少重复噪音。
- **必要时显式忽略类型检查**：`# type: ignore` 需最小化并附原因。
- **lint/type-check 保持通过**：将工具告警视作质量信号，不长期堆积忽略。

## 最小示例

### 导入分组与入口

```python
from __future__ import annotations

import os
from collections.abc import Sequence

from absl import app


def main(argv: Sequence[str]) -> None:
    del argv  # Unused.
    print(os.getenv("HOME", ""))


if __name__ == "__main__":
    app.run(main)
```

### 异常处理与 `None` 判断

```python
def parse_port(value: str | None) -> int:
    if value is None:
        raise ValueError("port is required")
    try:
        port = int(value)
    except ValueError as exc:
        raise ValueError(f"invalid port: {value!r}") from exc
    if port < 1024:
        raise ValueError(f"port must be >= 1024, got {port}")
    return port
```

### 资源管理与 TODO 规范

```python
def read_first_line(path: str) -> str:
    # TODO: https://example.com/issues/123 - 支持自定义编码。
    with open(path, encoding="utf-8") as f:
        return f.readline().rstrip("\n")
```

## 本 skill 的回答方式（输出模板）

当用户给出 Python 代码、报错或风格问题时，按以下结构输出：

1. **适用范围判定**：导入、命名、异常、文档、类型、资源管理等涉及点。
2. **结论（3-10 条检查点）**：先高风险（错误处理、资源泄漏、副作用）后低风险（格式与命名）。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
