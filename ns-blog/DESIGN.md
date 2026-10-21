# Neutral System

Preset for this blog: a shadcn-style neutral system. Zinc surfaces, near-black text, hairline borders, and almost no chroma except where a control needs a state (admonition type, syntax tokens, focus). The type is Geist with Geist Mono for code. Light and dark are the same components with the tokens swapped.

The implementation lives in `assets/original.css` (the theme already publishes this file as the site stylesheet), `assets/syntax.css`, `assets/admonitions.css`, and `assets/neutral.js`. Layout overrides in `layouts/` only change structure where the system needs it: a sticky bar, card lists, a sidebar table of contents, and a command-palette search dialog. Canonical tags, the CNAME, the Pages workflow, service-worker revalidation, the pinned Mermaid script, admonition markup, RSS, and the sitemap stay as they are.

## Palette

Zinc, not a tinted gray. Text tokens are the ones that clear WCAG AA for normal text. Borders are separators; they are not asked to carry 3:1 non-text contrast because every control also has a label, a fill, or a focus ring that does.

### Light

| Role | Token | Value | Use |
| --- | --- | --- | --- |
| Page | `--background` | `#ffffff` | Page canvas |
| Text | `--foreground` | `#09090b` | Body, headings, links |
| Card | `--card` | `#ffffff` | Cards, admonition body |
| Popover | `--popover` | `#ffffff` | Search dialog |
| Popover text | `--popover-foreground` | `#09090b` | Dialog text |
| Primary | `--primary` | `#18181b` | Primary buttons |
| Primary text | `--primary-foreground` | `#fafafa` | Text on primary |
| Secondary | `--secondary` | `#f4f4f5` | Tags, secondary buttons |
| Secondary text | `--secondary-foreground` | `#18181b` | Text on secondary |
| Muted fill | `--muted` | `#f4f4f5` | Inline code, table headers, search hover |
| Muted text | `--muted-foreground` | `#52525b` | Dates, meta, hints. 7.4:1 on white, 7.0:1 on `#f4f4f5` |
| Accent | `--accent` | `#f4f4f5` | Hover fill |
| Border | `--border` | `#e4e4e7` | 1px hairlines |
| Ring | `--ring` | `#18181b` | Focus ring |
| Code surface | `--code` | `#f4f4f5` | Fenced blocks |
| Overlay | `--overlay` | `rgb(9 9 11 / 0.45)` | Dialog backdrop |

### Dark

| Role | Token | Value | Use |
| --- | --- | --- | --- |
| Page | `--background` | `#09090b` | Page canvas |
| Text | `--foreground` | `#fafafa` | Body, headings, links |
| Card | `--card` | `#09090b` | Cards sit on the page; the border separates them |
| Popover | `--popover` | `#09090b` | Search dialog |
| Popover text | `--popover-foreground` | `#fafafa` | Dialog text |
| Primary | `--primary` | `#fafafa` | Primary buttons invert |
| Primary text | `--primary-foreground` | `#18181b` | Text on primary |
| Secondary | `--secondary` | `#27272a` | Tags |
| Secondary text | `--secondary-foreground` | `#fafafa` | Text on secondary |
| Muted fill | `--muted` | `#27272a` | Inline code, headers |
| Muted text | `--muted-foreground` | `#a1a1aa` | Meta. 7.8:1 on `#09090b` |
| Accent | `--accent` | `#27272a` | Hover fill |
| Border | `--border` | `#27272a` | Hairline on the canvas |
| Ring | `--ring` | `#d4d4d8` | Focus ring |
| Code surface | `--code` | `#18181b` | Lifted from the page |
| Overlay | `--overlay` | `rgb(0 0 0 / 0.65)` | Dialog backdrop |

Admonition accents are used for the 3px leading edge and the icon, never for body text. Body text stays `--foreground`.

| Token | Light | Dark | Types |
| --- | --- | --- | --- |
| `--adm-note` | `#1d4ed8` | `#93c5fd` | note, info, abstract, question, notify |
| `--adm-tip` | `#15803d` | `#86efac` | tip, success, example, experiment |
| `--adm-warning` | `#b45309` | `#fcd34d` | warning, idea |
| `--adm-danger` | `#b91c1c` | `#fca5a5` | caution, error, danger, goal, memo |
| `--adm-important` | `#6d28d9` | `#d8b4fe` | important, task, code, quote, conclusion |

Syntax tokens are GitHub (light) and GitHub Dark, generated with `hugo gen chromastyles`. Line numbers are `#52525b` in light and `#a1a1aa` in dark so they clear AA on `--code`. The block background is `--code`, not the stock GitHub canvas.

## CSS custom properties

