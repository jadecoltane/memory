---
type: decision
created: 2026-07-05
last-verified: 2026-07-05
---

工作台里"统计卡+随机重逢""今日抽卡+今日延伸""问题1+问题2"这几组并排卡片,最终用的是 `.obsidian/snippets/workbench.css`(本地插件配置,不进 git)里已有的纯 CSS 方案(`.markdown-preview-sizer` 设 `display:flex;flex-wrap:wrap`,配合 `:has()` 选择器让特定卡片收窄到 280px 起并排,并给卡片内容 `height:100%` 让外框跟着 flex 默认的 `align-items:stretch` 对齐),不是社区插件 Multi-Column Markdown。

**为什么**:2026-07-05 试装 Multi-Column Markdown 后发现三个问题——编辑/实时预览模式下会露出 `--- start-multi-column` 等原始语法标记很丑;两栏文本长度不一样时插件的默认容器不会自动对齐外框高度;还触发过一次不明原因的"1 Warning in region"。而项目里早就有一套纯 CSS 的并排卡片机制在用(横幅下面的统计卡/随机重逢就是这么做的),扩展它比引入插件更省心:不用装插件、编辑模式还是干净的标准 markdown、没有 warning、对齐问题直接靠 flex 默认行为解决。这也符合 [[decisions/自动化与文档设计优先选省token不影响效果的轻量方案]] 的取舍标准。

**何时失效**:如果未来想要的是"自由拖拽定位"而不是"并排网格",纯 CSS flex 方案做不到,那时候才需要考虑 Obsidian Canvas(`.canvas` 文件)或 Excalidraw,但那两者都不支持 dataviewjs,会牵动更大的架构改动。
