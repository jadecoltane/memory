---
type: pitfall
created: 2026-07-03
last-verified: 2026-07-06
---

# 症状

git 仓库 clone 进 iCloud 云盘目录(如 Obsidian 的 iCloud vault)后,操作变慢、偶发文件冲突副本。

**2026-07-06 手机端具体报错**:Obsidian Git 插件(isomorphic-git)在手机上操作工作台笔记时连续报 `An internal error caused this command to fail...Index file is empty (.git/index)`,紧接着几次 `Request failed. The request timed out`(后者是索引坏掉后续操作连锁失败,不是独立故障)。

# 原因

`.git` 目录内含大量小文件,iCloud 同步机制对此不友好,可能与 git 写入竞争——具体表现之一就是 `.git/index` 在两台设备同时读写或 iCloud 同步半路打断时被写空/损坏。

# 解法(遇到 index 损坏时)

在能跑终端的设备(Mac)上:

```bash
cd 你的vault路径
rm .git/index
git reset      # 用当前 HEAD 重建索引,不动工作区文件
git status     # 确认恢复正常
```

真实数据不受影响——vault 的真身在 GitHub(`jadecoltrane/memory`),`.git/index` 只是本地暂存区状态,坏了顶多丢一点还没提交推送的改动。

# 预防(降低复发概率,而非根治)

2026-07-06 用户明确选择**暂不改动架构**(继续用 iCloud 同步 vault + 两台设备都装 Obsidian Git 插件),原因是备选方案(把 `.git` 用 `.nosync` 排除出 iCloud 同步、仓库搬出 iCloud 改用 Working Copy 桥接、换 Obsidian Sync 付费同步)都要么手机端需要额外用终端 App(如 a-Shell)重新认领 git 历史、要么要多装一个 App/掏订阅费,复杂度/成本超过当前问题的实际烦扰程度。日常靠这两条习惯把风险压低:

- 避免两台设备在同一小段时间内都对 vault 做写入/git 操作,给 iCloud 同步留出窗口
- 尽快 commit + push,减少本地未提交改动的暴露时间,即使 index 又坏,损失也小

**如果以后想彻底根治**,评估过的方案在这里,不用重新分析:
1. `.git` 改名 `.git.nosync` + 建 symlink,让 iCloud 完全不碰 git 内部文件,手机端需要用 a-Shell 之类的终端 App 跑 `git init && git remote add origin ... && git fetch && git reset origin/main` 重新认领历史(不会覆盖已同步的笔记内容)——Mac 端简单,手机端这步没有实测验证过
2. 仓库整体搬出 iCloud,手机端换 Working Copy 桥接 Obsidian 移动版
3. 换用 Obsidian Sync(付费,约 4 美元/月)替代 iCloud 做笔记同步,git 只留作 GitHub 备份/自动化通道

相关:[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]、[[pitfalls/macOS文件名NFDNFC不一致会让git把整个中文笔记文件夹误判成已删除]](iCloud 同步在这个仓库上踩出的另一个具体坑)
