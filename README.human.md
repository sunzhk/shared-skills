

# shared-skills（给人看的说明）

本文档面向开发者与项目维护者，重点回答：

- 这些 skill 是做什么的？
- 怎么在项目里接入？
- 日常如何使用？
- 如何维护与升级？

## 包含的 skills

### `code-styleguide-skills/`

- 用途：多语言代码风格建议与审查支持。
- 典型场景：重构风格统一、Code Review 风格争议、命名与可读性建议。
- 入口 skill：`styleguide-router`（按语言分发到具体子 skill）。

### `eng-practices/`

- 用途：代码评审流程与评论策略（基于 Google eng-practices）。
- 典型场景：PR/CL 评审、评论措辞、冲突处理、Small CL 拆分、评审速度优化。
- 入口 skill：`eng-practices/SKILL.md`。

### `unit-test-guide-skills/`

- 用途：按项目类型输出单元测试规范（Android / iOS / 微信小程序）。
- 典型场景：补测试、统一测试分层、确定 mock/fake 策略、形成可执行测试任务清单。
- 入口 skill：`unit-test-guide-skills/unit-test-router/SKILL.md`（按平台分发到子 skill）。
- 子 skill：`unit-test-android`、`unit-test-ios`、`unit-test-wechat-miniprogram`。
- 规则基线：以官方文档为先（Android Developers、Apple Developer、微信开放文档）。

### `lean-spec-planning-with-files-bridge/`（一体化双轨协作）

- 用途：**强制双轨模式**——将 LeanSpec（`specs/` 规格轨）与 planning-with-files（`doc/plans/` 执行轨）合为一体。一键落地 Cursor 规则、hooks（含 **SpecRef 感知**）、计划脚本与协作文档；与 `planning-with-files-zh` 方法论对齐。
- 典型场景：初始化规划目录并同时建立规格轨、安装 planning hooks、多计划 `ACTIVE` 指针、**双轨协作**（`specs/` + `doc/plans/` + `SpecRef`/`ExecutionPlan`）。口令建议用 **「按双轨」**、**「双轨开需求」** 或技能全名。
- 入口 skill：`lean-spec-planning-with-files-bridge/SKILL.md`；人类操作说明见同目录 `README.md`（`bootstrap.sh`）。
- 权威协作文档：`lean-spec-planning-with-files-bridge/planning-with-files-and-lean-spec-collaboration.md`（bootstrap 复制到 `doc/plans/COORDINATION_LEANSPEC.md`）。

## LeanSpec 安装与初始化（须自行完成）

`configure-from-readme.sh` **不会**安装 LeanSpec CLI、**不会**执行 `lean-spec init` / `npx lean-spec init`，也**不会**写入 Cursor 的 LeanSpec MCP 配置。默认流程里与 LeanSpec 相关的仅是：在启用 `lean_spec_planning` 时，bootstrap 会将协作文档复制到业务仓库 `doc/plans/COORDINATION_LEANSPEC.md`，便于人类与 Agent 查阅「Spec ↔ `doc/plans/`」如何配合。

若要用 LeanSpec 管理 `specs/`、看板或官方 Web UI，请在本机或 CI 中**另行**按官方文档完成安装与初始化：

