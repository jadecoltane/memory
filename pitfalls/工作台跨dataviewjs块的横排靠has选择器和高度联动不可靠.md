---
type: pitfall
created: 2026-07-07
last-verified: 2026-07-07
---

# 坑

工作台.md 里"名画横幅"和"随机重逢"曾经是两个独立的顶层 dataviewjs 代码块,想让它们横排成一行(2:1),用的是 `.markdown-preview-sizer > *:has(.wb-daily-painting)` / `:has(.wb-reunion)` 分配 flex-basis,再配一段 JS(ResizeObserver 实时量画作高度,写成随机重逢的 max-height)做跨块高度同步。

这套组合在实测中反复复现"有时候并排、有时候两个都退化成各占一整行堆叠"——尤其是点了"随机重逢"的换一篇按钮(`container.innerHTML = ""` 整个重建 DOM)之后最容易触发。根因是两个块各自是独立渲染的 dataviewjs 实例,渲染/重排时机互不保证同步,:has() 选择器本身没问题,但 Obsidian 对渲染完成的时序没有跨块保证,一旦错开就整体退化。

**同一次调试还带出第二个连坑**:试图把这套 flex 网格也镜像一份给 `.cm-sizer`(Live Preview/编辑视图的容器),想让编辑模式也有卡片网格效果——结果把整个文档的原始文本渲染搞坏了(一整段文字被拆成一字一行的乱码排版)。原因:`.cm-sizer` 的直接子元素是 CodeMirror 按源文件逐行拆出的 `.cm-line`(不是渲染后的整块 div),即使确认根元素带 `.is-live-preview` 类也一样——只要某个块当前显示原始文本(光标停在里面,或 widget 还没渲染完),那些行仍然是 `.cm-sizer` 的直接子元素。对整个 `.cm-sizer` 做 `display:flex` + `flex-basis:100%` 会让容器自身失去确定宽度,退化成逐字换行。

**最终解法不是修 CSS,是去掉横排本身**:两张卡改回都用最外层通用规则 `flex: 1 1 100%`,各自占一整行,配套的 `:has()` 高度联动规则和 JS 里的 ResizeObserver 一并删除。用 devtools(`cmd+alt+i`,Elements 面板 + Cmd+F 搜索类名)实测定位,直接改代码复现不了才敢下结论。

# 下次遇到类似情况怎么办

- 工作台.md 里如果又想让两个独立的顶层 dataviewjs 块横排对齐(宽度或高度),先假设这套组合大概率不稳定,不要直接照抄这次撤掉的写法
- 如果确实需要跨块布局,块与块之间不要用"各自独立渲染 + CSS/JS 事后对齐"的思路,考虑合并成同一个 dataviewjs 块里的两个子元素(同一次渲染、同一个时序),从根源上避免竞态
- 不要往 `.cm-sizer` 加 `display:flex` 之类会重新解释其子元素布局模型的规则——`.cm-sizer` 装的是 CodeMirror 逐行结构,不是渲染后的语义块,阅读视图（`.markdown-preview-sizer`）那套"每个顶层块一个 flex item"的假设在编辑视图不成立
- 用 devtools 验证时优先搜索类名定位真实 DOM 结构(Elements 面板 Cmd+F),不要只凭 Styles 面板"规则是否列出"就判断选择器生效——同一个词可能先命中 CSS 源文件文本,要翻到 DOM 节点那次命中才算数
