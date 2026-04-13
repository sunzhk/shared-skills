---
name: styleguide-csharp
description: Use when writing or reviewing csharp code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# C# Code Style Skill

## 目标

基于 Google C# Style Guide，为 C# 代码提供可执行的风格约束，用于：

- Code Review：快速识别命名、文件结构、异常处理与可维护性问题。
- 风格统一：在不改变业务语义前提下减少写法漂移与审查争议。
- 输出建议：将规范落到“检查点 + 最小示例”，避免泛泛描述。

## 规范来源与优先级

1. 项目/团队既有约定（`.editorconfig`、Roslyn 分析器、CI 规则）。
2. 本 C# skill（本文）。
3. Google C# Style Guide（官方原文）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 文件与结构（Files / structure）

- **一文件一主要类型**：文件名与主要类型名保持一致，便于检索与导航。
- **`using` 有序且去冗余**：保持稳定分组与排序，移除未使用 `using`。
- **命名空间明确**：使用明确命名空间，避免全局污染与冲突。
- **可见性显式**：类型与成员的访问级别应显式声明，避免隐式默认带来误解。

### 命名与可读性（Naming / readability）

- **类型名 `PascalCase`**：类、结构体、接口、枚举、委托统一 `PascalCase`。
- **成员与局部变量 `camelCase`**：参数与局部变量保持 `camelCase`，避免无意义缩写。
- **接口前缀 `I`**：接口名使用 `I` 前缀（如 `IOrderService`）。
- **私有字段前缀一致**：私有字段使用统一前缀策略（如 `_fieldName`），并与项目既有风格一致。

### 控制流与异常（Control flow / exceptions）

- **大括号风格一致**：`if/for/while/switch` 统一使用大括号，减少单行语句误修改风险。
- **尽早返回**：优先处理异常路径与边界条件，降低嵌套层级。
- **异常要有上下文**：抛出异常时附带可诊断信息；捕获后重抛保留原始栈信息。
- **避免空 `catch`**：确需吞异常时必须注释说明原因与影响范围。

### 类型与 API 设计（Types / API design）

- **优先显式意图**：公共 API 的参数、返回值和可空性语义应清晰可见。
- **不可变优先**：能用只读就不用可变，减少共享状态带来的复杂性。
- **集合接口优先**：对外暴露接口时优先 `IReadOnlyList<T>`/`IEnumerable<T>` 等抽象类型。
- **避免过度魔法**：运算符重载、隐式转换等仅在收益显著且语义直观时使用。

### 异步与资源管理（Async / resources）

- **异步方法后缀 `Async`**：返回 `Task/Task<T>` 的方法命名统一 `Async` 后缀。
- **避免同步阻塞异步**：避免 `.Result`/`.Wait()` 阻塞异步流。
- **资源显式释放**：可释放对象使用 `using`/`await using` 管理生命周期。
- **取消机制显式传递**：有超时/取消需求时显式传递 `CancellationToken`。

### 工程落地（Tooling workflow）

- **格式化与分析器前置**：本地提交前执行 formatter 与 analyzer，减少 CI 往返。
- **规则变更可审计**：调整 `.editorconfig` 或 analyzer 规则需说明影响范围。
- **风格与功能改动拆分**：大面积格式化与业务逻辑改动分开提交。

## 最小示例

### 命名与可见性

```csharp
public interface IUserRepository
{
    Task<User?> FindByIdAsync(Guid userId, CancellationToken cancellationToken);
}

public sealed class UserService
{
    private readonly IUserRepository _userRepository;

    public UserService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }
}
```

### 异常与尽早返回

```csharp
public static int ParsePort(string? value)
{
    if (string.IsNullOrWhiteSpace(value))
    {
        throw new ArgumentException("port is required", nameof(value));
    }

    if (!int.TryParse(value, out var port))
    {
        throw new ArgumentException($"invalid port: {value}", nameof(value));
    }

    return port;
}
```

### 异步与资源管理

```csharp
public async Task<string> ReadFirstLineAsync(string path, CancellationToken cancellationToken)
{
    await using var stream = File.OpenRead(path);
    using var reader = new StreamReader(stream);
    var line = await reader.ReadLineAsync(cancellationToken);
    return line ?? string.Empty;
}
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

- 本地：`dotnet format`
- CI：`dotnet format --verify-no-changes && dotnet build`

## 本 skill 的回答方式（输出模板）

当用户给出 C# 代码、风格问题或审查请求时，按以下结构输出：

1. **适用范围判定**：命名、结构、异常、异步、资源管理、工具链等涉及点。
2. **结论（3-10 条检查点）**：先高风险（异常处理、资源泄漏、异步阻塞）后低风险（命名与格式）。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Google C# Style Guide](https://google.github.io/styleguide/csharp-style.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
- [C# Coding Conventions（Microsoft）](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [dotnet format（官方工具）](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format)
