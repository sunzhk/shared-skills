<!--
UpdatedAt: 2026-03-31 16:01:57
LatestChange: planning-with-files-lean-spec-bridge 条目注明标准术语「双轨协作」。
-->

# shared-skills 总纲

<!-- shared-skills-config
# 以下为仓库级默认：configure-from-readme.sh 会先应用本块，再用业务项目 README 中同名键覆盖。业务可整段不写 cursor_skill_links。
planning_with_files_ext=1
planning_with_files_ext_no_install_pwfz=0
lean_spec_bridge_doc=1
cursor_skill_links=planning-with-files-ext,planning-with-files-lean-spec-bridge,eng-practices,code-styleguide-skills,unit-test-guide-skills
-->

本目录用于存放可跨项目复用的 Cursor Skills。  
为避免“同一文档同时服务人和 AI”导致的冗长与歧义，采用三文档结构：

- `README.md`（当前文件）：总纲与导航。
- `README.human.md`：面向人的说明（用途、接入、使用、维护）。
- `README.ai.md`：面向 AI 的运行规则（配置、触发、路由、优先级、输出约束）。

## 阅读顺序

### 人类开发者

1. 先读 `README.md`（总览）
2. 再读 `README.human.md`（落地接入与日常用法）
3. 需要深入某个技能时，再进入对应目录（如 `eng-practices/`）

### AI/Agent

1. 先读 `README.md`（目录与边界）
2. 再读 `README.ai.md`（触发与执行规则）
3. 根据路由读取具体 `SKILL.md`

## 快速链接

- 人类使用手册（含完整 submodule 接入与更新）：`README.human.md`
- **业务项目 README 一键落地**：`configure-from-readme.sh`（约定见 `README.human.md`「README 驱动一键配置」）
  - 执行后自动写入业务项目 `AGENTS.md`，Agent 冷启动时即可路由，无需额外手工配置
- AI 运行规则（触发、路由、优先级、**冷启动自动配置流程**）：`README.ai.md`
- 风格技能说明：`code-styleguide-skills/README.md`
- 评审技能入口：`eng-practices/SKILL.md`
- 单元测试规范（主控 router）：`unit-test-guide-skills/unit-test-router/SKILL.md`（说明见 `unit-test-guide-skills/README.md`）
- 文件规划落地（bootstrap / hooks）：`planning-with-files-ext/SKILL.md`（包内说明见 `planning-with-files-ext/README.md`）

## 当前技能目录

- `code-styleguide-skills/`
  - 入口：`styleguide-router`
  - 说明：`code-styleguide-skills/README.md`
- `eng-practices/`
  - 入口：`eng-practices/SKILL.md`
  - 参考：`eng-practices/reference-code-review.md`
- `unit-test-guide-skills/`
  - 入口：`unit-test-router/SKILL.md`；子技能：`unit-test-android`、`unit-test-ios`、`unit-test-wechat-miniprogram`
  - 包说明：`unit-test-guide-skills/README.md`
  - 官方基线：Android Developers / Apple Developer / 微信开放文档（各子技能内有链接清单）
- `planning-with-files-ext/`
  - 入口：`planning-with-files-ext/SKILL.md`
  - 包说明：`planning-with-files-ext/README.md`（含 `bootstrap.sh` 一键写入 `.cursor` 与 `doc/plans`）
- `planning-with-files-lean-spec-bridge/`
  - 入口：`planning-with-files-lean-spec-bridge/SKILL.md`（**双轨协作**：`specs/` ↔ `doc/plans` 编排）
  - 脚本：`planning-with-files-lean-spec-bridge/bootstrap-bridge.sh`
- `configure-from-readme.sh`（仓库根）：先读**本文档**内 `<!-- shared-skills-config -->` 默认块（含预置 `cursor_skill_links`），再合并业务项目 `README.md` 中的同名块（可省略）；自动执行 bootstrap、**解析并校验**技能路径、**写入业务项目 `AGENTS.md`**（路径指向 `.cursor/shared-skills/...`）

## 路由说明

总纲不重复维护大表格映射，统一以 `README.ai.md` 为准。  
如果是人类读者需要快速判断，可先看 `README.human.md` 的“日常使用建议”章节。

## 目录约定

- 每个 skill 至少包含：`<skill-name>/SKILL.md`
- 可选文件：
  - `reference-*.md`（参考索引/深读）
  - `README.md`（该 skill 内部说明）
  - `scripts/`（确有自动化需求时才添加）
