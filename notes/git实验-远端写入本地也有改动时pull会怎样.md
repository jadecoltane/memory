---
type: note
created: 2026-07-22
source: 实验用，可以删掉
checkable: false
---

# 这是 Claude 从远端写入的测试文件

你在本地改了某条笔记，我在远端新建了这个文件。
你 pull 之后，两件事都应该保留：
- 你的本地修改出现在 staged changes 或 working changes
- 这个文件出现在你的 vault 里

如果出现冲突（你和我改的是同一个文件），Git 会在文件里插入冲突标记，让你手动选哪个版本。