Tokens are declared on `:root` for light. `:root[data-theme="dark"]` replaces them for an explicit dark choice. `@media (prefers-color-scheme: dark)` applies the dark set only when the document has no `data-theme="light"`, so a stored light choice wins over the OS and a visitor with no choice follows the OS, including changes made while the tab is open.

`color-scheme` is set to match, so form controls and scrollbars follow the same choice.

| Token | Light | Dark |
| --- | --- | --- |
| `--font-sans` | Geist, Inter, ui-sans-serif, system-ui, sans-serif | same |
| `--font-mono` | Geist Mono, ui-monospace, SFMono-Regular, Menlo, Consolas, monospace | same |
| `--text-xs` | `0.75rem` | same |
| `--text-sm` | `0.875rem` | same |
| `--text-base` | `1rem` | same |
| `--text-lg` | `1.125rem` | same |
| `--text-xl` | `1.25rem` | same |
| `--text-2xl` | `1.5rem` | same |
| `--text-3xl` | `1.875rem` | same |
| `--text-4xl` | `2.25rem` | same |
| `--space-1` … `--space-16` | `0.25rem` through `4rem` on a 4px grid | same |
| `--radius-sm` | `0.375rem` | same |
| `--radius` | `0.5rem` | same |
| `--radius-lg` | `0.75rem` | same |
| `--shadow-sm` | `0 1px 2px rgb(0 0 0 / 0.05)` | `0 1px 2px rgb(0 0 0 / 0.4)` |
| `--shadow-lg` | `0 16px 40px rgb(0 0 0 / 0.12)` | `0 16px 40px rgb(0 0 0 / 0.45)` |
| `--shell` | `40rem` | same |
| `--shell-wide` | `64rem` | same |
| `--header` | `3.5rem` | same |

A post with a table of contents sets `--shell` to `--shell-wide` so the header, article, and footer stay aligned.

## Type

Geist and Geist Mono are self-hosted variable fonts (latin subset, `font-display: swap`) from the SIL Open Font License build. The license is at `/fonts/OFL.txt`. Inter and the platform UI stack are fallbacks for glyphs outside the latin range (emoji, the bear mark in the footer).

| Style | Size | Weight | Tracking | Line height |
| --- | --- | --- | --- | --- |
| Body | `--text-base` | 400 | 0 | 1.7 |
| Small / UI | `--text-sm` | 500 | 0 | 1.5 |
| Meta | `--text-xs` | 500 | 0 | 1.4 |
| Card title | `--text-lg` | 600 | `-0.02em` | 1.35 |
| Section heading | `--text-2xl` | 600 | `-0.025em` | 1.3 |
| Page title | `--text-4xl` (`--text-3xl` under 640px) | 600 | `-0.03em` | 1.15 |
| Code | `0.8125rem` | 400 | 0 | 1.6 |

Headings use the sans, not a serif. Code, kbd, captions, and search meta use the mono.

## Spacing

The page rhythm is `--space-6` (24px) between blocks, `--space-10` above the title, `--space-16` under the article. Cards stack with `--space-3`. The header is `--header` tall. Inline clusters (tags, nav, actions) use `--space-2`.

## Radius

| Token | Where |
| --- | --- |
| `--radius-sm` | Tags, buttons, search rows, inline code |
| `--radius` | Cards, code blocks, admonitions, inputs |
| `--radius-lg` | Search dialog, 404 and offline panels |

## Elevation and borders

Elevation is a 1px solid `--border` plus, where a surface needs to lift off the page, `--shadow-sm`. The search dialog is the only `--shadow-lg`. No blur on cards. The sticky header uses an 86% `--background` wash and a 10px backdrop blur so content passing underneath stays legible without a second surface color.

Focus is a 2px `--ring` outline, 2px offset. It is the element that has to meet non-text contrast, and `--ring` does (zinc-900 on white, zinc-300 on zinc-950).

## Motion

`scroll-behavior: smooth` is on for in-page anchors. Under `prefers-reduced-motion: reduce`, scroll behavior is auto.

## Theme switching

A short script in `custom_head` runs before the body. If `localStorage.theme` is `light` or `dark`, it sets `data-theme` on `<html>`. Otherwise it leaves the attribute unset and the media query follows the OS. The header button flips the stored choice. The first visit has no flash of the wrong theme because the attribute is set before first paint.

## Primitives

### Links

Prose links are `--foreground` with a 1px underline in `--muted-foreground`, offset 3px. Hover darkens the underline to `--foreground`. They do not use a blue accent. Visited links stay the same color. Nav links are sans, `--text-sm`, weight 500, no underline; the current page is `--foreground` and the rest are `--muted-foreground`.

### Headings

