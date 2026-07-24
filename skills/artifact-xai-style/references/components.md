# grok-build component vocabulary

Copy-paste CSS + HTML for the recurring pieces. Everything is styled through
the tokens in `tokens.css`, so both themes work without extra work. These are
plain HTML/CSS reproductions of shadcn primitives (Card, Badge, Button, Table)
— Artifacts are a single self-contained file, so you can't import React/shadcn;
you reproduce the *look and token model*, not the library.

Contents: [Base/reset](#base) · [Type](#type) · [Eyebrow & mono labels](#labels)
· [Pill / status badge](#pill) · [Tag / chip](#tag) · [Stat tile](#stat)
· [Card](#card) · [Panel](#panel) · [Flow / DAG](#flow) · [Table](#table)
· [Checklist](#checklist) · [Legend](#legend) · [Focus & motion](#motion)

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
  letter-spacing: -0.011em;          /* grok sets slightly tight body */
  -webkit-font-smoothing: antialiased;
}
.wrap { max-width: 1180px; margin: 0 auto; padding: clamp(28px,5vw,72px) clamp(18px,4vw,48px) 96px; }
.mono { font-family: var(--font-mono); }
.tnum { font-variant-numeric: tabular-nums; }   /* any aligned digits */
```

<a id="type"></a>
## Type — the scale IS the personality

Display is large, weight **500** (confident, not bold), with **tight negative
tracking**. Body breathes. The move that reads unmistakably grok is the
**uppercase tracked MONO micro-label** — eyebrows, table headers, field labels
all read like code comments.

```css
h1 { font-size: clamp(2.1rem,5.2vw,3.4rem); line-height: 1.04; letter-spacing: -0.035em; font-weight: 560; margin: 0; text-wrap: balance; }
h2 { font-size: clamp(1.3rem,2.6vw,1.7rem); letter-spacing: -0.03em; font-weight: 560; margin: 0; text-wrap: balance; }
h3 { font-size: 1.02rem; letter-spacing: -0.02em; font-weight: 600; margin: 0; }
.lede { font-size: clamp(1.02rem,1.7vw,1.18rem); color: var(--muted-foreground); max-width: 64ch; }
```
Keep running text near 65ch. Weights available: 400 body, 500 display, 600 labels/headings.

<a id="labels"></a>
## Eyebrow & mono micro-labels

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
Use the same treatment (mono, uppercase, `letter-spacing: 0.12–0.2em`) for table
headers, node labels, and field captions. Tighter tracking (0.12em) for badges,
widest (0.2em) for the top eyebrow.

<a id="pill"></a>
## Pill / status badge — semantic state at a glance

Encode state in FORM + COLOR, not just words. A dot + tinted fill reads before
the label does. Status colors are semantic and separate from your accent.

```css
.pill { display: inline-flex; align-items: center; gap: 7px; border-radius: var(--radius-pill);
        font-size: 12.5px; font-weight: 500; padding: 6px 13px; border: 1px solid transparent; white-space: nowrap; }
.pill .dot { width: 7px; height: 7px; border-radius: 50%; flex: none; }
.pill.ok   { background: var(--status-success-bg); color: var(--status-success); border-color: color-mix(in srgb, var(--status-success) 30%, transparent); }
.pill.ok .dot   { background: var(--status-success); }
.pill.warn { background: var(--status-running-bg); color: var(--brand-warm-fg-on-surface); border-color: color-mix(in srgb, var(--status-running) 34%, transparent); }
.pill.warn .dot { background: var(--status-running); }
.pill.info { background: var(--status-queued-bg);  color: var(--status-queued);  border-color: color-mix(in srgb, var(--status-queued) 30%, transparent); }
.pill.info .dot { background: var(--status-queued); }
.pill.idle { background: var(--muted); color: var(--muted-foreground); border-color: var(--border); }
.pill.idle .dot { background: var(--faint); }
```
```html
<span class="pill ok"><span class="dot"></span>Passing</span>
```

<a id="tag"></a>
## Tag / chip — mono category markers

For engine/source/type categories. Mono, uppercase, tight radius (6px — chips
here are square-ish, only true *controls* are full pills).

```css
.tag { font-family: var(--font-mono); font-size: 10.5px; letter-spacing: 0.06em; text-transform: uppercase;
       padding: 3px 8px; border-radius: var(--radius-md); font-weight: 600; display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; }
.tag.solid { background: var(--engine-sql); color: var(--engine-sql-fg); }        /* near-black solid */
.tag.blue  { background: var(--engine-python-bg); color: var(--engine-python-fg); border: 1px solid var(--engine-python-bd); }
.tag.warm  { background: var(--engine-arrow-bg); color: var(--engine-arrow-fg); }
.tag.mut   { background: var(--muted); color: var(--muted-foreground); }
```

<a id="stat"></a>
## Stat tile — summary before detail

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
Add `@media (max-width:860px){ .stats{ grid-template-columns:repeat(2,1fr);} }`.

<a id="card"></a>
## Card — FLAT by default; the hairline carries elevation

The grok depth model: a single 1px border is the elevation. Reserve shadow for
*floating* chrome and hover-lift only. Cards use the outer radius (16px); inner
panels 14px.

```css
.card { border: 1px solid var(--border); border-radius: var(--radius-3xl); background: var(--card);
        padding: 22px; box-shadow: var(--shadow-card); }
.card.lift { transition: transform var(--duration-base) var(--ease-out), box-shadow var(--duration-base) var(--ease-out), border-color var(--duration-base) var(--ease-out); }
.card.lift:hover { transform: translateY(-3px); box-shadow: var(--shadow-lift); border-color: var(--border-strong); }
```

**Numbered head** (only when order is real information):
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
## Panel — accent-tinted section container

```css
.panel { border: 1px solid var(--border); border-radius: var(--radius-3xl); background: var(--card); padding: 24px; }
.panel.warm { border-color: color-mix(in srgb, var(--brand-warm) 30%, var(--border));
              background: linear-gradient(180deg, var(--status-running-bg), transparent 60%), var(--card); }
```
Spend the tint sparingly — one accented panel against quiet neighbors.

<a id="flow"></a>
## Flow / DAG diagram — horizontal, scrollable

Build pipelines/flows as flex stage-cards separated by arrow glyphs. Wrap in an
`overflow-x:auto` container with a `min-width` inner row so the page body never
scrolls sideways. Tag each node by source/engine with a colored left-border.

```css
.pipe-scroll { overflow-x: auto; padding: 4px 2px 14px; }
.pipe { display: flex; align-items: stretch; min-width: 880px; }
.stage { flex: 1; min-width: 168px; display: flex; flex-direction: column; }
.stage-card { border: 1px solid var(--border); border-radius: var(--radius-2xl); background: var(--card); padding: 16px 15px; height: 100%; display: flex; flex-direction: column; gap: 12px; }
.stage-card.dashed { border-style: dashed; background: var(--muted); }   /* deferred / future */
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
## Table — mono uppercase headers

```css
.tbl-scroll { overflow-x: auto; border: 1px solid var(--border); border-radius: var(--radius-2xl); background: var(--card); }
table { border-collapse: collapse; width: 100%; min-width: 620px; font-size: 13.5px; }
thead th { text-align: left; font-family: var(--font-mono); font-size: 10.5px; letter-spacing: 0.14em; text-transform: uppercase;
           color: var(--muted-foreground); font-weight: 600; padding: 13px 16px; border-bottom: 1px solid var(--border); background: var(--muted); }
tbody td { padding: 12px 16px; border-bottom: 1px solid var(--border); }
tbody tr:last-child td { border-bottom: none; }
```

<a id="checklist"></a>
## Checklist — inline SVG marks, not emoji

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
## Legend — decode the diagram colors

```css
.legend { display: flex; flex-wrap: wrap; gap: 16px; font-size: 12px; color: var(--muted-foreground); }
.legend span { display: inline-flex; align-items: center; gap: 7px; }
.legend i { width: 11px; height: 11px; border-radius: var(--radius-sm); display: inline-block; }
```

<a id="motion"></a>
## Focus & motion — restrained, accessible

```css
a:focus-visible, [tabindex]:focus-visible { outline: 2px solid var(--ring); outline-offset: 3px; border-radius: var(--radius-md); }

@keyframes rise { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: none; } }
.reveal { animation: rise .6s var(--ease-out) both; }
.d1{animation-delay:.05s} .d2{animation-delay:.12s} .d3{animation-delay:.19s} .d4{animation-delay:.26s}
@media (prefers-reduced-motion: reduce) { .reveal { animation: none; } .card.lift { transition: none; } }
```
One orchestrated load sequence (staggered `.reveal`) lands better than scattered
effects. Grok motion is quick (120–180ms) with no bounce — resist more.
