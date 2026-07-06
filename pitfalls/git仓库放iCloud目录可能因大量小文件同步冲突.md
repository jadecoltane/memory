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

# 预防(结构性根治已证明行不通,接受现状)

**2026-07-06 晚试过三种结构性方案,全部失败**:`.git` 改 symlink 指向 `.git.nosync`(被 Obsidian 核心程序扫描 vault 时拍平)、`.git` 改成 gitdir 重定向的纯文本文件且数据仍放 vault 内(插件运行时一样被删除/复制出 `.git 2`)、gitdir 指向完全在 iCloud 外的 `~/.memory-git`(关闭插件时用终端操作完全稳定,但**插件一运行,连这个静态指针文件也会被删除/复制**)。三次实测共同证明:根因是**插件本身的写入方式**跟这个 iCloud 容器冲突,不是"iCloud 同步 .git 内部文件"这件事本身——所以不管把 `.git` 伪装成什么形态,只要插件在跑,就会被写坏。

**最终决定**(decisions/vault用普通git接受插件偶尔报错.md):放弃所有结构性修复,`.git` 就是最普通的真实目录,插件保持启用。用户明确接受偶尔报错,出现时用上面「解法」一节的命令手动修复。也评估过完全弃用插件、改用外部脚本定时 pull/push(实测稳定),但用户想要插件自带的"打开自动拉取、编辑自动推送"体验,权衡后放弃了脚本方案。

**以后不要再往结构性修复的方向花时间**——symlink、原地 gitdir 文件、外部 gitdir 路径三种变体都已经在插件运行时验证失败。

相关:[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]、[[decisions/vault用普通git接受插件偶尔报错]]、[[decisions/vault保留iCloud仅用nosync隔离git内部文件]]、[[decisions/记忆库vault已迁出iCloud到本地只用git同步]]、[[pitfalls/macOS文件名NFDNFC不一致会让git把整个中文笔记文件夹误判成已删除]](iCloud 同步在这个仓库上踩出的另一个具体坑)
