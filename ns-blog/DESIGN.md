# Notebook

A warm paper system for the blog. The page is a sheet on a desk: cream (or night paper), a red margin rule, three binding holes, and a small sprout drawn in CSS. Body text is a humanist serif. Handwriting shows up only on short labels — dates, the table of contents, captions, footnote numbers — never on paragraphs.

This is a visual system, not a new site. Canonical URLs, the CNAME, the pinned Pages workflow, service-worker revalidation, the pinned Mermaid script, admonitions, RSS, and the sitemap stay as they are.

## What this does not do

No theme toggle. Color follows `prefers-color-scheme`. No search, comments, Tailwind, or React. No content rewrites. No new web fonts from a CDN at request time; the faces below are self-hosted.

## Type

| Role | Family | Use |
| --- | --- | --- |
| Body and headings | Literata (variable, latin, weight 200–900, roman and italic) | Prose, titles, nav, tags |
| Hand | Caveat (variable, latin, weight 400–700) | Dates, TOC title, code captions, footnote numbers, the “notes” label |
| Code | IBM Plex Mono (latin, 400, 400 italic, 500) | Code blocks and inline code |

Files live in `static/fonts/` with the OFL licenses beside them. `font-display: swap`. Literata roman is preloaded. Fallbacks: Palatino, then a generic serif; Segoe Print, then cursive; ui-monospace.

Caveat is always weight 600 and at least `1.35rem`. It is a label face. Long admonition titles stay in Literata.

### Scale

Root size is the browser default (16px). Body copy is 17px.

| Token | Size | Use |
| --- | --- | --- |
| `--text-xs` | 0.75rem | Code language, fine print |
| `--text-sm` | 0.875rem | Nav, tags, footer, TOC links, tables, footnotes |
| `--text-base` | 1.0625rem | Body |
| `--text-lg` | 1.25rem | h3 |
| `--text-xl` | 1.5rem | h2 |
| `--text-2xl` | 2rem | Post title |
| `--text-3xl` | 2.5rem | Home title |
| `--text-hand` | 1.35rem | Caveat labels |

Body line-height is 1.7. Headings are 1.25 with a slight negative tracking. Measure is `--measure` (`68ch`).

## Color

Text pairs were checked at 4.5:1 or better. The margin rule and the sprout are non-text; the rule clears 3:1 against both papers. The leaf is decorative.

Ink does not go pure black, and night paper does not go pure black. Both stay warm.

### Light

| Token | Value | Role |
| --- | --- | --- |
| `--desk` | `#e4d8c6` | Page around the sheet |
| `--paper` | `#f4efe6` | Sheet |
| `--paper-raised` | `#fffaf3` | Cards, code captions, form fields |
| `--ink` | `#2c241c` | Text, headings |
| `--ink-soft` | `#5c4e43` | Dates, secondary text |
| `--muted` | `#6e5f53` | Footer |
| `--line` | `#e0d2c0` | Hairlines, card borders |
| `--rule` | `#e6d9c8` | Horizontal ruling, drawn under the text |
| `--margin-rule` | `#b56560` | Vertical notebook rule |
| `--link` | `#1e4d7b` | Links, focus, light buttons |
| `--link-visited` | `#163556` | Visited prose links |
| `--accent` | `#9a4e32` | Blockquote spine, footnote numbers, card hover |
| `--highlight` | `#f6e3a1` | Selection, current nav, inline code wash |
| `--leaf` | `#5f8f68` | Sprout |
| `--leaf-deep` | `#3f6b4c` | Sprout stem and second leaf |
| `--button-fg` | `#fffaf3` | Text on a light-theme button |

### Dark

| Token | Value | Role |
| --- | --- | --- |
| `--desk` | `#161311` | Around the sheet |
| `--paper` | `#241e1a` | Sheet |
| `--paper-raised` | `#2e2722` | Cards |
| `--ink` | `#f3eadf` | Text |
| `--ink-soft` | `#d9cbbd` | Secondary text |
| `--muted` | `#c4b4a4` | Footer |
| `--line` | `#433930` | Hairlines |
| `--rule` | `#3a312b` | Ruling |
| `--margin-rule` | `#b56560` | Same red rule |
| `--link` | `#9fd4c4` | Links and buttons |
| `--link-visited` | `#c9b6e4` | Visited prose links |
| `--accent` | `#e7c8a0` | Spines, numbers, hover |
| `--highlight` | `#5a4630` | Selection, current nav, inline code |
| `--leaf` | `#9dcaa8` | Sprout |
| `--leaf-deep` | `#7eae90` | Stem |
| `--button-fg` | `#241e1a` | Text on a dark-theme button |

