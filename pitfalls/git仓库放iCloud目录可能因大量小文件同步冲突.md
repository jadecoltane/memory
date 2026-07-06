---
type: pitfall
created: 2026-07-03
last-verified: 2026-07-06
---

# 症状

git 仓库 clone 进 iCloud 云盘目录(如 Obsidian 的 iCloud vault)后,操作变慢、偶发文件冲突副本。

**2026-07-06 手机端具体报错**:Obsidian Git 插件(isomorphic-git)在手机上操作工作台笔记时连续报 `An internal error caused this command to fail...Index file is empty (.git/index)`,紧接着几次 `Request failed. The request timed out`(后者是索引坏掉后续操作连锁失败,不是独立故障)。

# 原因

`.git` 目录内含大量小文件,iCloud 同步机制对此不友好,可能与 git 写入竞争。

**2026-07-06 复盘澄清**:最初以为触发条件是"两台设备同时编辑",但当天实际时间线是——AI 在云端(远程会话)直接 push 了新提交到 GitHub,用户随后打开手机 Obsidian,手机端全程没有任何人为编辑动作,依然触发了报错。更可能的机制是:iCloud 为了省手机存储空间,对不常访问的文件会做"占位"(文件可见但内容尚未真正下载到本地,需要用到时才现拉),`.git/index`、`.git/objects` 这类内部文件平时用不到,很容易长期停留在"占位未下载"状态。一旦在这些文件还没真正落地时,Git 插件被触发去 pull 远端新提交(比如 AI 刚 push 完、打开 App 自动 pull),读到的可能是尚未下载完成的占位内容,于是报 index 为空。也就是说触发条件是"本地 `.git` 文件未完整下载 + 此时发起了 git 操作",不一定需要两台设备同时写。

# 解法(遇到 index 损坏时)

在能跑终端的设备(Mac)上:

```bash
cd 你的vault路径
rm .git/index
git reset      # 用当前 HEAD 重建索引,不动工作区文件
git status     # 确认恢复正常
```

真实数据不受影响——vault 的真身在 GitHub(`jadecoltrane/memory`),`.git/index` 只是本地暂存区状态,坏了顶多丢一点还没提交推送的改动。

# 预防(已根治,Mac 端)

**2026-07-06 晚最终方案**:vault 留在 iCloud(中途短暂尝试整体迁出本地,因一次 Finder 后台拷贝任务在会话期间静默完成、覆盖了本地副本而放弃,过程见 decisions/记忆库vault已迁出iCloud到本地只用git同步.md 与 decisions/vault保留iCloud仅用nosync隔离git内部文件.md),改用**方案 1**根治:`.git` 改名 `.git.nosync` + 建同名 symlink `.git -> .git.nosync`,iCloud 认这个后缀约定,完全不碰 `.git.nosync/` 里的内容,普通 git 命令通过 symlink 照常工作。`.gitignore` 里加了 `.git.nosync/` 防止被 git 自己误当成未追踪内容纳入。

Obsidian 的「Git」社区插件**保持启用**——nosync 已经让 iCloud 完全看不到 `.git` 内部文件,插件在 Mac 上自动 commit/push/pull 不会再和 iCloud 打架,不需要为了防已经根治的风险牺牲自动化。手机端由于 `community-plugins.json` 共享,插件在手机上也会显示启用,但手机 vault 里没有 `.git`(nosync 决定它永远不会同步过去),插件会报"不是有效仓库"之类的无害提示;手机如果也想自动提交,需要单独给手机建一个独立的本地 `.git`(各自 push/pull 同一个 GitHub 远程,属于正常的 git 多设备协作,不再有共享文件系统层面的冲突风险)。

相关:[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]、[[decisions/记忆库vault已迁出iCloud到本地只用git同步]]、[[pitfalls/macOS文件名NFDNFC不一致会让git把整个中文笔记文件夹误判成已删除]](iCloud 同步在这个仓库上踩出的另一个具体坑)
