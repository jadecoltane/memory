---
type: decision
created: 2026-07-06
last-verified: 2026-07-06
supersedes: vault保留iCloud仅用nosync隔离git内部文件
---

# 结论

vault 留在 iCloud 原路径,`.git` 就是最普通的真实目录,不做任何 symlink/gitdir 重定向/nosync 排除。Obsidian 的「Git」社区插件保持启用,自动 commit/push/pull 照常跑。用户明确接受:插件偶尔会把 `.git` 写坏(报错、或衍生出 `.git 2` 这类冲突副本),出现时用 pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突.md 里记录的方法手动修复。这本质上是回到 2026-07-06 当晚最早、也是最初就成立的那个选择("暂不改动架构"),中间那一整晚的迁出本地、nosync symlink、nosync gitdir 文件、gitdir 指外部路径这几轮尝试,全部被证明要么行不通、要么解决不了真正在意的问题。

# 为什么(整晚试错的结论)

当晚依次测试过的方案和各自的失败原因,记下来避免以后重新踩一遍:

1. **整体迁出 iCloud 到本地**(decisions/记忆库vault已迁出iCloud到本地只用git同步.md):技术上可行,但会话中途一次仍在后台运行的 Finder 拷贝任务悄悄覆盖了本地副本,且手机端会完全失去笔记同步(不止 git,整个 iCloud 同步都没了)——代价超过收益
2. **`.git` 改 symlink 指向 `.git.nosync`**:Obsidian 核心程序(不一定是插件)在扫描 vault 时不能正确处理这个 symlink,会把它"拍平"变回真实目录,`.git.nosync` 原始数据被清空
3. **`.git` 改成 gitdir 重定向的纯文本文件**(`gitdir: ./.git.nosync`),数据仍放 vault 内:插件运行时一样会把这个文件删除或复制出 `.git 2`
4. **gitdir 重定向指向完全在 iCloud 外的路径**(`~/.memory-git`,vault 内只留一个不该再被改写的静态指针文件):**关闭插件、纯终端操作时完全稳定**(静置 60 秒无恙,pull/status/log 都不会触发问题);但**插件运行期间,这个静态指针文件依然会被删除/复制**——证明问题不是"iCloud 同步 .git 内容"本身,而是插件的写入方式(可能是类似"写临时文件再 rename 覆盖"的操作模式)跟这个 iCloud 容器的文件层冲突,不管 `.git` 是目录、symlink 还是普通文件都一样会中招
5. **改用外部 launchd 定时脚本、彻底不用插件**:实测完全稳定,但用户明确说想要插件自带的"打开就自动拉取、编辑就自动推送"体验,不想要脚本这种看不见反馈的方案——权衡后接受方案 1 无法验证过的报错风险,继续用插件

# 影响

- 以后再遇到 `.git` 相关报错(index 为空、not a valid repository 等),直接按 pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突.md 的解法处理,不用重新怀疑架构或重新尝试 nosync 之类的结构性修复——已经验证过那条路走不通
- 不要再往这个方向花时间:symlink、gitdir 重定向文件、外部 gitdir 路径,三种变体都已经在插件运行时验证失败

相关:[[pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突]]、[[decisions/vault保留iCloud仅用nosync隔离git内部文件]]、[[decisions/记忆库vault已迁出iCloud到本地只用git同步]]、[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]
