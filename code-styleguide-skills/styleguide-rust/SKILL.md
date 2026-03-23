<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# Rust Code Style Skill

## 目标

基于 rustfmt 官方文档，为 Rust 代码提供“可执行、可自动化、可审计”的风格约束，用于：

- Code Review：快速识别格式一致性、配置漂移和工具链不一致问题。
- 风格统一：在不改变业务语义前提下，以 rustfmt 输出作为唯一格式真值。
- 工程落地：把规范落到本地命令、CI 检查、批量修复和异常处理流程。
- 输出建议：将规则落到“检查点 + 最小示例 + 执行步骤”，避免泛泛描述。

## 规范来源与优先级

1. 项目/团队既有约定（`rustfmt.toml`、CI 检查、clippy 规则）。
2. 本 Rust skill（本文）。
3. rustfmt 官方文档与稳定通道行为。

当冲突或无法确定时，默认选择：更接近项目 `rustfmt` 实际输出、更一致、更利于批量自动化修正的一侧，并说明理由。

## 配置与运行策略（必须明确）

### 配置分层

- **仓库级唯一配置**：优先在仓库根维护单一 `rustfmt.toml`，避免子目录多份配置互相覆盖。
- **工具链版本固定**：在团队层面固定 Rust toolchain，减少不同机器 rustfmt 版本差异。
- **配置变更需评审**：修改 `rustfmt.toml` 必须附影响说明（会改哪些文件、是否需要一次性批量格式化）。

### 运行模式

- **开发阶段**：使用 `cargo fmt` 快速修复格式偏差。
- **CI 阶段**：使用 `cargo fmt --all -- --check` 做只校验不改写，保证流水线可重复。
- **增量改动优先**：业务迭代中尽量只格式化受影响文件，避免无关大 diff。
- **专项治理例外**：若是“全仓统一格式化”专项，单独提交一次批量变更并与功能改动分离。

### 稳定性边界

- **默认 stable 行为**：常规项目以 stable rustfmt 为准。
- **避免依赖不稳定选项**：对 unstable 配置保持克制，确需使用时必须说明风险与回退方案。
- **跨环境一致性优先**：任何新配置先在本地与 CI 验证一致后再推广。

## 核心检查清单（可执行）

### 格式化基线（Formatting baseline）

- **统一使用 rustfmt**：提交前必须通过 `cargo fmt`（或等效 rustfmt 命令）格式化。
- **优先稳定配置**：默认遵循 stable rustfmt，避免依赖未稳定选项导致跨环境漂移。
- **不手工对齐排版**：避免“视觉对齐”式空格微调，交由 rustfmt 自动处理。
- **最小化格式争议**：代码评审优先讨论语义与设计，格式问题以 rustfmt 结果为准。
- **不在评审中手写格式修复**：能由 rustfmt 自动修复的，不做人工“审美调整”评论。

### 文件与声明布局（File / item layout）

- **模块与声明顺序清晰**：`use`、`const`、`type`、`struct/enum`、`impl`、`fn` 保持稳定分组与顺序。
- **导入分组一致**：同模块内 `use` 保持一致写法，必要时由 rustfmt 自动重排与折行。
- **长签名自动换行**：函数参数、泛型约束、where 子句过长时按 rustfmt 默认换行，不手动拼接。
- **链式调用可读断行**：方法链、builder 链遵循 rustfmt 断行结果，避免人为混搭风格。
- **属性与宏附近保持简洁空行**：避免“为视觉分块”插入过多空行导致结构噪音。

### 表达式与控制流（Expressions / control flow）

- **块结构统一**：`if/match/loop` 等控制结构使用统一大括号与缩进风格。
- **match 分支格式稳定**：多分支 `match` 保持一致缩进与逗号策略，避免局部特例。
- **闭包与参数格式一致**：闭包参数、返回类型、捕获场景遵循 rustfmt 默认布局。
- **复杂表达式拆分优先可读**：超长表达式优先拆成中间变量，减少“格式正确但难读”。
- **避免“强行单行化”**：即使可压成一行，也优先保留 rustfmt 给出的多行可读结构。

