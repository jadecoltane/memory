---
type: pitfall
created: 2026-07-16
last-verified: 2026-07-16
---

# claude-code-action 结束后 git push 要显式带 GITHUB_TOKEN,否则凭证已被抹掉

**坑**:workflow 里 `anthropics/claude-code-action@v1` 之后再跟一步 `git push`,push 会报
`remote: Invalid username or token` / `fatal: Authentication failed`,即使外层 `actions/checkout` 用的是默认(持久化凭证)。

**原因**:claude-code-action 内部会自己跑一次 `checkout`(`persist-credentials: false`),它在
post-cleanup 阶段执行 `git config --local --unset-all http.https://github.com/.extraheader`,
把**外层 checkout 持久化的 `GITHUB_TOKEN` 凭证一起 unset 掉**。等轮到 push 步骤,本地已经没有任何认证。
失败日志里那行 `persist-credentials: false` 来自 action 内部,不是 workflow 文件——所以只盯着外层 checkout 的
`persist-credentials` 怎么调都没用(2026-07-16 前两次修复 bd91a52/a35bde8 都栽在这个思路上)。

**解法**:push 步骤不依赖任何被持久化的凭证,当场用 GITHUB_TOKEN 显式认证:
```bash
git config --unset-all http.https://github.com/.extraheader 2>/dev/null || true
git push "https://x-access-token:${GH_TOKEN}@github.com/${{ github.repository }}.git" HEAD:${{ github.ref_name }}
```
(`GH_TOKEN: ${{ github.token }}`,workflow 需 `permissions: contents: write`。)

**何时会失效**:claude-code-action 未来版本若不再 unset 外层 extraheader,这个显式认证就成了冗余但无害;
本仓库 .github/workflows/weekly-gc.yml 与 daily-workbench.yml 均已按此修好并验证 run 通过。
新建带 claude-code-action + 后续 push 的 workflow 时照抄这个 push 写法。
