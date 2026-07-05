---
type: pitfall
created: 2026-07-05
last-verified: 2026-07-05
---

# 症状

打开 工作台.md 后点进一篇笔记(二级页),再返回工作台,有时(不是每次)页面展示不正常;手机端比电脑端更容易复现。

# 原因

工作台顶部 dataviewjs 代码块里的实时时钟用的是裸 `setInterval(tick, 15000)`。Dataview/Obsidian 在你切换到别的笔记再切回来时,不保证会调用上一次渲染留下的清理逻辑——裸 `setInterval` 不会被自动清掉,于是每次"进二级页再返回"都会在后台多叠加一个计时器,持续对着已经被替换掉的旧 DOM 节点写值。计时器越攒越多,尤其手机端内存更紧张,拖累到一定程度就会让页面重新渲染时出问题。这是 Dataview 官方文档明确点名的坑:dataviewjs 里任何计时器都应该用 `dv.component.registerInterval(setInterval(...))`,而不是裸 `setInterval`。

# 解法

改成 `dv.component.registerInterval(setInterval(tick, 15000))`——计时器生命周期绑定到这次渲染的组件上,组件卸载(比如切换笔记)时会被自动清掉,不再累积。已在 工作台.md 里改掉。

以后工作台里如果要加新的 `setInterval`/`setTimeout` 循环,一律走 `dv.component.registerInterval(...)`,不要写裸的。

另外手机上 🌱🕸️➕ 等统计卡胶囊一排放不下 5 个的问题,是单纯的窄屏溢出布局问题,跟这个坑无关,已经在 `.obsidian/snippets/workbench.css` 里把 `.wb-cards` 改成横向可滑动(`overflow-x: auto` + 隐藏滚动条 + `scroll-snap`)解决,不是本条要修的渲染 bug。
