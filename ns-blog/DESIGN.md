# Swiss Grid

International Typographic Style for neilsriv blog. A strict column grid, a grotesk sans, a numbered index, and black, white, and one red. Structure comes from rules and alignment. Nothing is rounded, nothing floats, nothing gets a second color.

The preset is a Müller-Brockmann poster brought onto a blog: oversized type, a visible frame, asymmetric columns, and an index you can scan by number.

## Principles

- One voice. Inter for text, IBM Plex Mono for code. Both are neo-grotesks.
- One signal. Red marks the index, the current place, warnings, and link underlines. Everything else is ink on paper.
- Rules, not shadows. Elevation is zero. A 1px rule is the only separator.
- Numbers are part of the layout. Navigation, posts, and the table of contents are numbered.
- Asymmetry is the composition. Intro copy sits in the left seven columns. Meta sits in the right three. On a post, contents take a narrow left rail and the article takes the rest.
- Motion is a color change. Nothing travels, bounces, or fades in.
- Light and dark are the same poster, inverted. Red is the only hue that changes value, so it stays AA on both papers.

## Color

Contrast ratios are for the token used as text or as an icon, measured against the page or against `--signal` where noted. Every text pair clears WCAG AA (4.5:1). Signal-on-paper also clears AA, so red can be small text, not only a large graphic.

| Token | Light | Dark | Role | Contrast |
| --- | --- | --- | --- | --- |
| `--bg` | `#ffffff` | `#0a0a0a` | Page | — |
| `--ink` | `#0a0a0a` | `#f4f4f4` | Text, rules, borders | 19.8:1 / 18.0:1 on `--bg` |
| `--muted` | `#595959` | `#a3a3a3` | Kickers, dates, comments | 7.0:1 / 7.9:1 on `--bg` |
| `--signal` | `#c4001d` | `#ff4d4d` | Index numbers, current nav, underlines, warning rules | 6.2:1 / 6.1:1 on `--bg` |
| `--on-signal` | `#ffffff` | `#0a0a0a` | Text on a signal fill | 6.2:1 / 6.1:1 on `--signal` |
| `--code-bg` | `#f3f3f3` | `#141414` | Code and diagram panels | Ink on this ground stays above 17:1 / 16:1 |
| `--signal-wash` | `#f8d6da` | `#3d1216` | Highlighted code line | Ink on wash is 14.7:1 either mode |
| `--mark-filter` | `grayscale(1) contrast(1.4)` | `grayscale(1) invert(1)` | Social marks, so brand blue does not become a second hue | — |

`--rule` is an alias of `--ink`. Hairlines are black on white and white on black. There is no gray divider.

`color-scheme` follows the same pair, so scrollbars and form controls match the paper. `::selection` is signal fill with `--on-signal` text.

## Typography

Self-hosted, latin, `font-display: swap`.

| Family | Files | Use |
| --- | --- | --- |
| Inter (variable, roman and italic) | `static/fonts/inter-latin.woff2`, `inter-latin-italic.woff2` | Everything except code |
| IBM Plex Mono (400) | `static/fonts/ibm-plex-mono-latin.woff2` | Code |
| Helvetica Neue, Helvetica, Arial | system | Fallback, and the offline page, which must render with no font files |

Both webfonts are SIL Open Font License. The license texts sit next to the files.

The stack is `--font-sans: Inter, "Helvetica Neue", Helvetica, Arial, sans-serif` and `--font-mono: "IBM Plex Mono", "Courier New", monospace`.

Weights in use: 400 body, 500 labels, 700 display and titles. Italic is reserved for Markdown emphasis. The system itself does not italicize dates, quotes, or captions.

### Scale

Display sizes use `clamp` so the poster fits a phone. Tracking is tight on large sizes and open on labels. Labels are 11px, uppercase, 0.14–0.16em tracking.

