---
name: artifact-xai-style
description: >-
  Build self-contained Artifacts (single-file HTML pages, dashboards, diagrams,
  plans, docs, posters) in the xAI / grok-build visual identity — shadcn-style
  CSS-variable theming with the grok palette (white / lifted near-black #151515
  grounds, grok-blue #0659D2 + sunset-orange #FF7A17 accents), Geist-family type
  with uppercase-tracked-mono micro-labels, flat hairline cards, and pill
  controls. Use this whenever the user asks for an Artifact or web page "in the
  grok / xAI style", "like grok build", with "shadcn styling / shadcn look", or
  references the Daedalus grok-build design system — and reach for it even when
  they only describe that look (clean minimal UI, blue accent, mono labels, dark
  dashboard) without naming it. Also use it to restyle an existing Artifact to
  this identity. Not for building a real React/Next.js app that npm-installs
  shadcn (the tokens still port, but the workflow here targets a single
  self-contained HTML Artifact).
---

# Artifact — xAI / grok-build style

Produce a **single self-contained HTML Artifact** in the grok-build visual
language. shadcn is a React component library; an Artifact is one static file
with no build step and a strict CSP, so you **reproduce shadcn's look and
token model in plain HTML/CSS** — you don't (and can't) install it. The payoff
is that shadcn's theming *is* a CSS-variable system, so porting it is natural:
this skill hands you that variable layer pre-filled with the grok palette.

## Workflow

1. **Load the `artifact-design` skill first** for design calibration (the
   Artifact tool requires it) — it tells you how much design investment the
   request warrants. Most grok-build requests are **utilitarian** technical
   pages (a plan, a dashboard, a pipeline diagram): make them polished — real
   hierarchy, considered spacing, the full palette — but don't bolt on a giant
   hero or scattered animation. A landing page or something the user will keep
   and share earns an editorial treatment.
2. **Start from `assets/starter.html`** — copy it, keep the `<style>` token
   block + reset, replace the demo inside `<div class="wrap">`. It's already
   Artifact-shaped (no `<!DOCTYPE>`/`<html>`/`<head>`/`<body>`; the harness
   wraps it). For a page heavier than the starter covers, paste the full
   `references/tokens.css` block instead and pull pieces from
   `references/components.md`.
3. **Build the content** with the component vocabulary in
   `references/components.md` (eyebrow labels, pills, tags, stat tiles, cards,
   flow/DAG, tables, panels). Style everything **through the tokens** — never
   hardcode a hex — so both themes work for free.
4. **Publish** with the `Artifact` tool: set a stable `<title>`, pass a
   one-sentence `description`, and give it an emoji `favicon` (e.g. `🔷` for the
   blue identity). Re-publishing the same file path keeps the URL.

## The design language — what makes it read as grok

Follow these because they're what separates this identity from a generic
"clean dark UI"; the reasoning matters more than the rule.

- **Grounds are quiet, color is the accent.** White (light) / lifted near-black
  `#151515` (dark). The interactive vocabulary — buttons, borders, most text —
  stays **monochrome**; grok-blue `#0659D2` is the one accent (links, focus
  ring, active state, primary emphasis), sunset `#FF7A17` the warm secondary.
  Spend boldness in one place and keep everything around it neutral. **Semantic
  status** (success green / running orange / queued blue / failure red) is a
  separate system from your accent — use it for state, not decoration.
- **The type carries it.** The signature move is the **uppercase tracked MONO
  micro-label** — eyebrows, table headers, node labels, stat captions all read
  like code comments (`font-mono`, `text-transform:uppercase`,
  `letter-spacing:.12–.2em`). Display is large, weight **500** (confident, not
  700-bold), with **tight negative tracking** (`-.03` to `-.04em`). Body is set
  slightly tight (`-.011em`) and breathes near 65ch.
- **Cards are flat; the hairline is the elevation.** A single `1px` border
  carries depth — no drop shadow on a resting card. Reserve shadow for genuinely
  floating chrome (popovers) and a subtle hover-lift. This flatness is core to
  the look; adding card shadows makes it read as generic Material.
- **Pills for controls, tight cards for content.** Every control (button, chip,
  tab, filter) is a full pill (`--radius-pill`). Content sits in tight cards —
  base radius **8px**, outer cards 16px, inner panels 14px, app-shell chrome
  20px. Category chips (engine/source/type) are square-ish 6px, not pills.
- **Design both themes, equally.** The token block handles it: light on `:root`,
  dark deltas under `@media (prefers-color-scheme:dark)` *and*
  `:root[data-theme="dark"]` (the viewer's toggle stamps `data-theme`, which
  must win). Never invert naively — the dark accents are pre-shifted to
  periwinkle/amber for contrast on `#151515`.
- **Motion is restrained.** One orchestrated load sequence (staggered
  `.reveal`) beats scattered effects; transitions are quick (120–180ms) with no
  bounce. Always guard `prefers-reduced-motion`.

## Artifact constraints (don't get burned)

- **Self-contained only.** A strict CSP blocks every external host — no CDN CSS/
  JS, fonts, or images. Inline all CSS/JS; embed any image as a `data:` URI.
- **No webfont.** Geist (the real grok face) is CDN-blocked, so the tokens ship a
  deliberate system stack (`ui-sans-serif, system-ui …` / `ui-monospace …`) —
  the tracking/weight discipline is what sells the look, and system fonts render
  it fine. Don't `@import` or `<link>` a font and risk a silent fallback.
- **Never scroll the body sideways.** Wide content (tables, DAGs, code) goes in
  its own `overflow-x:auto` container with a `min-width` inner element.
- **Responsive.** Relative units, grid/flex with `gap`, `max-width:100%` on
  media; collapse multi-column grids to one column under ~860px.
- **Accessible.** Visible `:focus-visible` outline (use `--ring`), real SVG
  marks over emoji for UI glyphs, `aria-hidden` on decorative arrows.

## Files

| File | Use |
|---|---|
| `assets/starter.html` | Copy-and-fill self-contained seed (tokens inlined). Start here. |
| `references/tokens.css` | The full shadcn-shaped token set (both themes, radius, shadow, motion, status/syntax/engine/chart palettes). Paste for a richer page. |
| `references/components.md` | Copy-paste CSS + HTML for every recurring piece, with the "why" for the flat-card / pill / mono-label rules. |
