---
type: decision
created: 2026-07-06
last-verified: 2026-07-06
supersedes: vault用外部gitdir降低插件报错的影响范围
---

# 结论

vault 留在 iCloud 原路径,`.git` 保持普通目录、原名原地不动,只是打上一个 iCloud 认的扩展属性标记:

```bash
xattr -w com.apple.clouddocs.not-sync 1 .git
```

不改名、不建 symlink、不做 gitdir 重定向,数据也不搬去 vault 外部。Obsidian 的「Git」社区插件保持启用。

# 为什么

- 来源:用户分享了博主"麻辣眼貘 MalayanTapir"的实操帖,用的就是这个 `com.apple.clouddocs.not-sync` xattr 标记法,而不是当晚一直在试的"改名 + symlink/gitdir 重定向"那条路
- **实测效果明显更好**:插件运行下,`.git` 目录静置观察近 4 分钟(此前 symlink、原地 gitdir 文件、外部 gitdir 路径三种方案全部在 10-20 秒内就被写坏),期间 `git status`/`git log` 全程正常,xattr 标记本身也没被清除
- 推测原因:这个标记直接作用于 iCloud 的同步守护进程(CloudDocs daemon)层面,而不是靠改变文件/目录的呈现形式(名字、是否是 symlink、是否是普通文件)——之前三种方案的共同点是都改变了 `.git` 在文件系统里的"长相",而 Obsidian 插件(isomorphic-git 实现)对这些非标准形态处理得不好,才引发反复写坏;这次 `.git` 从插件角度看完全是个正常目录,插件不需要用任何特殊逻辑处理它,不稳定的根源被绕开了

# 影响

- 博主帖子里提到:如果有多台 Mac,这个 xattr 标记要在每台电脑上分别执行——它是本地文件系统属性,不会跟着 iCloud 同步到别的设备
- 帖子里也提到配套的 `.gitignore` 精简建议(排除 `.obsidian/workspace.json`、`.obsidian/cache/`、iCloud 冲突副本命名模式等高频噪声文件),值得后续单独评估是否要加
- **还没做长期验证**——目前只观察了几分钟,真正的验证要靠接下来几天的正常使用。如果之后仍然出现报错,回退方案是 decisions/vault用外部gitdir降低插件报错的影响范围.md(数据搬到 `~/.memory-git`,已经验证可行,只是指针文件本身在插件运行时也会被写坏)或 decisions/vault用普通git接受插件偶尔报错.md
- 手机端依然不指望能用插件做 git 操作(不管哪种方案,`community-plugins.json` 共享导致手机上插件也会显示启用,但手机本来就不适合参与 git 层面的操作),只作为笔记阅读/编辑端,这点在几个方案里是一致的

相关:[[pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突]]、[[decisions/vault用外部gitdir降低插件报错的影响范围]]、[[decisions/vault用普通git接受插件偶尔报错]]、[[decisions/vault保留iCloud仅用nosync隔离git内部文件]]、[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]
