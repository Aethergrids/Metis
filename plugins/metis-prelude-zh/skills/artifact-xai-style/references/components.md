# grok-build 组件词汇

以下 CSS 与 HTML 可直接复制。所有样式都通过 `tokens.css` 中的 token 定义，因此无需
额外处理即可支持两种 theme。这些是 shadcn primitive（Card、Badge、Button、Table）的
纯 HTML/CSS 复现；Artifact 是单文件，不能导入 React/shadcn，只复现其视觉和 token
model。

目录：[Base/reset](#base) · [Type](#type) · [Eyebrow 与 mono label](#labels)
· [Pill/status badge](#pill) · [Tag/chip](#tag) · [Stat tile](#stat)
· [Card](#card) · [Panel](#panel) · [Flow/DAG](#flow) · [Table](#table)
· [Checklist](#checklist) · [Legend](#legend) · [Focus 与 motion](#motion)

<a id="base"></a>
## Base / reset

```css
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--background);
  color: var(--foreground);
  font-family: var(--font-sans);
  line-height: 1.55;
  letter-spacing: -0.011em;
  -webkit-font-smoothing: antialiased;
}
.wrap { max-width: 1180px; margin: 0 auto; padding: clamp(28px,5vw,72px) clamp(18px,4vw,48px) 96px; }
.mono { font-family: var(--font-mono); }
.tnum { font-variant-numeric: tabular-nums; }
```

<a id="type"></a>
## Type — 字阶决定识别度

display 大而不粗，使用 weight **500** 和紧负字距；body 留出呼吸空间。最容易识别为
grok 的元素是全大写、带字距的 **MONO micro-label**，用于 eyebrow、table header 与
field label。

```css
h1 { font-size: clamp(2.1rem,5.2vw,3.4rem); line-height: 1.04; letter-spacing: -0.035em; font-weight: 560; margin: 0; text-wrap: balance; }
h2 { font-size: clamp(1.3rem,2.6vw,1.7rem); letter-spacing: -0.03em; font-weight: 560; margin: 0; text-wrap: balance; }
h3 { font-size: 1.02rem; letter-spacing: -0.02em; font-weight: 600; margin: 0; }
.lede { font-size: clamp(1.02rem,1.7vw,1.18rem); color: var(--muted-foreground); max-width: 64ch; }
```

running text 保持约 65ch。可用 weight：body 400、display 500、label/heading 600。

<a id="labels"></a>
## Eyebrow 与 mono micro-label

```css
.eyebrow {
  font-family: var(--font-mono);
  font-size: 11px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.2em;
  color: var(--muted-foreground);
}
```

```html
<span class="eyebrow">Daedalus · Feature Platform</span>
```

table header、node label 与 field caption 使用相同处理：mono、uppercase、
`letter-spacing: 0.12–0.2em`。badge 使用较紧的 0.12em，顶部 eyebrow 使用最宽的
0.2em。

<a id="pill"></a>
## Pill / status badge — 一眼识别语义状态

同时通过形状和颜色编码状态，而不是只依赖文字。dot 与 tinted fill 应先于 label 被识别。
status color 是独立的语义系统，不等于 accent。

```css
.pill { display: inline-flex; align-items: center; gap: 7px; border-radius: var(--radius-pill);
        font-size: 12.5px; font-weight: 500; padding: 6px 13px; border: 1px solid transparent; white-space: nowrap; }
.pill .dot { width: 7px; height: 7px; border-radius: 50%; flex: none; }
.pill.ok   { background: var(--status-success-bg); color: var(--status-success); border-color: color-mix(in srgb, var(--status-success) 30%, transparent); }
.pill.ok .dot   { background: var(--status-success); }
.pill.warn { background: var(--status-running-bg); color: var(--brand-warm-fg-on-surface); border-color: color-mix(in srgb, var(--status-running) 34%, transparent); }
.pill.warn .dot { background: var(--status-running); }
.pill.info { background: var(--status-queued-bg); color: var(--status-queued); border-color: color-mix(in srgb, var(--status-queued) 30%, transparent); }
.pill.info .dot { background: var(--status-queued); }
.pill.idle { background: var(--muted); color: var(--muted-foreground); border-color: var(--border); }
.pill.idle .dot { background: var(--faint); }
```

```html
<span class="pill ok"><span class="dot"></span>Passing</span>
```

<a id="tag"></a>
## Tag / chip — mono category marker

用于 engine/source/type。使用 mono、uppercase 和较紧的 6px radius；只有真正的 control
才使用完整 pill。

```css
.tag { font-family: var(--font-mono); font-size: 10.5px; letter-spacing: 0.06em; text-transform: uppercase;
       padding: 3px 8px; border-radius: var(--radius-md); font-weight: 600; display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; }
.tag.solid { background: var(--engine-sql); color: var(--engine-sql-fg); }
.tag.blue  { background: var(--engine-python-bg); color: var(--engine-python-fg); border: 1px solid var(--engine-python-bd); }
.tag.warm  { background: var(--engine-arrow-bg); color: var(--engine-arrow-fg); }
.tag.mut   { background: var(--muted); color: var(--muted-foreground); }
```

<a id="stat"></a>
## Stat tile — 先摘要，后细节

```css
.stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 14px; }
.stat { border: 1px solid var(--border); border-radius: var(--radius-2xl); padding: 20px; background: var(--card); display: flex; flex-direction: column; gap: 6px; }
.stat .n { font-size: clamp(1.9rem,3.4vw,2.5rem); font-weight: 560; letter-spacing: -0.04em; line-height: 1; }
.stat .n small { font-size: .5em; color: var(--muted-foreground); font-weight: 500; letter-spacing: 0; }
.stat .k { font-family: var(--font-mono); font-size: 10.5px; letter-spacing: 0.16em; text-transform: uppercase; color: var(--muted-foreground); }
```

```html
<div class="stat"><span class="n tnum">996</span><span class="k">Tests passing</span></div>
```

补充 `@media (max-width:860px){ .stats{ grid-template-columns:repeat(2,1fr);} }`。

<a id="card"></a>
## Card — 默认平面，以 hairline 建立层次

grok 的 depth model 由 1px border 承担。shadow 只用于 floating chrome 和 hover lift。
outer card radius 为 16px，inner panel 为 14px。

```css
.card { border: 1px solid var(--border); border-radius: var(--radius-3xl); background: var(--card);
        padding: 22px; box-shadow: var(--shadow-card); }
.card.lift { transition: transform var(--duration-base) var(--ease-out), box-shadow var(--duration-base) var(--ease-out), border-color var(--duration-base) var(--ease-out); }
.card.lift:hover { transform: translateY(-3px); box-shadow: var(--shadow-lift); border-color: var(--border-strong); }
```

只有顺序本身有信息时才使用 numbered head：

```html
<div style="display:flex; gap:13px; align-items:flex-start;">
  <span class="num">1</span><div><h3>Recent engagement</h3>…</div>
</div>
```

```css
.num { font-family: var(--font-mono); font-size: 12px; font-weight: 700; color: var(--background);
       background: var(--foreground); width: 26px; height: 26px; border-radius: var(--radius-lg); display: grid; place-items: center; flex: none; }
```

<a id="panel"></a>
## Panel — 带 accent tint 的 section container

```css
.panel { border: 1px solid var(--border); border-radius: var(--radius-3xl); background: var(--card); padding: 24px; }
.panel.warm { border-color: color-mix(in srgb, var(--brand-warm) 30%, var(--border));
              background: linear-gradient(180deg, var(--status-running-bg), transparent 60%), var(--card); }
```

tint 要克制：安静邻居之间只保留一个 accent panel。

<a id="flow"></a>
## Flow / DAG — 横向、可滚动

使用 flex stage-card 与箭头构建 pipeline。外层 `overflow-x:auto`，内层设置
`min-width`，避免 body 横向滚动。按 source/engine 通过彩色左边框标记 node。

```css
.pipe-scroll { overflow-x: auto; padding: 4px 2px 14px; }
.pipe { display: flex; align-items: stretch; min-width: 880px; }
.stage { flex: 1; min-width: 168px; display: flex; flex-direction: column; }
.stage-card { border: 1px solid var(--border); border-radius: var(--radius-2xl); background: var(--card); padding: 16px 15px; height: 100%; display: flex; flex-direction: column; gap: 12px; }
.stage-card.dashed { border-style: dashed; background: var(--muted); }
.node { font-family: var(--font-mono); font-size: 11px; padding: 7px 9px; border-radius: var(--radius-lg); background: var(--muted); border: 1px solid var(--border); }
.node.blue { border-left: 3px solid var(--brand-accent); }
.node.warm { border-left: 3px solid var(--brand-warm); }
.node .nlab { display: block; font-size: 9.5px; letter-spacing: 0.12em; text-transform: uppercase; color: var(--muted-foreground); margin-bottom: 2px; }
.arrow { flex: none; width: 34px; display: grid; place-items: center; color: var(--faint); }
```

```html
<div class="arrow" aria-hidden="true">
  <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12h15"/><path d="M13 6l6 6-6 6"/></svg>
</div>
```

<a id="table"></a>
## Table — mono uppercase header

```css
.tbl-scroll { overflow-x: auto; border: 1px solid var(--border); border-radius: var(--radius-2xl); background: var(--card); }
table { border-collapse: collapse; width: 100%; min-width: 620px; font-size: 13.5px; }
thead th { text-align: left; font-family: var(--font-mono); font-size: 10.5px; letter-spacing: 0.14em; text-transform: uppercase;
           color: var(--muted-foreground); font-weight: 600; padding: 13px 16px; border-bottom: 1px solid var(--border); background: var(--muted); }
tbody td { padding: 12px 16px; border-bottom: 1px solid var(--border); }
tbody tr:last-child td { border-bottom: none; }
```

<a id="checklist"></a>
## Checklist — 使用 inline SVG，不使用 emoji

```css
.checklist { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 11px; }
.checklist li { display: flex; gap: 11px; align-items: flex-start; font-size: 13.5px; }
.checklist .mk { flex: none; margin-top: 2px; width: 16px; height: 16px; }
.checklist code { font-family: var(--font-mono); font-size: 12px; background: var(--muted); padding: 1px 5px; border-radius: var(--radius-sm); border: 1px solid var(--border); }
```

```html
<li><svg class="mk" viewBox="0 0 20 20" fill="none" stroke="var(--status-success)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 10.5l4 4 8-9"/></svg><span>…</span></li>
```

<a id="legend"></a>
## Legend — 解释 diagram color

```css
.legend { display: flex; flex-wrap: wrap; gap: 16px; font-size: 12px; color: var(--muted-foreground); }
.legend span { display: inline-flex; align-items: center; gap: 7px; }
.legend i { width: 11px; height: 11px; border-radius: var(--radius-sm); display: inline-block; }
```

<a id="motion"></a>
## Focus 与 motion — 克制且 accessible

```css
a:focus-visible, [tabindex]:focus-visible { outline: 2px solid var(--ring); outline-offset: 3px; border-radius: var(--radius-md); }

@keyframes rise { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: none; } }
.reveal { animation: rise .6s var(--ease-out) both; }
.d1{animation-delay:.05s} .d2{animation-delay:.12s} .d3{animation-delay:.19s} .d4{animation-delay:.26s}
@media (prefers-reduced-motion: reduce) { .reveal { animation: none; } .card.lift { transition: none; } }
```

一个 staggered `.reveal` load sequence 优于零散 effect。grok motion 通常为
120–180ms，不使用 bounce。
