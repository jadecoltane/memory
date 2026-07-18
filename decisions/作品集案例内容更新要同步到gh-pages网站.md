---
type: decision
created: 2026-07-11
last-verified: 2026-07-18
---

# 作品集案例内容更新要同步到 gh-pages 网站

**约定**(用户 2026-07-11 明确要求):portfolio 仓库里案例内容有实质进展时,要同步更新到网站——即 portfolio 仓库的 **gh-pages 分支**(index.html + project-*.html 静态站)。

- 网站页面结构:index.html(bento 首页,三张项目卡)+ project-caidan.html(案例⑤彩蛋,已完整)+ project-hmi.html(案例①控制中心,2026-07-11 已灌入)+ project-ai.html + resume.html + contact.html
- 案例页有现成组件:decision-card / principle-grid / case-insight / case-meta / spec-table,新案例页复用这套,风格参照 project-caidan.html
- 同步口径:网站版比 PDF 版更精简;"不进 PDF 的自用内容"(面试预演、红线自检)绝不上网站;占位图用 case-image-placeholder 惯例
- 敏感信息红线同仓库规则:雇主名、内部数据不出现(2026-07-11 曾发现首页两处"吉利"残留于标签默认文本——脱敏只改了 data-zh 属性漏了 innerHTML,已修复;此类检查用 grep 全站扫)
- 失效条件:网站迁移出 gh-pages 分支,或用户改变载体策略

**2026-07-18 更新**:全站视觉基准已从"Framer 风高饱和色块"改为**苹果风简约质感**(用户明确要求"简约点 有质感 苹果那种感觉"):系统字体栈、#f5f5f7/#1d1d1f 中性色、发丝描边白卡片、深浅两态,项目卡用色点标识不用渐变;英雄卡=「晨雾光晕」浅色流体(淡紫→蜜桃,深字+黑胶囊按钮,2026-07-18 用户否决纯黑后定稿;备选深邃极光/暮色座舱两套配色留在 index.html 注释,一行可切)。后续改网站样式以此为基准,组件类名与双语/暗夜/氛围灯功能未变。Agent Demo 已部署在 gh-pages `/demo/`,首页迷你控制中心与案例②页有直达链接——案例②demo 代码更新时要同步复制到 gh-pages。
