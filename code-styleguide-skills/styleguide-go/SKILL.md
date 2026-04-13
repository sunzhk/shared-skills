---
name: styleguide-go
description: Use when writing or reviewing go code and you need language-specific style conventions and checks.
---

<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# Go Code Style Skill

## 目标

基于 Google Go Style 文档体系，为 Go 代码提供可执行的风格约束，用于：

- Code Review：快速识别可读性、命名、错误处理、接口设计与测试中的风格问题。
- 风格统一：在不改变业务语义前提下减少“写法漂移”与审查争议。
- 输出建议：将规则落到“检查点 + 最小示例”，避免泛泛描述。

## 规范来源与优先级

1. 项目/团队约定（若已有强制 `gofmt`、`go vet`、lint 规则，以其为准）。
2. 本 Go skill（本文）。
3. Google Go Style Guide（Guide）。
4. Google Go Style Decisions（冲突细节与解释）。
5. Google Go Best Practices（非强制但推荐）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 基础与可读性（Basics / readability）

- **必须格式化**：代码提交前保持 `gofmt` 后格式，不手写“个性化排版”。
- **可读性优先**：优先让不了解上下文的读者快速看懂，而非为作者省输入。
- **局部一致性优先**：在不违背硬规则前提下，优先与相邻代码风格保持一致。
- **避免无意义抽象**：不要为“看起来通用”而引入过早抽象层级。

### 命名与包组织（Naming / packages）

- **包名简洁小写**：包名短、语义明确、全小写，避免下划线和冗长前缀。
- **导出符号最小化**：非必要不导出；导出 API 命名应直接表达行为与意图。
- **命名避免重复上下文**：调用点已包含包语义时，标识符不重复包名。
- **缩写可读**：缩写只在业内通用且不损可读性时使用（如 `ID`, `URL`）。

### 错误处理与控制流（Errors / control flow）

- **错误必须显式处理**：禁止静默丢弃 `error`（除非明确注释说明可忽略原因）。
- **错误信息可定位**：返回错误时应携带足够上下文，便于定位失败位置。
- **尽早返回**：优先处理错误与边界条件，减少深层嵌套。
- **`panic` 使用克制**：仅用于不可恢复错误或程序不变量被破坏场景。

### 函数与接口设计（Functions / interfaces）

- **函数保持小而专注**：单个函数尽量只做一件事，控制认知负担。
- **参数与返回值清晰**：避免布尔“魔法参数”，必要时使用具名类型或配置结构体。
- **接口按消费者定义**：接口应小且面向使用方，不为“未来可能”预设大接口。
- **组合优于继承思维**：通过组合与小接口组织行为，避免“类层级迁移思维”。

### 并发与共享状态（Concurrency）

- **共享可变状态最小化**：优先通过消息传递而非随意共享内存。
- **并发生命周期可追踪**：goroutine 创建处应能看出退出条件与资源回收路径。
- **避免隐式竞态**：对共享变量访问需有清晰同步策略（channel/lock/atomic）。

### 测试与可维护性（Testing / maintainability）

- **测试行为而非实现细节**：优先验证可观察行为，减少脆弱的内部耦合测试。
- **表驱动测试优先**：多输入场景优先 table-driven 形式，提升覆盖与可读性。
- **失败信息要可诊断**：断言失败输出应包含关键输入与期望/实际差异。
- **近处修复原则**：新增逻辑时同步补齐邻近测试与风格问题，避免技术债扩散。

## 最小示例

### 错误处理与尽早返回

```go
func LoadUser(ctx context.Context, repo UserRepo, id string) (*User, error) {
    if id == "" {
        return nil, fmt.Errorf("empty user id")
    }

    user, err := repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find user by id %q: %w", id, err)
    }
    return user, nil
}
```

### 小接口面向消费者

```go
type Clock interface {
    Now() time.Time
}
```

### 表驱动测试

```go
func TestNormalize(t *testing.T) {
    cases := []struct {
        name string
        in   string
        want string
    }{
        {name: "trim spaces", in: "  A ", want: "a"},
        {name: "already lower", in: "go", want: "go"},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            got := Normalize(tc.in)
            if got != tc.want {
                t.Fatalf("Normalize(%q) = %q, want %q", tc.in, got, tc.want)
            }
        })
    }
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

- 本地：`gofmt -w . && go vet ./...`
- CI：`test -z "$(gofmt -l .)" && go vet ./... && go test ./...`

## 本 skill 的回答方式（输出模板）

当用户给出 Go 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：Go + 涉及点（命名、错误处理、函数接口、并发、测试、可读性）。
2. **结论（3-10 条检查点）**：先高风险再低风险，优先指出可导致维护成本上升或缺陷的问题。
3. **最小示例**：仅给必要的正确/错误对照或 before/after。
4. **不改变语义声明**：默认仅做风格与可读性改进，除非用户明确要求行为重构。

## 参考

- [Google Go Style（入口）](https://google.github.io/styleguide/go/)
- [Google Go Style Guide（Canonical）](https://google.github.io/styleguide/go/guide)
- [Google Go Style Decisions（Normative）](https://google.github.io/styleguide/go/decisions)
- [Google Go Best Practices（参考）](https://google.github.io/styleguide/go/best-practices)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