### 注释与文档（Comments / docs）

- **注释不做列对齐**：注释与代码的间距交给 rustfmt 与常规缩进，不手工拉齐。
- **文档注释紧邻目标项**：`///` 与 `//!` 贴近被说明项，避免被无关空行分隔。
- **注释解释“为什么”**：避免重复代码表层含义，优先补充约束、边界与设计原因。
- **示例代码也要可格式化**：文档中的 Rust 片段应能通过 rustfmt（避免“文档误导”）。

### 工程落地（Tooling workflow）

- **本地与 CI 同步**：本地格式化命令与 CI 检查命令保持一致，避免“本地过、CI 挂”。
- **批量修正优先自动化**：历史代码统一风格时优先一次性 rustfmt，而非人工逐段修改。
- **配置变更显式评审**：修改 `rustfmt.toml` 时说明影响范围并同步团队。
- **格式化失败可快速定位**：CI 输出应包含失败命令与重跑指引。

## 常见冲突与处置

- **冲突 1：团队“视觉偏好” vs rustfmt 输出**  
  处置：以 rustfmt 输出为准；若确有团队共识，优先通过 `rustfmt.toml` 配置表达，而非人工维护。
- **冲突 2：功能改动夹杂大面积格式化 diff**  
  处置：拆分提交，先纯格式化、后功能变更，提升审查效率。
- **冲突 3：本地通过但 CI 失败**  
  处置：先对齐 toolchain 与命令，再检查是否存在环境差异或配置未提交。
- **冲突 4：多 crate 仓库格式化边界不清**  
  处置：统一在仓库根执行 `cargo fmt --all`，并固定同一配置来源。

## 执行清单（给开发者）

1. 拉取最新代码并确认 Rust toolchain 版本一致。
2. 运行 `cargo fmt --all` 修复格式。
3. 运行 `cargo fmt --all -- --check` 做只校验。
4. 若需改 `rustfmt.toml`，单独提交并附影响说明。
5. 提交前确认本次 diff 不混入无关目录的大面积格式化。

## 最小示例

### 格式化前后（由 rustfmt 接管）

```rust
// Before
fn build_user(id:u64,name:String)->User{User{id, name}}

// After
fn build_user(id: u64, name: String) -> User {
    User { id, name }
}
```

### 长参数与 where 子句交给 rustfmt 换行

```rust
fn transform<T, U>(input: T, mapper: impl Fn(T) -> U, fallback: U) -> U
where
    T: Clone + Send + Sync + 'static,
    U: Clone + Send + Sync + 'static,
{
    mapper(input.clone())
}
```

### 链式调用保持一致布局

```rust
let result = users
    .iter()
    .filter(|u| u.enabled)
    .map(|u| u.name.clone())
    .collect::<Vec<_>>();
```


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 工程化命令（本地/CI）

- 本地：`cargo fmt --all && cargo clippy --all-targets --all-features -D warnings`
- CI：`cargo fmt --all -- --check && cargo clippy --all-targets --all-features -D warnings`

## 本 skill 的回答方式（输出模板）

当用户给出 Rust 代码、格式化冲突或风格问题时，按以下结构输出：

1. **适用范围判定**：格式化、配置、CI、导入布局、表达式断行、注释文档等涉及点。
2. **结论（3-10 条检查点）**：先高风险（CI 不一致、配置漂移、版本不一致）后低风险（局部布局）。
3. **最小修正示例**：给出必要的 before/after，避免无关重构。
4. **执行步骤**：给出可直接复制的命令序列（本地修复 + CI 校验）。
5. **行为影响声明**：默认仅做风格和可维护性优化，不改变业务语义。

## 参考

- [Rustfmt 官方文档](https://rust-lang.github.io/rustfmt/)
- [Clippy 官方文档](https://doc.rust-lang.org/clippy/)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
