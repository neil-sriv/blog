# Editorial

A small literary magazine, set on warm paper. The reading column is a serif, the furniture (masthead rules, nav, dates, labels) is a compact sans, and a single cinnabar accent carries links, drop caps, rules that mean something, and code keywords. Hierarchy comes from type size and hairline rules. There is no shadow, no gradient, and no second color.

The system follows the page, not a component library. Home is the issue opener. A post is an article with a marginal contents rail. A tag page is an index. The offline fallback is the same paper, inlined, so it still looks like the magazine when the stylesheet did not cache.

## Palette

Light is the default. Dark replaces the same roles when `prefers-color-scheme: dark`. Roles do not change between modes: paper is the page, ink is the text, the accent is the only chromatic color.

| Role | Light | Dark | Use |
| --- | --- | --- | --- |
| paper | `#f6f1e7` | `#161311` | Page background |
| paper-raised | `#fbf7f0` | `#221e1a` | Admonitions, raised panels |
| ink | `#1c1612` | `#f3eadf` | Body, headlines, rules that structure the page |
| ink-soft | `#5c5148` | `#cbbba8` | Dates, captions, secondary labels |
| rule | `#c4b6a4` | `#5c4e44` | Hairlines between rows, table rules, code frame |
| accent | `#8e2c2c` | `#ef7d72` | Links, drop cap, pull-quote rule, admonition label, code keywords |
| accent-hover | `#6f2222` | `#f3b7b0` | Link hover |
| accent-visited | `#6a2424` | `#f3b7b0` | Visited links in prose |
| code-bg | `#efe6d6` | `#241e1a` | Listings |
| code-fg | `#1c1612` | `#f3eadf` | Listing text |
| code-comment | `#5e534a` | `#c4b5a4` | Comments in listings |

Contrast against the surface that color sits on (WCAG 2.1):

| Pair | Ratio |
| --- | --- |
| Light ink on paper | 15.9:1 |
| Light ink-soft on paper | 6.8:1 |
| Light accent on paper | 7.3:1 |
| Light accent on code-bg | 6.7:1 |
| Light code-comment on code-bg | 6.0:1 |
| Dark ink on paper | 15.5:1 |
| Dark ink-soft on paper | 9.9:1 |
| Dark accent on paper | 6.9:1 |
| Dark accent on code-bg | 6.2:1 |
| Dark code-comment on code-bg | 8.2:1 |

Ink, ink-soft, accent, and code comments clear AA for normal text. Accent on paper also clears AAA in light and AA in dark, so the drop cap and small-caps labels are safe. Selection is accent fill with paper text, which is the same pair inverted and stays above 6.9:1.

Structural rules (masthead, article head, footer) use ink, not the hairline color, so they read as the page's frame. Hairlines are decorative separators and are not the only cue for any control.

## Tokens

Tokens are custom properties on `:root`. Dark mode reassigns the color tokens inside `@media (prefers-color-scheme: dark)`. Components never use raw hex.

| Token | Value | Notes |
| --- | --- | --- |
| `--paper` `--paper-raised` `--ink` `--ink-soft` `--rule` | palette roles | |
| `--accent` `--accent-hover` `--accent-visited` | palette roles | |
| `--code-bg` `--code-fg` `--code-comment` | palette roles | |
| `--font-display` | Newsreader, then Iowan Old Style, Palatino, Georgia, serif | Headlines, lede, pull quotes, drop cap |
| `--font-body` | Source Serif 4, then the same serif stack | Prose |
| `--font-ui` | Source Sans 3, then Segoe UI, Helvetica, Arial, sans-serif | Nav, dates, labels, footer |
| `--font-mono` | IBM Plex Mono, then ui-monospace, SFMono-Regular, Menlo, Consolas, monospace | Code |
| `--text-xs` | 0.75rem | Eyebrows, nav, tag index |
| `--text-sm` | 0.875rem | Byline, dates |
| `--text-base` | 1.125rem | Body. 18px so the serif has a real reading size |
| `--text-md` | 1.35rem | Home lede, dek |
| `--text-lg` | 1.625rem | H3 |
| `--text-xl` | 1.75rem | H2 |
| `--text-2xl` | clamp(2.15rem, 4vw, 3.15rem) | Article and section headlines |
| `--text-display` | clamp(2.75rem, 7vw, 4.4rem) | Masthead wordmark on the home page |
| `--leading-body` | 1.65 | Prose |
| `--leading-tight` | 1.12 | Headlines |
| `--measure` | 66ch | Reading column |
| `--space-1` … `--space-8` | 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4.5 rem | The only spacing scale |
| `--mast-width` | 40rem | Home, indexes, pages without a contents rail |
| `--page-width` | 64rem | Article pages that have a contents rail |
| `--radius` | 0 | See below |
| `--shadow` | none | See below |

