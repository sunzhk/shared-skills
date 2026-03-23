<!--
UpdatedAt: 2026-03-23 15:19:44
LatestChange: 实现：基于 Google C++ Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

# C++ Code Style Skill

## 目标

基于 Google C++ Style Guide（当前目标 C++20），为 C++ 代码提供可执行的风格约束，用于：

- Code Review：快速识别头文件组织、命名、接口设计、资源管理与危险特性的违规点。
- 风格统一：在不改变业务语义的前提下减少维护成本与隐性 bug。
- 输出建议：将规则落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目已有 clang-format、lint、构建硬约束，以其为准）。
2. 本 C++ skill（本文）。
3. Google C++ Style Guide（官方原文）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 语言与文件基础（Language / files）

- **语言版本**：目标 C++20；不要使用 C++23 特性。
- **文件扩展名**：实现文件 `.cc`，头文件 `.h`，仅供文本包含的文件用 `.inc`（且应少用）。
- **头文件自包含**：每个 `.h` 应可单独编译，具备 include guard，并包含其直接依赖。
- **`#include` 顺序**：相关头文件 → C 系统头 → C++ 标准库头 → 其他库头 → 本项目头；组间 1 个空行，组内字母序。
- **Include What You Use**：直接使用的符号必须直接 include，避免依赖传递包含。

### 命名与作用域（Naming / scoping）

- **命名风格**：类型 `PascalCase`，变量/参数 `snake_case`，类成员变量尾随 `_`，常量 `kCamelCase`。
- **命名目标**：优先语义清晰，避免难懂缩写与无信息命名。
- **命名空间**：除少数例外，代码放入命名空间；禁止 `using namespace ...`。
- **内部实现隔离**：`.cc` 内部仅本文件使用的符号放匿名命名空间或 `static`（不要在 `.h` 使用）。

### 类与接口设计（Classes / APIs）

- **`struct` vs `class`**：仅“被动数据聚合”用 `struct`，其余用 `class`。
- **继承优先级**：优先组合而非继承；继承关系应表达明确的 “is-a”。
- **重写标注**：重写虚函数使用 `override`（或 `final`），不要和 `virtual` 重复堆叠。
- **成员可见性**：数据成员默认 `private`（常量除外），降低不变量被破坏风险。
- **拷贝/移动语义明确**：在 `public` 区显式 `=default` / `=delete`，让类型是否可拷贝/可移动一眼可见。

### 资源与错误处理（Resource / error handling）

- **所有权清晰**：优先值语义；需转移所有权时优先 `std::unique_ptr`。
- **谨慎共享所有权**：`std::shared_ptr` 仅在确有必要时使用，避免“隐式共享导致设计模糊”。
- **禁止 C++ 异常**：不使用 `throw/catch` 与相关异常机制（按 Google 规则）。
- **静态/全局对象限制**：仅允许平凡析构类型；避免难以推断的初始化/析构顺序问题。

### 函数与参数（Functions）

- **参数方向清晰**：优先返回值而非输出参数；输入参数优先值或 `const&`。
- **函数保持短小**：倾向小而专注的函数；复杂逻辑拆分为可读单元。
- **重载要可读**：调用点无需推导复杂重载规则就能理解行为。
- **默认参数约束**：仅在默认值稳定且可读性收益明显时使用；虚函数禁用默认参数。

### 风格与格式（Formatting）

- **列宽**：最大 80（遵循 Google C++ 指南）；少数无法拆分场景可例外（如 include、长 URL）。
- **缩进**：仅空格，不用 Tab；常规缩进 2 空格。
- **控制流大括号**：`if/for/while/switch` 等优先使用大括号，保持一致可读。
- **空白与断行**：避免行尾空白；复杂表达式按语义层级断行，不为“省行数”牺牲可读性。

### 特性使用边界（Feature boundaries）

- **禁用宏驱动 API**：避免在头文件导出宏；能用 `inline`/`constexpr`/`enum` 就不用宏。
- **禁用危险/复杂特性**：谨慎 RTTI、模板元编程、协程；非必要不引入复杂度。
- **类型转换规范**：使用 C++ 风格 cast（`static_cast` 等），避免 C 风格强转。
- **空指针与字符零值**：指针使用 `nullptr`；字符零值使用 `'\0'`。
- **增量运算**：无后置语义需求时优先前置 `++i/--i`。

## 最小示例

### include 顺序

```cpp
#include "foo/server/fooserver.h"

#include <sys/types.h>
#include <unistd.h>

#include <string>
#include <vector>

#include "base/basictypes.h"
#include "third_party/absl/flags/flag.h"
```

### 命名空间与 override

```cpp
namespace my_project {

class Processor {
 public:
  virtual ~Processor() = default;
  virtual void Run() = 0;
};

class FlightProcessor final : public Processor {
 public:
  void Run() override;

 private:
  int retry_count_ = 0;
};

}  // namespace my_project
```

### 所有权与参数

```cpp
std::unique_ptr<Foo> BuildFoo();

void ConsumeFoo(std::unique_ptr<Foo> foo);

int ComputeScore(const Input& input);
```

## 本 skill 的回答方式（输出模板）

当用户给出 C++ 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：C++ + 涉及点（头文件组织、命名、类设计、所有权、格式、危险特性）。
2. **结论（3-10 条检查点）**：优先指出高风险项（传递 include、异常、全局静态对象、宏滥用、模糊所有权）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：强调默认只做风格层改动，除非用户明确要求语义重构。

## 参考

- [Google C++ Style Guide（官方）](https://google.github.io/styleguide/cppguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