| Token | Size | Line height | Tracking | Weight | Use |
| --- | --- | --- | --- | --- | --- |
| `--display` | `clamp(2.75rem, 12vw, 7.25rem)` | 0.9 | -0.06em | 700 | Wordmark |
| `--title` | `clamp(2.25rem, 5vw, 3.75rem)` | 0.95 | -0.045em | 700 | Page title |
| `--h1` | `clamp(2rem, 4vw, 2.75rem)` | 1.05 | -0.04em | 700 | Home headline, Markdown h1 |
| `--h2` | `1.5rem` | 1.15 | -0.03em | 700 | h2 |
| `--h3` | `1.25rem` | 1.25 | -0.02em | 700 | h3, index titles |
| `--h4` | `1.0625rem` | 1.35 | 0 | 700 | h4–h6 |
| `--body` | `1.0625rem` | 1.55 | 0 | 400 | Prose |
| `--small` | `0.8125rem` | 1.45 | 0 | 400 | Secondary prose |
| `--label` | `0.6875rem` | 1.4 | 0.14em | 500 | Kickers, tags, code captions |
| `--index` | `clamp(3rem, 8vw, 5.5rem)` | 0.8 | -0.06em | 700 | Year or count beside a title |
| `--num` | `1.75rem` | 1 | -0.04em | 700 | Row numbers |

Index numbers, dates, and counts use tabular figures.

## Space, grid, radius, elevation

Base unit is 8px. The scale is 4, 8, 12, 16, 24, 32, 48, 64.

| Token | Value |
| --- | --- |
| `--space-2xs` | 4px |
| `--space-xs` | 8px |
| `--space-sm` | 12px |
| `--space-md` | 16px |
| `--space-lg` | 24px |
| `--space-xl` | 32px |
| `--space-2xl` | 48px |
| `--space-3xl` | 64px |
| `--page` | 70rem |
| `--frame` | 24px, 16px below 760px |
| `--gap` | 20px |

The page is a centered frame, max 70rem, with a signal bar on the top edge and an ink rule on the left and right. Inside that frame the composition is a 12-column grid with a 20px column gap.

- Masthead: wordmark in the left columns, numbered nav flush right.
- Home: prose in columns 1–7, the site description in columns 9–12, the post index across all twelve. Below 760px every home region stretches the full frame, including the rules.
- Post: contents in a narrow left column, article in the remaining column. One column below 760px.
- Index rows: number, date, title, on a three-column track.

Radius is 0 on every element. Elevation is 0. There is no shadow, no blur, and no translucent scrim. The only depth cue is a rule.

## Motion

| Token | Value |
| --- | --- |
| `--dur` | 120ms |
| `--ease` | `cubic-bezier(0.2, 0, 0, 1)` |

Only color, background, and border transition, and only on links, tags, index rows, and the skip link. `scroll-behavior: smooth` is on for anchor jumps.

`prefers-reduced-motion: reduce` removes the smooth scroll, the skip-link travel, and every transition.

## Primitives

### Links

Ink text. Underline is 1px signal, offset 0.18em. Hover turns the text signal. On an index row, tag, or status action the hover fills the whole control with signal and sets the type to `--on-signal`. Focus-visible is a 2px signal outline, 3px offset. Visited links stay ink. The underline is the affordance, not a color change.

### Headings

Page title uses `--title`. Markdown headings step down the scale and sit tight to the paragraph they introduce. Each heading keeps its anchor (`#`), signal colored, hidden until hover or focus. Touch devices, where hover does not exist, show the anchor. That behavior stays as it was fixed on main.

### Code

Inline code is mono, one step smaller, on `--code-bg`, with a 1px ink border and no radius.

A fenced block is a square panel: ink border, `--code-bg`, a caption row (language in signal, title in muted, both tracked labels), then the code. Lines scroll horizontally instead of wrapping, so the gutter stays aligned. Line numbers are muted. Keywords and numbers are signal. Strings, names, and operators stay ink. Comments are muted. A highlighted line uses `--signal-wash`. Chroma runs with classes, not inline colors, so the same sheet follows light and dark.