The site name in the bar is not an `h1`. Each page has one `h1` (the post title, the section title, or the home page's own heading). Section headings step down the scale above. Heading anchors stay the `#` link that was added for the table of contents: visible on hover, on keyboard focus, and always when the device has no hover. The color is `--muted-foreground`.

### Code blocks

A fenced block is a `figure.highlight` with a 1px border, `--radius`, and `--code` fill. The caption is a mono row: title on the left, language on the right, separated by a hairline. The `pre` scrolls horizontally instead of wrapping, so line numbers stay aligned. Inline code is mono, `--text-sm`, `--muted` fill, 1px border, `--radius-sm`. Highlighting uses Chroma classes (`noClasses = false`) so one stylesheet can serve both themes.

### Blockquotes and admonitions

A plain blockquote is a 1px `--border` rule on the left, `--space-4` of padding, `--muted-foreground` text, roman (not italic).

GitHub-style alerts still render through hugo-admonitions (`div.admonition.<type>`). `assets/admonitions.css` loads after the module stylesheet and restyles them: hairline border, 3px accent edge, `--muted` header, `--card` body, `--foreground` text, type color on the icon only. The markup, icons, and alert types are unchanged.

### Tables

Full width, collapsed 1px `--border`, `--space-3` cell padding, header row on `--muted` at weight 600. Type is `--text-sm`. On narrow screens the table scrolls inside the prose column.

### Images

`max-width: 100%`, intrinsic height, `--radius`, and a 1px border so a screenshot sits on the same grid as a card.

### Tags

A tag is an inline badge: `--secondary` fill, 1px border, `--radius-sm`, `--text-xs`, weight 500, no underline. The label keeps the existing `#name` form. Rows wrap.

### Nav

The bar is sticky to the viewport. Inside the shell: site name, section links (`home`, `tech`, `now`), then a search trigger and the theme button pinned to the end. Below 640px the search trigger keeps the icon and drops the word and the shortcut.

### Footer

A full-bleed hairline, then the shell. Social marks, then the existing made-with line. The GitHub mark is a black glyph, so it inverts under the dark theme; Bluesky keeps its color.

### TOC

Posts with headings get a two-column layout: prose, then a 15rem sidebar. The sidebar is sticky under the header and scrolls on its own. The label is "On this page". Nested Hugo TOC links indent; the link text is `--muted-foreground` with a hairline on the left that turns `--foreground` on hover. On viewports under 960px the contents move above the article inside a disclosure that starts open. From 960px up the summary leaves the tab order and a toggle listener keeps the list open, so the expanded state cannot drift from the visible list. In-page heading links use `scroll-padding-top` so the sticky bar does not cover the target.

### Post list

Home (recent posts), section indexes, and tag terms use the same card. Each card is a bordered, `--radius` surface with a `--shadow-sm`, the date in `--text-xs`, the title, and a two-line plain summary. The whole card is the hit target; the accessible name is the title. Tag terms say "Filtering for" with the existing remove-filter link. An empty list is a dashed panel with "No posts yet".

### 404

A centered panel: eyebrow "404", heading "Page not found", one sentence, a primary button back to home. The site chrome (bar, search, theme, footer) stays.

### Offline

The offline document does not use the base template, so it repeats the core tokens, the font stack, and the same panel and buttons. It follows `prefers-color-scheme` and a stored theme choice. The title, explanation, and the three actions (home, go back, try again) are the module's existing strings.

### Search

The trigger looks like a command input: icon, "Search", and a `⌘K` / `Ctrl K` keycap. It opens a native `dialog` (top layer, focus trap, Escape to dismiss, click on the backdrop to dismiss). The input filters a JSON index of regular pages (`/search-index.json`: title, url, date, summary, section, tags) generated with the home page. Matching is case-insensitive across those fields. Up to eight hits, title and date/section, arrow keys to move, Enter to open. An empty query lists the eight newest posts.

## Pages

| Page | Composition |
| --- | --- |
| Home | Bar, prose intro from the content file, card list of the five newest posts, footer |
| Section (`/tech/`) | Title, card list, tag badges for tags used in that section |
| Post | Title, date, tags, prose, sticky contents when the post has headings |
| Tag | "Filtering for", card list, link to clear |
| Multipage | Same prose styles, previous/next as buttons. The ring tutorial that uses this layout is still a draft |
| 404 | Panel described above |
| Offline | Standalone panel described above |

## What this does not change

Canonical and social meta, `static/CNAME`, the pinned Pages workflow, service-worker `stale-while-revalidate` for CSS and JS, the Mermaid 11.12.2 script URL and integrity hash, admonition render markup, RSS outputs, and the sitemap. Post markdown is untouched. Titles render as written in front matter.