`color-scheme` is `light` or `dark` with the palette so form controls and the canvas match the paper.

## Type

Four families, each self-hosted as a Latin woff2 subset in `/fonts/` (SIL Open Font License; see `static/fonts/OFL.txt`).

- **Newsreader** (roman 400–600, italic 400–500) for the wordmark, headlines, the home lede, pull quotes, and drop caps. Optical size is left on `auto`.
- **Source Serif 4** (roman and italic, 400–600) for body, lists, and admonition copy.
- **Source Sans 3** (roman 400–600, italic 400) for the masthead dateline, navigation, bylines, contents, tag index, code captions, and footer.
- **IBM Plex Mono** (400, 500, italic 400) for inline code and listings.

`font-display: swap` with a serif or sans fallback that is close in tone, so a slow font does not leave the page blank or suddenly sans-serif. Two files are preloaded: Source Serif 4 roman and Newsreader roman.

The wordmark is Newsreader at display size, tight tracking, roman. Inner pages use the same wordmark one step down so the article title can be the loudest line. Chrome (nav, kickers, the contents label, tags, code captions) is uppercase Source Sans with 0.14–0.16em tracking. Article titles stay in the casing they were written in.

The home opener's first paragraph is set as a lede in Newsreader. An article whose first block is a paragraph gets a Newsreader drop cap in the accent, about 3.4em, floated. Pull quotes are Newsreader italic at 1.45rem with a 3px accent rule. Those two treatments are the magazine voice. They are not applied on top of each other: the home lede is not also a drop cap.

## Spacing, measure, and layout

The page is centered. Home, tag indexes, section indexes, and the 404 sit in `--mast-width` (40rem) with generous side margins on a wide monitor. An article with a table of contents widens to `--page-width` and becomes a two-column grid: a 14rem contents rail and a 66ch reading column, separated by `--space-7`. Articles without headings stay on the narrow measure.