Shared: `--focus` is `--link`. `--code-bg` is `#282828` and `--code-fg` is `#ebdbb2` in both themes. Code is an ink well sitting on the paper, not a second theme.

`--button-bg` is `--link`.

### Admonition spines

Header text stays `--ink`. The type color is the left spine and the icon, so a bright yellow never becomes small text.

| Group | Token | Light | Dark | Types |
| --- | --- | --- | --- | --- |
| Info | `--adm-info` | `#1e4d7b` | `#9ec4e8` | note, info, abstract, memo, quote, code, question, notify, task |
| Good | `--adm-good` | `#1f5e4a` | `#9fd4c4` | tip, success, example, idea, experiment, conclusion |
| Warn | `--adm-warn` | `#8a5a12` | `#f0c27a` | warning |
| Risk | `--adm-risk` | `#9a2f2f` | `#f0a8a4` | caution, error, danger, important, goal |

Anything the admonition module does not recognize still renders as a note, which is the module’s own default.

## Space, radius, elevation

Space is a 4px grid: `--space-1` 0.25rem through `--space-4` 1rem, then 1.5, 2, 3, and 4rem (`--space-5` to `--space-8`).

| Token | Value | Use |
| --- | --- | --- |
| `--radius-sm` | 8px | Sketch page, small chips |
| `--radius-md` | 12px | Images |
| `--radius-lg` | 16px | Cards, code, admonitions, TOC, notes |
| `--radius-xl` | 20px | The sheet on the desk |
| `--radius-pill` | 999px | Nav current, tags, buttons |

`--shadow-sheet` lifts the page off the desk. `--shadow-card` is a soft drop plus a hair of inner light, so cards feel like a second sheet rather than a floating panel. Dark shadows are black at low opacity. Borders are 1px `--line`. The TOC and the notes column use a dashed border; everything else is solid.

## Motion

`--dur` is 160ms. `--ease` is `cubic-bezier(0.2, 0.8, 0.2, 1)`. Links and cards change color and border on hover. `scroll-behavior: smooth` on `html`.

`prefers-reduced-motion: reduce` removes smooth scroll, transitions, and animation. Nothing on the site depends on motion to be understood.

## Paper

The sheet is centered, `max-width: 48rem` (64rem when a post has a table of contents), radius `--radius-xl`, padded so text starts to the right of the margin rule. Ruling is a 1px line every 32px, painted as a background on the sheet only, in `--rule`, so it never competes with text contrast.

Binding holes are three CSS circles down the left edge, punched through to `--desk`. Below 760px the sheet goes full-bleed, the holes hide, and the red rule stays.

The masthead is the site name in Literata, the sprout, then the nav. The site name is a link, not a heading, so each page has one h1.

## Primitives

**Links.** `--link`, underline offset about 0.18em. Hover lays down `--highlight` and turns the underline `--accent`. Visited prose links use `--link-visited`. Card titles and nav links are not underlined. Focus is a 2px `--focus` ring, offset 3px, on `:focus-visible` only.

**Headings.** Literata, `--ink`, tight leading. The section anchor is a Caveat `#` in `--accent`, hidden until hover on a fine pointer and always visible on touch. Headings have `scroll-margin-top` so in-page jumps clear the top of the sheet.

**Code.** Inline code is Plex Mono on a `--highlight` wash, `--ink` text, small radius. Fences are a rounded ink well: Gruvbox classes in `assets/syntax.css`, with line numbers, comments, and red tokens lifted so they clear 4.5:1 on `#282828`. Highlighting is class-based (`noClasses = false`) and the syntax sheet loads with the page, because a render hook runs too late to decide the `<head>`. A fence title sits above the well in Caveat. The language name, when the fence has one, is Plex Mono so a short token stays legible. `pre` scrolls horizontally; it does not wrap, so indentation survives. Mermaid is not an ink well. It is a dashed paper card, and the pinned Mermaid build is themed with the paper palette for the active color scheme.

**Blockquotes.** Italic `--ink-soft`, a 3px `--accent` spine, no fill.

**Admonitions.** The hugo-admonitions render hook stays. Its Sass file is overridden at `assets/sass/vendors/_admonitions.scss` (the module’s own override point) so the injected sheet uses these tokens. Rounded card, `--paper-raised`, 4px spine, icon in the group color, title in Literata. The project `render-blockquote.html` still styles `.alert` the same way for the non-module path.

