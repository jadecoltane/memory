---
type: decision
created: 2026-07-06
last-verified: 2026-07-06
supersedes: 记忆库vault已迁出iCloud到本地只用git同步
---

# 结论

vault 最终留在原 iCloud 路径 `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/memory`,没有迁出本地。用 `.git` → `.git.nosync` 改名 + 同名 symlink 的方式,把 git 内部数据排除出 iCloud 同步(iCloud 认 `.nosync` 后缀约定,完全不碰这个文件夹);`.gitignore` 加了 `.git.nosync/` 防止被 git 自己当成未追踪内容。

**⚠️ 当晚内部已修正一次**:最初判断连 Obsidian 的「Git」社区插件也一起关掉,后来发现这步过头了——原始冲突的根因是"iCloud 同步机制去碰 `.git` 内部文件",不是"插件自动提交"本身;`.git.nosync` 已经让 iCloud 完全看不到 `.git` 内部文件,所以插件在 **Mac 上**自动 commit/push/pull 现在是安全的,已重新在 `community-plugins.json` 里启用,沿用原有的 `autoSaveInterval: 10`(分钟)+ `autoBackupAfterFileChange: true` + `autoPullOnBoot: true` 配置,不需要用户手动跑 git。

# 为什么

- 当晚先执行了 decisions/记忆库vault已迁出iCloud到本地只用git同步.md 的迁出方案(整体复制到 `~/Documents/Obsidian/memory`),但会话中途发现本地那份副本消失、iCloud 路径的仓库工作区又回退到了旧版本——推测是用户最初那次卡在"正在准备拷贝"的 Finder 操作,其实并未真正卡死,而是在后台持续运行,期间悄悄完成并覆盖了本地新副本。核对确认 GitHub 上的 `jadecoltrane/memory` 完整无损(用 `git reset --hard origin/main` 把 iCloud 副本的工作区拉回一致状态,没有任何独家未推送内容丢失)
- 出于这次意外,用户改变主意:与其整体迁出本地、还要单独解决手机端 vault 归属问题,不如直接用 pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突.md 里早就评估过的"方案 1"根治——成本更低(不用换手机端 App、不用付费),且直接对症"iCloud 和 git 内部文件互相干扰"这个根因
- **用户不接受"没有自动提交"**——追问后确认真正在意的是"确保 GitHub 备份不滞后",不是设备间笔记一致性(那本来就是 iCloud 在管,跟 git 无关)。既然 nosync 已经根治了根因,没必要为了防一个已经不存在的风险而牺牲自动化

# 影响

- **Mac 端**:插件自动 commit/push/pull 照常工作,`.git.nosync` 不受 iCloud 干扰
- **手机端**:`community-plugins.json` 是共享文件,插件在手机上也会显示为"已启用",但手机的 vault 里根本没有 `.git`(nosync 决定了它永远不会同步过去),插件会报"不是有效的 git 仓库"之类的提示——**这是预期内的无害报错**,不会导致数据损坏,忽略掉即可
- 手机如果也想要自动提交,需要给手机的 vault 单独建一个独立的本地 `.git`(比如用 a-Shell 之类的终端 App clone 一份,或者试试插件自带的"Clone an existing remote repo"命令是否能在已有文件的 vault 里直接用)——这会是一个和 Mac 完全独立、各自 push/pull 同一个 GitHub 远程的仓库,不再有共享文件系统层面互相干扰的风险,冲突时按普通 git 多设备协作处理(pull 前先 push,有冲突走正常 merge)即可

相关:[[pitfalls/git仓库放iCloud目录可能因大量小文件同步冲突]]、[[decisions/记忆库vault已迁出iCloud到本地只用git同步]]、[[decisions/数据层保持Markdown加Git但Obsidian插件放开用]]
