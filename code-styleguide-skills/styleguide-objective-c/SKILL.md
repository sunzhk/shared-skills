<!--
UpdatedAt: 2026-03-18 15:48:23
LatestChange: 实现：基于 Google Objective-C Style Guide，补充可执行检查清单、冲突裁决与输出模板。
-->

## 目标

基于 Google Objective-C Style Guide，为 Objective-C / Objective-C++ 代码提供**可执行**的风格约束，用于：

- Code Review：快速识别命名、格式化、注释、Cocoa 模式使用中的常见问题。
- 风格统一：在不改变业务语义的前提下统一书写习惯，降低维护成本。
- 输出建议：优先输出“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若已有统一的 iOS/ObjC 规范与工具链，以其为准）。
2. 本 Objective-C skill（本文）。
3. Google Objective-C Style Guide（官方原文）及其建议的 Apple Cocoa Coding Guidelines。

当发生冲突或无法确定时，默认选择：**更可读、更一致、更接近现有代码库风格**的一侧，并说明理由。

## 核心原则（用来裁决“可选项”）

- **为读者优化，不为作者优化**：读代码的时间远大于写代码。
- **保持一致**：指南允许多种写法时，选择一种并在代码库内坚持。
- **与 Apple SDK 使用方式保持一致**：能降低认知与工具成本。
- **风格规则要“物有所值”**：避免为了小收益强行增加记忆负担。

## 核心检查清单（可执行）

### 命名（Naming）

- **描述性优先**：避免不标准缩写；不要为了省横向空间牺牲可理解性。
- **缩写/首字母缩略词**：在名字中统一使用全大写（如 `URL`、`ID`）。
- **包容性语言（Inclusive language）**：命名与注释避免带偏见/歧视含义的词（如 `master/slave`、`blacklist/whitelist` 等），改用中性表达。

#### 文件名（File Names）

- 文件名应反映其包含的类实现（含大小写一致）。
- 常用扩展名：
  - `.h` 头文件
  - `.m` Objective-C 实现
  - `.mm` Objective-C++ 实现
  - `.cc` 纯 C++ 实现（如项目采用）
  - `.c` C 实现
- 可跨项目共享的文件名应具有唯一性（通常带项目或类前缀）。
- Category 文件名：`ClassName+CategoryName.h` / `.m`（如 `NSString+GTMParsing.h`）。

#### 前缀（Prefixes）

- ObjC 全局命名空间容易冲突，类/协议/全局函数/全局常量通常需要前缀（建议至少 3 个字符，避免 Apple 保留的两字符前缀）。
- Category：
  - 类名与 `(` 之间有一个空格：`@interface UIViewController (GTMCrashReporting)`
  - Category 方法建议用小写前缀 + `_`，避免选择器冲突（如 `gtm_myCategoryMethodOnAString:`）。

#### 方法命名（Objective-C Method Names）

- 以句子可读为目标，参数名与方法名“读起来通顺”。
- 访问器不使用 `get` 前缀：`- (id)delegate;` 而不是 `getDelegate`。
- 布尔值：getter 方法名以 `is` 开头，但 property 名不包含 `is`：

  - `@property(nonatomic, getter=isGlorious) BOOL glorious;`
- 点语法只用于 property（不要用来调用普通方法）。

#### 函数命名（C Functions）

- 函数名使用 PascalCase（每个单词首字母大写）。
- 非 static 函数必须带前缀以降低冲突风险。

#### 变量命名（Variables）

- 局部变量一般 lowerCamelCase。
- **实例变量**：前导下划线（如 `_usernameTextField`）。
- **文件级/全局变量**：前缀 `g`（如 `gGlobalCounter`），但应尽量少见。
- 不使用匈牙利命名标注静态类型（int/pointer 等）。

#### 常量（Constants）

- 常量用 mixedCase 分词；全局/文件级常量使用合适前缀。
- 静态存储期、实现文件内部私有常量可用 `k` 前缀（如 `kFileCount`）。
- 为 Swift 互操作：枚举值命名建议扩展 typedef 名（如 `DisplayTingeGreen`）。

### 类型与声明（Types and Declarations）

- 局部变量在**最小可行作用域**声明，尽量靠近使用点，并在声明处初始化。
- implementation 文件中的文件级变量/常量若不需对外可见，使用 `static`（或 ObjC++ 匿名命名空间）。
- 避免 unsigned 整数（除非匹配系统接口），尤其是“倒数到 0”的循环。
- 注意 `long/NSInteger/NSUInteger/CGFloat` 在 32/64 位下大小差异；需要精确尺寸时用 `int32_t/int64_t`。
- `CGFloat` 常量：避免项目里混用 `float`/`double` 后缀风格；选一种并保持一致。

### 注释（Comments）

- 注释要像叙述文本一样可读，注意标点/拼写/语法；用一致风格。
- “声明注释”说明用途/契约；“实现注释”解释 tricky/微妙/复杂实现与取舍。
- 行尾注释：代码与注释之间至少 **2 个空格**；连续多行注释可对齐但不强制。
- 需要消歧义时在注释中用反引号或 Doxygen 的 `@c` 标记符号（避免含糊）。
- 文件头可选描述；若文件有 author 行且改动很大，可考虑删除 author 行（版本历史更准确）。