### Blockquotes

A quote is not italic. It is ink text with a 4px ink rule on the left and no background.

### Admonitions

GitHub-style alerts stay alerts. They render as a square `aside`: 1px ink border, a tracked uppercase label, then the body. Warning, caution, danger, and error get a 6px signal rule and a signal label. Note, tip, and the other types keep an ink rule. No icon, no rainbow, no shadow. The type name is the marker.

### Tables

Full width of the column. Header row is a tracked label with a 2px ink rule under it. Body cells have a 1px ink rule under them. No vertical rules, no zebra, no rounded corners. Wide tables scroll inside the article column.

### Images

`max-width: 100%`. A 1px ink frame. Captions are tracked labels, muted, left aligned, not italic.

### Tags

A tag is a label in a 1px ink box. Hover fills it signal. The hash prefix stays, so the existing tag language is recognizable.

### Navigation

The wordmark is the site title, set in `--display`, and it links home. It is not an `h1`. The page title owns the `h1`.

The nav is a vertical index, flush right, uppercase labels with tabular numbers: 00 index, then the menu. The current page's number is a signal chip with `--on-signal` type. Below 760px the nav becomes a wrapping row under the wordmark.

The skip link is unchanged in behavior: off-screen until focus, then a signal chip at the top of the frame.

### Footer

A top rule, then a single row. Social marks are monochrome via `--mark-filter`. RSS is a tracked label. The made-with line stays as written in config, muted, on the right. Below 760px the row stacks.

### Table of contents

A sticky left rail on wide screens. "Contents" is a label. Entries are numbered with CSS counters, signal numbers, ink titles, no underline. Nested lists indent one step and restart their count. Code inside a heading is unmarked in the rail, so a chip cannot blow the column.

Below 760px the rail is a closed disclosure above the article, so a long outline does not push the essay down. Wide screens force the list open. The disclosure does not depend on JavaScript.

### Post index

An ordered list. Each row is number, `YYYY.MM.DD`, title. The number is signal `--num`. Rows are separated by ink rules. Hover and focus fill the row with signal. The home page shows the five most recent posts this way. Section and tag pages show every page in the current list, in the existing order.

The home index spans all twelve columns. The intro above it does not.

### 404

A signal display "404", an ink title, one sentence, and a filled ink action back to the index. Hover turns that action signal. The bear is gone. This page is a poster, not a joke.

### Offline

Same poster, inlined, so it does not depend on the stylesheet or the webfonts. System Helvetica is the stack. The kicker is "Offline", the title and body are the existing strings, and the three actions (home, back, reload) are ink boxes that fill signal on hover. No bootstrap icons and no extra hues.

### Mermaid

The pinned Mermaid build stays. `theme: "base"` takes the same ink, paper, and signal as the tokens, chosen from `prefers-color-scheme` at load. Diagrams are black rules on the page ground, with signal only on the secondary border. They do not introduce a palette.

## Page types

| Page | Composition |
| --- | --- |
| Home | Signal frame, display wordmark, description in the empty right columns, prose in the left seven, full-width numbered index |
| Section list | Kicker "Index", section title, count as the display number, numbered rows, tag row |
| Tag | Kicker "Filtering for", the tag as the title, a remove link, the count, numbered rows |
| Post | Kicker with section and date, title, the year as the display number, contents rail, article, tags |
| Multipage | Same title block with a part kicker, contents rail, previous / next as a ruled pair |
| 404 | Display 404 and a single action |
| Offline | Display title and three actions, styles inlined |

## What this does not change

Canonical URLs, the author and description meta, CNAME, the pinned Hugo workflow, service-worker revalidation, the pinned Mermaid script and hash, RSS, and the sitemap stay as they are. Post markdown is not rewritten. Admonitions still fire from the same `> [!TYPE]` syntax. The theme submodule is not edited. Overrides live in the site layouts and in `assets/original.css`, which already replaces the theme sheet.