The masthead is centered: dateline (today's date and the author), wordmark, the site description on the home page only, then a navigation bar closed by an ink rule. A 4px ink rule and a 1px ink rule, with a paper gap, sit on top of the masthead. The footer closes with a single 4px ink rule.

Below 880px the grid stacks. Contents come first, in document order, inside a 14rem scrolling box so a long outline does not push the article off the screen. Index rows stack the date above the title. The wordmark uses the clamp already in the display token.

## Radius and elevation

Radius is 0. Elevation is none. Cards, shadows, and frosted panels are out of the system. Surfaces separate with ink rules (structure) or `--rule` hairlines (rows, tables, the code frame, image edges). Admonitions are the one filled surface: `--paper-raised`, a hairline border, and a 3px accent rail. They are flat.

## Motion

Under `prefers-reduced-motion: no-preference`, the skip link eases in and links change color over 150ms. The page uses smooth scrolling. Under `prefers-reduced-motion: reduce`, scrolling is instant and those transitions are not applied. Nothing else moves. There is no entrance animation.

## Primitives

### Links

Prose links are the accent, underlined, with a softer underline color that turns solid on hover. Hover shifts to `--accent-hover`. Visited prose links use `--accent-visited`, which still clears AA. The underline is the cue, not color alone.

Navigation, the contents rail, index titles, tag indexes, and the wordmark are ink and gain the accent on hover. Visited state does not recolor an index; the page would turn into a field of two reds. The current nav item keeps an accent underline.

Focus is a 2px accent outline, offset 3px, on `:focus-visible`. The skip link is the first control, visually hidden until focused, and it remains available.

### Headings

Newsreader, ink, tight leading, slight negative tracking. H1 is `--text-2xl`. H2 is `--text-xl`. H3 is `--text-lg`. H4–H6 share 1.15rem. The section anchor sits in the accent and appears on hover where the pointer can hover; it stays visible when hover is unavailable. Headlines use `text-wrap: balance`.

### Code

Inline code is IBM Plex Mono a step smaller, on `--code-bg`, with a hairline. Listings are a figure: an uppercase Source Sans caption when the fence has a title, then the code on `--code-bg` inside a square hairline frame. The frame scrolls horizontally. Code is not soft-wrapped.

Listings are set like type, not like an IDE. Comments are `--code-comment` italic. Strings are italic ink. Keywords are the accent. Names, numbers, and operators stay ink, with functions at weight 500. One accent, no rainbow. Line numbers, when Hugo emits them, are `--ink-soft` and not selectable. Chroma runs with classes (`noClasses = false`) so these tokens can follow the color scheme. The theme's Dracula `syntax.css` is not loaded.

### Blockquotes and admonitions

A plain blockquote is a pull quote: Newsreader italic, 1.45rem, ink, 3px accent rail, no fill.

An admonition (Hugo alert blockquote: note, tip, warning, caution, and the rest) is a flat panel. The label is the alert title, or the type name when there is no title, set as an uppercase accent eyebrow. The body is Source Serif at reading size. Every type shares the accent rail. The word in the label distinguishes a warning from a note, so the palette does not grow a color per severity. The markup stays an `aside.admonition` with the type in the class, the same header and body structure the module used, without the module's multicolor stylesheet.

### Tables

Full width of the column, horizontal rules only. The header row is an uppercase Source Sans eyebrow with an ink rule under it. Body cells sit on hairlines. No zebra, no boxed grid.

### Images

Content images fill the column, keep their ratio, and take a hairline edge. Captions are Newsreader italic, centered, in ink-soft. Mermaid diagrams are not framed as listings: the diagram sits in the column, centered, and may scroll sideways when it is wider than the measure.

### Tags

A tag is an uppercase Source Sans label with its `#`, ink, wrapping with the other tags. On an article they sit under a "Filed under" eyebrow and an ink rule. On a section index they sit under a "Tags" eyebrow. Hover turns the accent.

### Nav

Uppercase Source Sans, tracked, centered under the wordmark, ink, wrapped when the line is short on space. `aria-current="page"` marks the section you are in. The bar is separated from the wordmark by an ink rule.

### Footer

A 4px ink rule, then a centered Source Sans colophon: Bluesky and GitHub as ink masks (so the icons follow the palette instead of introducing a blue), then the existing made-with credit.

### Table of contents

An eyebrow, "Contents", then a hairline rail. The rail is omitted when the page has no headings. Links are Source Sans, ink, quiet. Nested items step in and use ink-soft. The rail sticks under the top of the viewport on wide screens and scrolls inside itself. On narrow screens it is the boxed outline described above.

### Post list

An index, not a feed of cards. An ink rule opens the list. Each row is a hairline, with the date in Source Sans (tabular figures) and the title in Newsreader at 1.3rem. No bullets. The marker color elsewhere on the page is the accent, for lists inside prose.

The home page's recent-post shortcode uses the same row. A Newsreader italic line introduces it. The sentence is the one already in the shortcode.

### 404

The masthead stays. The page is an issue with an eyebrow "Not in this issue", a display "404", one sentence, and a link home.

### Offline

The service worker's fallback (`/offline/`) is its own document so it does not depend on the main stylesheet. It inlines the same paper, ink, and accent, and the same serif stack, with `@font-face` pointing at the self-hosted files for when those are cached. The heading and the explanation are the existing offline strings. Home, back, and reload stay as the three actions, set as text links.

### Mermaid

The pinned Mermaid 11.12.2 script, integrity hash included, stays. Initialization still uses theme `base`, and `themeVariables` map background, text, borders, and lines onto paper, ink, and accent for the current `prefers-color-scheme`. The diagram typeface is Source Serif 4.

## Pages

- **Home.** Masthead with the dateline, the display wordmark, and the description. The essay in the content file, its first paragraph as a lede, then the recent-post index.
- **Section index** (`/tech/`). Eyebrow "Section", the section title, the post index, then the tag index for that section.
- **Tag index.** Eyebrow "Filtering for", the tag as the title, a "Remove filter" link, then the same post index.
- **Article.** Eyebrow linking to the section when the page has one, the title, a byline with the date and author, contents and prose, then "Filed under" when the page has tags.
- **Multipage.** The same article head and contents rail, with previous and next as an uppercase pager under an ink rule. The tutorial that uses this layout is still a draft.
- **404 and offline.** As above.

## Out of scope

No theme toggle. The page follows the system scheme. No content rewrites, no new posts, no change to canonical tags, the CNAME, the pinned Pages workflow, service-worker revalidation, the Mermaid pin, RSS, or the sitemap. No Tailwind, no JavaScript framework, no font CDN. Social icons are not redrawn; they are masked so they inherit ink.