### C 语言特性（C Language Features）

- **避免宏（Macros）**：优先 `const`、`enum`、C 函数等；必要宏用唯一名称，尽量缩小作用域并可 `#undef`。
- 允许 `__typeof__`，但不要滥用类型推导；`__auto_type` 仅限 block/函数指针的局部变量场景。

### Cocoa / Objective-C 模式（常见易踩点）

- **指定初始化器**：用 `NS_DESIGNATED_INITIALIZER` 等标注；子类新增 designated initializer 时覆盖父类 designated initializers，避免无效初始化路径。
- **NSObject 覆写方法放前面**：例如 `init.../dealloc/copyWithZone:/description/isEqual:/hash` 等，保持集中。
- **init 中不要把 ivar 再初始化成 0/nil**（冗余）。
- 头文件里声明 ivar：应为 `@protected` 或 `@private`（通常更推荐放到实现文件或用 property 自动合成）。
- **不使用 `+new`**：改用 `+alloc/-init`。
- **公共 API 保持简单**：不需要公开的方法不要放到 public interface，降低误用与“意外 override”风险。
- **#import vs #include**：`#import` ObjC/ObjC++ 头，`#include` C/C++ 头；系统框架优先 umbrella header（`@import UIKit;` 或 `#import <Foundation/Foundation.h>`）。
- **include 顺序**：相关头文件 → 系统 → 语言库 → 其他依赖；每组间一个空行；组内按字母序。
- **initializer / dealloc 避免给 self 发消息**（含属性访问器），尽量直接操作 ivar，避免子类 override 导致未初始化/已释放状态被访问。
- **避免冗余 property 访问**：同一链式访问多次时，提取局部变量减少消息分发与 ARC retain/release。
- **Copy 语义**：接收并持有“可能可变”的对象（如 `NSString/NSArray/NSSet/NSDictionary` 等有 mutable variant 的类型），setter/initializer 通常应 `copy`；异步 dispatch 前 copy；proto 等可变对象也通常应 copy。
- **轻量泛型**：为 `NSArray/NSDictionary/NSSet` 等使用 lightweight generics 以提升类型安全；复杂时用 typedef 提升可读性。
- **避免抛异常**：不 `@throw`；必要时可 `@try/@catch/@finally` 捕获第三方/系统异常并注释说明可能抛出的调用点。
- **nil 检查**：不要为了“避免给 nil 发消息”而写多余判断；但对 C/C++ 指针与 block 指针仍需避免 `NULL` 解引用。
- **Nullability**：使用 `nullable/nonnull/null_resettable` 等标注；优先 `_Nullable/_Nonnull` 语义；不要故意违反 nullability 契约。
- **BOOL 陷阱**：避免把一般整数/位运算结果直接转换为 `BOOL`；用条件表达式返回 `YES/NO`；不要写 `if (great == YES)`。
- **无 ivar 的容器**：`@interface/@implementation` 不要写空 `{}`。

### 格式与空白（Spacing and Formatting）

- **仅使用空格**，不使用 Tab；缩进 **2 空格**。
- **行宽**：100 列（ObjC 文件）。
- 方法声明/定义：
  - `-`/`+` 与返回类型之间 1 个空格：`- (void)foo...`
  - 参数列表除参数之间外不额外加空格。
  - 超长声明：每个参数独立一行；除首行外至少 4 空格缩进；优先对齐冒号。
- 条件语句：
  - `if/while/for/switch` 后有空格；比较运算符两侧空格。
  - `if` 有 `else` 时，两支都应使用大括号；`else` 与前一个 `}` 同行。
  - switch 的有意 fall-through 用注释说明。
- 表达式：
  - 二元运算符/赋值两侧空格；一元运算符不加空格；括号内不加空格。
- 方法调用：
  - 与声明类似：要么一行全参数，要么每行一个参数并对齐冒号；避免混合风格。

### Objective-C++（混编）

- 遵循“实现所在语言”的风格：`@implementation` 内按 ObjC 命名；C++ 类方法按 C++ 风格；文件内保持一致。

### 风格例外标记

- 需要明确声明“此处不遵循规范”的行，使用 `// NOLINT` 或 `// NOLINTNEXTLINE`（注意 `//` 后一个空格）。

## 本 skill 的回答方式（输出模板）

当用户给出 ObjC/ObjC++ 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Objective-C / Objective-C++ + 涉及点（命名/宏/初始化/ARC copy/nullability/格式化等）。
2. **结论（3–10 条检查点）**：逐条对应本规范条目，优先指出“高风险可读性/正确性”问题。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：默认只做风格层面的调整（除非用户明确要求语义重构）。

## 参考

- Google Objective-C Style Guide（官方）：https://google.github.io/styleguide/objcguide.html
- Google Style Guides（索引）：https://google.github.io/styleguide/

