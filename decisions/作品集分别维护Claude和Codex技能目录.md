---
type: decision
created: 2026-07-16
last-verified: 2026-07-16
---

# 作品集分别维护 Claude 和 Codex 技能目录

`jadecoltrane/portfolio` 中的 Claude 技能继续放在 `.claude/skills/`，Codex 原生技能放在 `.agents/skills/`。两套目录服务于不同的发现机制和工具语义，不再把 Claude 文件简单复制后当作已经兼容。

Codex 版技能遵循这些约定：

- `SKILL.md` frontmatter 只保留 `name` 和 `description`；名称与目录一致。
- 使用 Codex 实际能力，例如 `update_plan`、collaboration 多智能体工具、`apply_patch` 和可用的 web/browser 工具；不写不存在的 `Task`、`TodoWrite`、`WebFetch`、显式 `Skill` 工具或 Claude 插件变量。
- 只提交被技能直接引用的脚本、模板和参考文件；资源缺失时重写工作流，不保留虚假的能力声明。
- 在 Codex 中选择本地 `portfolio` 项目时自动发现 `.agents/skills/`；仅远程操作 GitHub 时需要按需读取，不能假装远程仓库已经成为当前工作目录。

2026-07-16 已将 20 个技能迁移并验证，提交为 `jadecoltrane/portfolio@4bd3ebb`。

失效条件：Codex 后续原生支持把远程仓库挂载为项目并自动发现远程技能，或用户决定只维护其中一套技能。
