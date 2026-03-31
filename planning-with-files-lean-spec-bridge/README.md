<!--
UpdatedAt: 2026-03-31 14:35:34
LatestChange: 协作文档与本目录同路径；README 内引用从 ../ 改为本目录文件名。
-->

# planning-with-files-lean-spec-bridge

在 **planning-with-files-ext** 与 **LeanSpec** 之间做流程编排：由 Cursor 技能触发时代理按清单完成 Spec ↔ `doc/plans/` 桥接；可选脚本把协作文档复制进仓库 `doc/plans/COORDINATION_LEANSPEC.md`。

## 安装（Cursor 技能）

- **个人全局**：将本目录复制或软链到 `~/.cursor/skills/planning-with-files-lean-spec-bridge/`。
- **单仓库**：复制或软链到该仓库的 `.cursor/skills/planning-with-files-lean-spec-bridge/`。

## 脚本（人类或代理执行）

**多项目推荐**：在业务项目 README 配置块中设 `lean_spec_bridge_doc=1`，并执行 `bash .cursor/skills-shared/configure-from-readme.sh`（见 `README.human.md`）。

**单独执行**：

```bash
bash /path/to/planning-with-files-lean-spec-bridge/bootstrap-bridge.sh /path/to/target/repo
```

权威协作文档与本技能同目录：`planning-with-files-and-lean-spec-collaboration.md`。
