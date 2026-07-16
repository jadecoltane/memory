---
type: decision
created: 2026-07-16
last-verified: 2026-07-16
supersedes: 每日工作台与每周GC改用Codex Action运行
---

# 每日工作台与每周 GC 继续使用 Claude OAuth 自动运行

`daily-workbench.yml` 和 `weekly-gc.yml` 使用 `anthropics/claude-code-action@v1`,通过已有仓库 Secret `CLAUDE_CODE_OAUTH_TOKEN` 运行。每日工作台保持北京时间 05:00;每周 GC 按用户 2026-07-16 的要求为周一 04:00。安静周跳过、lint、索引重建、待裁决 issue 和直接推 `main` 的行为保持不变。

原因:官方 `openai/codex-action@v1` 当前必须使用单独计费的 `OPENAI_API_KEY`,不能复用 ChatGPT/Codex 订阅或已连接的 GitHub 账号;Claude Code OAuth 则可沿用现有订阅认证。为避免只为两条个人定时任务新增 API 费用,云端定时执行器保留 Claude。Codex 仍可处理日常仓库协作和手动维护。

Claude 只负责在工作区修改文件;commit、push 和待裁决 issue 由后续 GitHub Actions 步骤机械执行。待裁决 issue 使用日期标题去重,自动重跑不会重复通知。

失效条件:Codex Action 后续支持复用 Codex 订阅/GitHub 集成且用户决定再次迁移,或 Claude OAuth 不再可用。

相关:`.github/workflows/daily-workbench.yml`、`.github/workflows/weekly-gc.yml`、`.github/workflows/rerun-on-failure.yml`
