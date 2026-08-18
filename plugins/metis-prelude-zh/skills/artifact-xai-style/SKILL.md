---
name: artifact-xai-style
description: >-
  使用 xAI / grok-build 视觉语言构建自包含 Artifact（单文件 HTML 页面、dashboard、
  diagram、plan、doc 或 poster）：采用 shadcn 风格 CSS variable theme、grok palette
  （白色 / 抬升的近黑 #151515 地面、grok blue #0659D2 与 sunset orange #FF7A17
  强调色）、Geist 系字体、全大写带字距的 mono micro-label、平面 hairline card 与 pill
  control。用户要求 grok/xAI 风格、grok build、shadcn look、Daedalus grok-build
  design system，或只描述“干净极简、蓝色强调、mono label、深色 dashboard”时使用；
  也用于将已有 Artifact 改成该视觉语言。不用于需要 npm 安装 shadcn 的真实 React/
  Next.js 应用；本工作流面向单文件自包含 HTML Artifact。
---

# Artifact — xAI / grok-build 风格

生成一个采用 grok-build 视觉语言的**单文件自包含 HTML Artifact**。shadcn 是 React
component library，而 Artifact 是无 build step、受严格 CSP 约束的静态文件，因此要在
纯 HTML/CSS 中复现 shadcn 的视觉和 token model，不安装库。shadcn 的 theme 本质上是
CSS variable system，本 skill 已提供填入 grok palette 的 variable layer。

## 工作流

1. **先加载 `artifact-design` skill** 校准设计投入；Artifact tool 需要它。大多数
   grok-build 请求是 utilitarian 技术页面，例如 plan、dashboard 或 pipeline diagram：
   做好层级、间距和 palette，但不要无缘由添加巨型 hero 或零散动画。需要长期保存或分享的
   landing page 才采用更 editorial 的处理。
2. **从 `assets/starter.html` 开始。** 保留 `<style>` token block 和 reset，替换
   `<div class="wrap">` 内 demo。它已经符合 Artifact 形态，不含
   `<!DOCTYPE>`、`<html>`、`<head>` 或 `<body>`，由 harness 包装。更复杂页面可改用
   `references/tokens.css` 的完整 token，并从 `references/components.md` 选取组件。
3. **使用 `references/components.md` 的组件词汇构建内容：** eyebrow label、pill、
   tag、stat tile、card、flow/DAG、table 和 panel。所有样式都通过 token 设置，不直接
   写 hex，确保 light/dark theme 同时可用。
4. **使用 Artifact tool 发布：** 设置稳定的 `<title>`、一句话 `description` 和 emoji
   `favicon`（例如蓝色视觉使用 `🔷`）。重复发布同一路径可保留 URL。

## 视觉语言

- **地面安静，颜色只作强调。** Light 使用白色，dark 使用抬升近黑 `#151515`。button、
  border 与大多数文字保持 monochrome；grok blue `#0659D2` 作为 link、focus ring、
  active state 和 primary emphasis，sunset `#FF7A17` 作为暖色次强调。boldness 集中在
  一个位置，周边保持中性。success green、running orange、queued blue 与 failure red
  属于独立 semantic status system，只用于状态。
- **字体承担识别度。** 标志性做法是全大写、带字距的 **MONO micro-label**：eyebrow、
  table header、node label 和 stat caption 都像 code comment。display 使用大字号、
  weight 500 和紧负字距（`-.03` 到 `-.04em`）；正文略紧（`-.011em`），宽度约 65ch。
- **Card 保持平面，hairline 负责层次。** 静止 card 只用 1px border，不加 drop shadow。
  shadow 只用于真正浮动的 chrome 或轻微 hover lift；否则会变成普通 Material 风格。
- **Control 用 pill，content 用紧凑 card。** button、chip、tab、filter 都使用完整 pill。
  content card base radius 8px，outer card 16px，inner panel 14px，app-shell chrome 20px。
  engine/source/type category chip 使用较方的 6px radius，不是 pill。
- **Light 与 dark 同等设计。** token block 在 `:root` 提供 light，在
  `@media (prefers-color-scheme:dark)` 与 `:root[data-theme="dark"]` 提供 dark；
  viewer 设置的 `data-theme` 必须胜出。不要直接反相，dark accent 已调整为对
  `#151515` 有足够对比的 periwinkle/amber。
- **Motion 克制。** 一个编排好的 staggered `.reveal` load sequence 优于散落 effect。
  transition 控制在 120–180ms，不使用 bounce，并始终处理
  `prefers-reduced-motion`。

## Artifact 约束

- **只能自包含。** CSP 会阻止所有外部 host；不使用 CDN CSS/JS、font 或 image。CSS/JS
  必须 inline，图片使用 `data:` URI。
- **不使用 webfont。** Geist 会被 CSP 阻止。使用 token 内 system sans/mono stack，
  通过 tracking 和 weight 建立风格；不要 `@import` 或 `<link>` font。
- **body 不横向滚动。** 宽 table、DAG 和 code 放入自己的 `overflow-x:auto` 容器，
  内层使用 `min-width`。
- **Responsive。** 使用 relative unit、带 `gap` 的 grid/flex、媒体
  `max-width:100%`；约 860px 以下将多列折成一列。
- **Accessible。** 使用 `--ring` 提供可见 `:focus-visible` outline；UI glyph 使用
  真正 SVG 而不是 emoji；装饰箭头添加 `aria-hidden`。

## 文件

| 文件 | 用途 |
|---|---|
| `assets/starter.html` | 可直接复制并填充的自包含起点，已内联 token。 |
| `references/tokens.css` | 完整 shadcn-shaped token set，含双 theme、radius、shadow、motion、status/syntax/engine/chart palette。 |
| `references/components.md` | 常用组件的 CSS + HTML，以及 flat-card、pill 与 mono-label 规则。 |