- 官方中文指南（概述、快速开始、AI 集成含 MCP 示例）：[什么是 LeanSpec？ | LeanSpec](https://www.lean-spec.dev/zh-Hans/docs/guide/)

**环境**：需要可用的 **Node.js**（建议 LTS）与 **npm**（自带 `npx`）。具体版本以 LeanSpec npm 包说明为准。

**常见初始化方式（择一即可）**

1. **全局 CLI**（适合频繁使用）：`npm install -g lean-spec`，在业务仓库根执行 `lean-spec init`（或按文档使用教程示例如 `npx lean-spec init --example …`）。
2. **不装全局**（适合偶发使用）：在仓库根执行 `npx lean-spec init`（首次会下载依赖，需网络）。

初始化后通常会出现 `specs/` 等目录结构；可视化与检索可选用 `lean-spec board`、`lean-spec stats`、`lean-spec ui`（见官方指南）。若要在 Cursor 中通过 MCP 访问 Spec，按指南「AI 集成」配置 MCP，与 shared-skills 的 `configure-from-readme.sh` 相互独立。

**非 Node 主栈仓库**：仍可只用 Markdown + 目录约定手工维护 `specs/`，不必强装 CLI；需要自动化与看板时再补装 Node 与 `lean-spec`。

## 如何在项目中接入

推荐将本仓库作为共享规范源，在业务项目中“引用”而非复制粘贴。

### 方式 A：Git submodule（推荐，权威方案）

适用：需要版本锁定和可控升级节奏的团队。

#### A1. 首次接入（在业务项目根目录）

```bash
git submodule add <shared-skills-repo-url> .cursor/shared-skills
git submodule update --init --recursive
```

#### A2. 克隆后初始化（给新同学/CI）

```bash
git submodule update --init --recursive
```

#### A3. 拉取子模块最新提交（跟进上游）

```bash
git submodule update --remote --recursive
```

如果你希望固定到某个 release/tag，建议在子模块目录手动 checkout 到目标 tag，并在主仓库提交子模块指针变更。

#### A4. 常见更新流程（推荐）

1. 在业务项目执行 `git pull`。
2. 执行 `git submodule update --init --recursive`。
3. 如需升级共享技能，再执行 `git submodule update --remote --recursive`。
4. 回归验证后，提交主仓库中“子模块指针”变更。

#### A5. 常见问题排查

- **问题：目录是空的或未检出内容**
  - 处理：执行 `git submodule update --init --recursive`。
- **问题：主仓库更新后本地 submodule 版本没变化**
  - 处理：确认已拉取主仓库最新提交并执行 submodule update。
- **问题：本地误改了 submodule 内容**
  - 处理：先在子模块内处理/清理改动，再回到主仓库更新指针。

### 方式 B：Git subtree

适用：不想引入 submodule 使用心智，但仍希望同步上游。

### 方式 C：直接拷贝（仅试验）

适用：短期 PoC。  
风险：后续升级困难、容易版本漂移。

## submodule 路径约定

- 推荐路径：`.cursor/shared-skills`
- 该路径下的典型结构：
  - `.cursor/shared-skills/configure-from-readme.sh`（README 驱动一键配置入口）
  - `.cursor/shared-skills/code-styleguide-skills/`
  - `.cursor/shared-skills/eng-practices/`
  - `.cursor/shared-skills/unit-test-guide-skills/`
  - `.cursor/shared-skills/lean-spec-planning-with-files-bridge/`

## README 驱动一键配置（推荐：落仓库规则与技能入口）

目标：人类或 CI 在业务项目根执行一条 `configure-from-readme.sh`，即可完成 `.cursor/`、`doc/plans/`、`**AGENTS.md` 中的 Shared Skills 列表**等。**默认键值（含 `cursor_skill_links`）已预写在 shared-skills 仓库根 `README.md` 的 `<!-- shared-skills-config -->` 中**；脚本**先应用该默认块，再读取业务项目 `README.md` 中的同名块并覆盖**。因此空项目或仅有不含配置块的 README 时，**无需手写 `cursor_skill_links`**；仅在需要关闭某项或增减技能时，在业务 README 中加块覆盖即可。

### 1. 业务项目 `README.md` 中的配置块（可选）

若全部接受默认，可**不写**本块。若要覆盖部分键，在 **项目根目录 `README.md`** 任意位置加入 HTML 注释块（键值区分大小写；`#` 开头为注释行）。完整示例（与仓库默认一致，仅作参考；不必复制到业务项目）：

```markdown
<!-- shared-skills-config
# 一体化双轨协作：写入 .cursor/rules、hooks（含 SpecRef 感知）、doc/plans 脚本与协作文档
lean_spec_planning=1
# 若为 1，则等价于 bootstrap 传入 --no-install-planning-with-files-zh
lean_spec_planning_no_install_pwfz=0
# 声明要写入 AGENTS.md 的技能（相对 shared-skills 根的路径，该路径下须有 SKILL.md；不创建 .cursor/skills 软链）
# 聚合包 code-styleguide-skills、unit-test-guide-skills 可写顶层目录名，脚本会自动改为 …/styleguide-router、…/unit-test-router
cursor_skill_links=lean-spec-planning-with-files-bridge,eng-practices,code-styleguide-skills,unit-test-guide-skills
-->
```

**向后兼容**：旧键 `planning_with_files_ext=1` 仍映射至 `lean-spec-planning-with-files-bridge/bootstrap.sh`；建议迁移到 `lean_spec_planning=1`。旧键 `lean_spec_bridge_doc` 已废弃（协作文档复制已含于一体化 bootstrap）；若仅设置该键而未启用 `lean_spec_planning`，脚本会提示改用 `lean_spec_planning=1`。

**布尔值**：`1` / `true` / `yes` / `on` 为启用，其余为不启用。

**执行顺序**（脚本固定）：合并配置（shared-skills 根 README 默认块 → 业务 README 覆盖）→ `lean_spec_planning`（或向后兼容 `planning_with_files_ext`，均调用同一 `bootstrap.sh`）→ **解析** `cursor_skill_links`（含聚合包名展开）→ 校验 `SKILL.md` → 写入 `AGENTS.md`。

**不在此脚本内**：**LeanSpec** 的 CLI 安装、`lean-spec init` / `npx lean-spec init`、MCP 配置等——详见上文 **「LeanSpec 安装与初始化（须自行完成）」**；需要时可后续在配置块增加新键并在 `configure-from-readme.sh` 中实现自动化。

`**cursor_skill_links` 说明**：逗号分隔；每一项解析后为 **shared-skills 根下的相对路径**，且该路径（最后一级目录）下须有 `SKILL.md`。普通技能包为单层名（如 `eng-practices`、`lean-spec-planning-with-files-bridge`）。**聚合包**可写顶层目录名 `code-styleguide-skills` 或 `unit-test-guide-skills`，脚本会分别展开为 `code-styleguide-skills/styleguide-router`、`unit-test-guide-skills/unit-test-router` 再校验与写入；若你更希望显式声明，也可直接写上述带子路径的项（与展开结果相同，不会重复写入）。脚本将 `.cursor/shared-skills/<解析后路径>/SKILL.md` 写入 `AGENTS.md`，**不会**向 `.cursor/skills/` 创建软链。`planning-with-files-zh` 通常由 bootstrap 从本机 `~/.agents/skills/` 安装到项目，**不必**在此列表中重复。

`**AGENTS.md` 写入**：脚本执行结束前会自动写入或更新业务项目根 `AGENTS.md` 中的 `## Shared Skills` 节，内容为解析后各技能的 `.cursor/shared-skills/.../SKILL.md` 路径（可含 `/`）。`AGENTS.md` 应提交到 git，使团队所有成员和 CI 环境中的 Agent 在冷启动时即可正确路由，**无需再次运行配置脚本**。

### 2. 一键执行（ submodule 场景）

假设业务项目已按上文将共享库置于 `.cursor/shared-skills/`：

```bash
cd /path/to/your-project
git submodule update --init --recursive
bash .cursor/shared-skills/configure-from-readme.sh
```

若 shared-skills 在其他路径，可显式指定：

```bash
SKILLS_ROOT=/path/to/shared-skills bash /path/to/shared-skills/configure-from-readme.sh /path/to/your-project
```

### 3. 与 `AGENTS.md` 的关系

- `**README.md` 配置块 + `configure-from-readme.sh**`：负责**仓库内可执行产物**（规则、hooks、计划目录、协作文档副本、`**AGENTS.md` 的 Shared Skills 节**）。
- `**AGENTS.md`**：由脚本自动生成其中的 `## Shared Skills` 节；人工部分（团队约定、项目级路由）可继续手写在其他节，脚本不会触碰。
- `**AGENTS.md` 须提交 git**：它是 Agent 冷启动的路由入口，不提交则新同学/CI clone 后 Agent 无法发现 skill。

### 4. Agent 冷启动预期行为

业务项目 clone 后，若 `AGENTS.md` 已由脚本生成并提交，Agent 的自动行为如下：

1. Cursor 加载 `AGENTS.md` → 读取 `## Shared Skills` 节中的路径列表
2. 根据用户意图，按 `shared-skills/README.ai.md` §3 路由规则选择对应 skill
3. 直接读取 `.cursor/shared-skills/<name>/SKILL.md` 执行

若 `AGENTS.md` 中没有 Shared Skills 声明（首次接入或遗漏提交），Agent 会按 `README.ai.md` §0 冷启动流程主动检测并提议补全配置。

### 4. 扩展更多能力（后续）

当前脚本内置键仅覆盖 **planning / LeanSpec 桥接文档 / 通过 AGENTS.md 声明共享技能路径**。若将来要为「风格 / 评审 / 单测」等增加仓库侧落地，建议：

- 在 **同一配置块** 中增加新键，并在 `shared-skills/configure-from-readme.sh` 中实现分支（保持单入口、README 仍为唯一声明处）。

---

## 项目中如何配置（AGENTS 路由）

在业务项目的 `AGENTS.md` 中声明共享 skills，建议示例：

```markdown
## Shared Skills

- `.cursor/shared-skills/lean-spec-planning-with-files-bridge/SKILL.md`（一体化双轨协作：文件规划 + LeanSpec 规格轨）
- `.cursor/shared-skills/code-styleguide-skills/styleguide-router/SKILL.md`
- `.cursor/shared-skills/eng-practices/SKILL.md`
- （推荐）`.cursor/shared-skills/unit-test-guide-skills/unit-test-router/SKILL.md`
- （可选，直达某端）`.cursor/shared-skills/unit-test-guide-skills/unit-test-android/SKILL.md` 等同目录下 `unit-test-ios`、`unit-test-wechat-miniprogram`

使用约定：
- 风格问题优先走 `styleguide-router`。
- 评审流程、评论策略、冲突处理优先走 `eng-practices`。
- 单元测试规范与补测策略优先走 `unit-test-router`；若平台已明确，可直达对应 `unit-test-*` 子 skill。
- 需要**双轨协作（规格 + 执行计划）**时走 `lean-spec-planning-with-files-bridge`（按 `SKILL.md` 执行 `bootstrap.sh`）。
```

## 日常使用建议

1. 先判断问题类型（风格 / 评审流程 / 单元测试规范 / **双轨协作（规格+规划）**）。
2. 选择对应入口（`styleguide-router`、`eng-practices`、`unit-test-router`、`lean-spec-planning-with-files-bridge`）。
3. 输出以可执行建议为主，避免泛化描述。
4. 与项目强制规范冲突时，以项目规范为准。

## 维护与升级

- 建议通过 PR 维护共享 skills，避免项目内私有分叉。
- 业务项目升级 shared-skills 时，建议在 PR 中写清：
  - 升级前后子模块提交哈希
  - 本次升级涉及的 skill 变化摘要
  - 是否需要团队迁移动作
- 每次文档更新都应写明：
  - `UpdatedAt`（精确到秒，命令行获取）
  - `LatestChange`（本次更新说明）
- 新增/删除 skill 时，同步更新：
  - `README.md`（总纲）
  - `README.human.md`（人类说明）
  - `README.ai.md`（AI 运行规则）

