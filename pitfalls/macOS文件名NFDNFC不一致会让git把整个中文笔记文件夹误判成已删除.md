---
type: pitfall
created: 2026-07-04
last-verified: 2026-07-04
---

# 症状

`git status` 显示 `notes/主体性/`、`notes/生活方式/`、`notes/社会认知/` 等整个中文命名的文件夹下的文件同时出现两条记录：一条 `D `(已暂存删除),一条 `??`(未跟踪新文件),文件名肉眼看完全一样,内容也没有真的丢失。`git ls-files` 里也找不到那个"看起来存在"的路径(`git show :path` 报 `exists on disk, but not in the index`)。

# 原因

macOS/iCloud 对包含 CJK 字符的文件名可能用 NFD(分解)形式存取,而 git 索引里记的是 NFC(预组合)形式的字节序列——两者渲染出来是同一个字符串,但作为 git 比较用的路径字节串是不同的。只要文件被 iCloud 重新同步/重写过一次(比如从另一台设备同步回来),就可能从 NFC 变成 NFD,git 就会把"旧路径"判定为删除、"新路径"判定为未跟踪新增,即使内容完全没变。
这次還叠加了 Obsidian Git 插件的 `autoSaveInterval: 10`(每 10 分钟)和 `autoBackupAfterFileChange: true`,它在后台不断自动 `git add`,把中间态也顺手暂存了,让 `.gitignore`、`index.md`、`scripts/build_memory_index.py` 同时出现"已暂存又被改动"(`MM`)的状态,进一步增加了排查难度。

# 解法

`git config core.precomposeunicode true` 让 git 在读文件系统时统一转换成 NFC 再比较,是 macOS 上的标准修复;配置后需要重新 `git add` 一次让索引里的路径与实际磁盘状态对齐(不会丢内容,只是路径编码归一)。
排查时用 `git -c core.quotepath=false status --short` 看可读文件名,再用 `git -c core.quotepath=false ls-files -s -- <目录>` 核对索引里实际有哪些路径,能快速判断是不是这个问题而不是真的丢了文件。

# 何时失效

如果 git 版本或 macOS 版本改变了默认的 unicode 处理行为,或仓库迁出 iCloud 目录后未再复现,需要重新验证。

相关:[[pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突]]
