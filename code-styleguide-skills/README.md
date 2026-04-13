<!--
UpdatedAt: 2026-04-13 09:46:41 +0800
LatestChange: 增加顶层入口 skill 与 `init` 子命令说明，统一为单 skill + 子命令方式。
-->

## 这是什么

本目录是一组按语言拆分的代码风格技能，统一由顶层 skill `code-styleguide-skills` 作为入口，再委托 `styleguide-router` 进行识别、分发与输出格式控制。

- 总纲入口：`code-styleguide-skills`
- 路由入口：`styleguide-router`
- 子技能：`styleguide-<language>`
- 目标：在 Claude / Codex 中提供可执行、可落地的风格建议

## 推荐安装方式

本技能组以 skills.sh 生态发布。当前仓库对应安装命令如下：

```bash
npx skills add sunzhk/shared-skills --skill code-styleguide-skills
```

当前版本不再推荐 submodule、subtree 或直接拷贝分发。

## 使用方式

1. 初始化项目说明时，使用 `/code-styleguide-skills init`。
2. 处理风格问题时，从 `code-styleguide-skills` 进入。
3. 顶层 skill 会把默认请求委托给 `styleguide-router`。
4. 再由 router 根据语言、文件类型或问题描述分发到具体子技能。

## 冲突优先级

1. 项目明确约定
2. shared-skills 中的风格规则
3. 官方语言规范
4. 个人偏好
