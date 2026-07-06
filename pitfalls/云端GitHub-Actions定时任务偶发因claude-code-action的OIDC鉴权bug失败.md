---
type: pitfall
created: 2026-07-06
last-verified: 2026-07-06
---

# 症状

`weekly-gc.yml` 2026-07-06 第一次按 `schedule` 定时触发就失败(32 秒内结束),日志显示卡在鉴权阶段:

```
Exchanging OIDC token for app token...
App token exchange failed: 401 Unauthorized - User does not have write access on this repository
```

同一个仓库的 `daily-workbench.yml` 用同一个 `anthropics/claude-code-action@v1`、同样是 `schedule` 触发,过去三天(07-03~07-05)都成功;手动 `workflow_dispatch` 触发 `weekly-gc.yml` 也成功过一次(07-04)。只有这次定时触发失败。

# 原因

这不是仓库自己配置的问题,是 `anthropics/claude-code-action` 上游一个已知未修复的 bug:action 用 GitHub OIDC token 换取一个有仓库写权限的 App token,这个换取动作在 `schedule` 事件触发时会偶发性地失败,报"当前用户没有写权限",即使触发者(actor)明明是仓库所有者。GitHub 官方 issue 跟踪到这个问题(标了 `bug`/`p1`/`area:permissions`,截至目前没有官方修复):

- https://github.com/anthropics/claude-code-action/issues/814 (「Claude doesn't work in cron jobs」,同样是 schedule 成功率不稳定、workflow_dispatch 必现成功)
- https://github.com/anthropics/claude-code-action/issues/270 (同样的 401 报错)
- https://github.com/anthropics/claude-code-action/issues/1017 (同一鉴权链路的另一种触发方式,附了一个社区绕过方案)

`daily-workbench.yml` 目前运气好、三天都没撞上,不代表它对这个 bug免疫——本质是同一条鉴权链路,随时可能在某次定时触发上也失败。

# 解法

**临时**:定时触发失败时,手动 `workflow_dispatch` 重跑一次就能过(这个鉴权链路手动触发目前没失败过)。

**根治(社区方案,未验证是否需要,目前没做)**:issue #1017 里给出的绕过办法是不再依赖 action 自带的 OIDC→App token 兑换,改成自己建一个 GitHub App、用 `actions/create-github-app-token@v2` 提前换好 token,再通过 `github_token` 输入显式传给 `anthropics/claude-code-action@v1`,同时去掉 workflow 里的 `id-token: write` 权限。这需要用户在 GitHub 上新建一个 GitHub App、生成私钥、装到这个仓库、把 `app-id`/私钥存成两个新的仓库 secret——是一次性但不算小的配置工作,目前判断"定时任务偶发失败、手动重跑一次就好"这个代价还能接受,没有主动做这个改造;如果未来失败频率明显升高、或用户不想再手动兜底,再考虑升级成这个方案。

以后遇到 `daily-workbench.yml`/`weekly-gc.yml` 任何一个定时任务显示 Failure、日志卡在"Exchanging OIDC token for app token"这一步,直接判定是这个已知上游 bug,不用在仓库自己的 workflow 配置或 CLAUDE.md 里找原因——先手动 workflow_dispatch 重跑,能过就说明只是这次运气不好。
