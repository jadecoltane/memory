---
type: pitfall
created: 2026-07-06
last-verified: 2026-07-06
---

# 坑

2026-07-06 当天早些时候的每周 GC(`53fec7e`/`e4e68fb`/`b8433f2`/`9bda180`)往 `RESOLVER.md`、`SUMMARY.md`、`index.md` 推了新增内容。几个小时后本地 Obsidian vault 的自动 backup 提交(`47092b1`,parent 正确指向了最新的 `9bda180`)却把这三个文件里刚推上去的新增内容覆盖回了旧版本——`RESOLVER.md` 的 pitfalls 准入门槛段落、`SUMMARY.md` 的"工作台开发实现现状"整节、`index.md` 里 `profile/健康` 和 OIDC 那条 pitfall 全部消失了,同时该提交还新增了一条指向从未创建过的文件的死链(`lint_memory.py` 当场报错)。

具体的 git/Obsidian 同步机制没有完全查清——commit parent 显示 push 前确实先同步到了最新提交,但提交内容却是本地磁盘上落后的文件状态。可观察的规律是:如果本地 vault 长时间没在 Obsidian 里重新打开/拉取,同时远端(GC、CI、其他会话)在这期间对同一批文件做了增量修改,下一次本地 backup 提交有较高风险把这些增量覆盖回本地磁盘上的旧内容,且不会以显式 git 冲突的形式出现,需要事后靠 lint(断链检测)或人工比对才能发现。

# 应对

GC 或任何自动化流程更新 `RESOLVER.md`/`SUMMARY.md`/`index.md` 等基础设施文件后,如果短时间内又出现一次 vault backup 提交,应该重新 diff 一遍确认没有回退;`lint_memory.py` 的断链检测是目前唯一的机械捕获手段,GC 例行跑一遍能兜底这类问题,但无法兜底"内容被静默削减但没产生断链"的情况(比如这次 `RESOLVER.md`/`SUMMARY.md` 少的那两段,本身不含双链,lint 查不出来,是靠对比 git diff 才发现的)。

# 适用范围/边界

- 仅在本地 vault 长时间未与远端同步、同时远端有其他来源(GC/CI/其他会话)持续写入的场景下才会触发;正常"打开 Obsidian 就先拉取"的习惯下应该不会出现
- 和 [[pitfalls/工作台没更新先检查本地是否拉取了远端而不是怀疑云端日更挂了]] 是同一根因(本地 vault 未及时拉取远端)的另一种表现:那条是"读"方向的影响(本地看到的内容旧),这条是"写"方向的影响(本地旧内容反向覆盖远端)