**Tables.** Full width, separate borders, `--line` rules, header row on `--highlight`, `--ink` text. The content column scrolls if a table is wider than the measure.

**Images.** `max-width: 100%`, radius `--radius-md`, a 1px `--line` edge and `--shadow-card`. Captions are Caveat, centered, `--ink-soft`.

**Tags.** Pills: `--paper-raised`, `--line` border, `--text-sm`, `--ink-soft`. Hover shifts border and text to `--link`. The post’s tags and the section’s tag row share `.tag`.

**Nav.** A wrapping row under the site name. Items are `--ink-soft`, at least 44px tall. The current item (and its section, while you are in a post) gets a `--highlight` pill and `aria-current="page"`. The pill rules are scoped to the mast, so the table of contents stays a text list.

**Footer.** A hairline, then the social marks and the existing made-with line in `--muted`. GitHub’s black glyph is filtered to warm paper in dark mode. Bluesky keeps its own color. Each mark has a 44px target.

**TOC.** A dashed card labeled “table of contents” in Caveat. Nested lists in `--text-sm`. Inline code in a heading stays mono in the margin, without the highlight chip, so a narrow line can wrap. On viewports at least 960px wide it is a sticky left margin (`13.5rem`, `top: 1.25rem`) aligned with the post title. Below that it stacks under the title and above the prose.

**Footnotes.** Goldmark’s footnote list is the notes column. A Caveat “notes” label, handwritten numbers in `--accent`, dashed card. From 1100px up, if a page has footnotes, the sheet widens and the list is absolutely placed in a right margin so the prose keeps its measure. Below that it stacks at the end of the entry. No posts use footnotes today; the style is there for when one does.

Print forces the ink, links, and code to black on white. The highlighter colors are hardcoded, so print overrides them directly.

**Post list.** Each post is a rounded card: Caveat date, Literata title. The whole card is the link. The same list is the home “recent posts” block and the section and tag pages. An empty list is one card reading “No posts yet”. A tag page has a Caveat “Filtering for” eyebrow, the tag as the h1, and the existing “Remove filter” link.

**Home.** The existing copy, set as prose on the sheet, with recent posts as cards. No extra headline.

**404.** “404”, the sentence “this page isn’t in the notebook.”, a “back home” button, and a CSS sketch of a ruled page with a folded corner.

**Offline.** `/offline/` is the service worker’s document fallback. Hugo resolves `layouts/index.offline.html` ahead of `layouts/index.html`, then renders it through the same base as every other page, so the sheet, ruling, and nav are the notebook rather than a second inline stylesheet. The module’s title, explanation, and Home / Go back / Try again actions stay.

**Pager.** Multipage previous / next links are the same pills as buttons.

## Layout

`layouts/_default/baseof.html` replaces the theme base only to add the sheet, the font preload, both stylesheets, and a `kind-*` class on `body`. Head partials are unchanged in order: favicon, title, SEO, styles, RSS, `custom_head` (canonical, manifest, theme-color). `custom_body` still registers the service worker and, when a page used a Mermaid fence, the pinned script.

Single pages keep the date, the TOC partial, the body, and the tags. Menu pages such as “now” skip the post byline, which is the theme’s own rule, so a page that is already a heading in the nav does not grow a second title and a timestamp.

Section tag clouds still list only tags that appear in that section.

## Files

| File | Job |
| --- | --- |
| `assets/original.css` | Tokens and every primitive except chroma colors |
| `assets/syntax.css` | Code token colors |
| `assets/sass/vendors/_admonitions.scss` | Admonition card, overriding the module |
| `layouts/_default/baseof.html` | Sheet, styles, preload |
| `layouts/partials/header.html` | Skip link, masthead, sprout, binding |
| `layouts/partials/nav.html` | Current page |
| `layouts/partials/footer.html` | Colophon |
| `layouts/partials/custom_head.html` | Theme color, plus the existing canonical and manifest links |
| `layouts/partials/custom_body.html` | Mermaid palette for the active scheme |
| `layouts/_default/single.html` | Post |
| `layouts/_default/list.html` | Section and tag |
| `layouts/index.html` | Home |
| `layouts/404.html` | Missing page |
| `layouts/index.offline.html` | Offline fallback at `/offline/` |
| `layouts/shortcodes/recent_posts.html` | Home cards |
| `layouts/_default/_markup/render-codeblock.html` | Caption and language |
| `static/fonts/` | Literata, Caveat, IBM Plex Mono |
