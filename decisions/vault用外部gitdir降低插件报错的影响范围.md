---
type: decision
created: 2026-07-06
last-verified: 2026-07-06
supersedes: vault用普通git接受插件偶尔报错
---

# 结论

vault 留在 iCloud 原路径,但 git 数据本体搬到 `/Users/peiyaohuang/.memory-git`(完全在 iCloud 之外),vault 根目录的 `.git` 只是一个一行纯文本指针文件:

```
gitdir: /Users/peiyaohuang/.memory-git
```

`~/.memory-git/config` 里额外设了 `core.worktree` 指回 vault 路径,让 git 知道工作区在哪。Obsidian 的「Git」社区插件保持启用。

# 为什么

- 已经证实(见 pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突.md):不管 `.git` 是普通目录、symlink 还是原地 gitdir 文件,插件运行时都有同等概率被写坏(报错、或衍生 `.git 2` 冲突副本)——**报错概率这件事上,普通目录方案和外部 gitdir 方案没有差别**
- 但**出问题时的影响范围完全不同**:
  - 普通目录方案:iCloud 全程碰得到整个 `.git`(几千个内部文件),出问题时不确定具体是索引、还是更深层的 object/ref 数据,历史上见过的是 `.git/index` 为空,理论上不能完全排除更深层的损坏
  - 外部 gitdir 方案:iCloud 只碰得到 vault 里那一行指针文件,**真实历史数据在 `~/.memory-git` 完全不暴露给 iCloud**,出问题只可能是这一行文本没了或变成 `.git 2`,修复方式是重新写一行文本,比 `rm .git/index && git reset` 还简单,而且不用担心历史数据本身被波及
- 当晚实测验证:关闭插件时,这个指针文件能稳定存在(60 秒静置、git pull/status/log 都不受影响);打开插件后大约 10-20 秒内会被复制成 `.git 2`,和普通目录方案的报错节奏差不多——修复后 `~/.memory-git` 用 `git fsck` 验证历史完全没有损坏

# 影响

- 遇到报错时的修复命令变成:
  ```bash
  cd "vault路径"
  rm -f ".git 2"   # 如果有冲突副本残留,先清掉
  printf 'gitdir: /Users/peiyaohuang/.memory-git\n' > .git
  git status   # 确认恢复
  ```
- `~/.memory-git` 本身不需要额外备份意识——它只是本地缓存,真身仍在 GitHub(`jadecoltrane/memory`),这个本地路径丢了大不了重新 clone
- `.gitignore` 不需要为这个方案加任何规则(不像 nosync 方案还要排除 `.git.nosync/`),因为数据完全不在 vault 目录树内,git 自己也看不到它

相关:[[pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突]]、[[decisions/vault用普通git接受插件偶尔报错]]、[[decisions/vault保留iCloud仅用nosync隔离git内部文件]]、[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]
