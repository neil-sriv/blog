# Terminal

A monospace shell for the blog. Dark is the default. Light is a real second theme, not an inverted gimmick. The page is a terminal window: a title bar, a prompt, dense type, and box rules. No scanlines, no glow, no CRT blur.

The system is plain CSS custom properties on `:root`. `prefers-color-scheme: light` swaps the same tokens. When the OS reports no preference, the dark set stays. `prefers-reduced-motion` leaves the caret solid and turns off smooth scrolling.

## Palette

Text tokens are at least 4.5:1 on the surface they sit on (WCAG AA). The accent is also the focus ring, and it clears 3:1 against both backgrounds.

Dark is phosphor on ink. Light is the same roles printed on paper, with the mint pulled down so it still reads as a link.

### Dark

| Token | Hex | Role |
| --- | --- | --- |
| void | `#07090c` | Page behind the window |
| bg | `#0e1218` | Window background |
| bg-elev | `#161c27` | Title bar, TOC, code chrome, alert fill |
| bg-code | `#0b0e14` | Code, mermaid, terminal blocks |
| fg | `#d7dee9` | Body text |
| fg-muted | `#9aa6b8` | Secondary text, colophon |
| fg-dim | `#7d8b9e` | Dates, comments, title-bar meta |
| accent | `#5eecc4` | Links, prompt, focus, current selection |
| accent-hover | `#8ff5d6` | Link hover |
| accent-visited | `#d2a8ff` | Visited prose and post links |
| on-accent | `#0e1218` | Text on accent fill |
| accent-dim | `#14332c` | Hover wash behind a link |
| amber | `#f0c36a` | Inline code, warning, type names |
| red | `#ff7b86` | Caution, deletion, tags in syntax |
| blue | `#8eb6ff` | Notes, function names |
| green | `#b7e38d` | Tips, strings |
| purple | `#d2a8ff` | Important, keywords |
| orange | `#ffb086` | Numbers |
| line | `#2c3546` | Hairline rules |
| line-strong | `#465066` | Window border, tag chips |
| selection | `#1d4f44` | Text selection |

### Light

| Token | Hex | Role |
| --- | --- | --- |
| void | `#d5dbe3` | Page behind the window |
| bg | `#f7f8fa` | Window background |
| bg-elev | `#e8edf2` | Title bar, TOC, code chrome, alert fill |
| bg-code | `#fbfcfe` | Code, mermaid, terminal blocks |
| fg | `#1a1f29` | Body text |
| fg-muted | `#3d4654` | Secondary text |
| fg-dim | `#4c5666` | Dates, comments, meta |
| accent | `#0c6b52` | Links, prompt, focus |
| accent-hover | `#0b5f49` | Link hover |
| accent-visited | `#6d28d9` | Visited links |
| on-accent | `#f7f8fa` | Text on accent fill |
| accent-dim | `#e5f4ef` | Hover wash |
| amber | `#8a5a00` | Inline code, warning, types |
| red | `#b4233a` | Caution, deletion |
| blue | `#1d4ed8` | Notes, functions |
| green | `#0f6a32` | Tips, strings |
| purple | `#6d28d9` | Important, keywords |
| orange | `#9a3412` | Numbers |
| line | `#c5ced8` | Hairline rules |
| line-strong | `#8b97a6` | Window border, tag chips |
| selection | `#c8efe3` | Text selection |

Syntax colors reuse these roles so a code block and an admonition speak the same language. Comments use `fg-dim`. Keywords use purple, strings green, numbers orange, functions blue, types amber, operators the accent, tags red.

## Tokens

Color properties live on `:root`, use the palette hexes above, and flip under `(prefers-color-scheme: light)`. Components never hardcode a hex.

| Property | Use |
| --- | --- |
| `--bg-void` | `body` |
| `--bg` | `.shell` |
| `--bg-elev` | chrome, TOC, alerts |
| `--bg-code` | code and diagrams |
| `--fg` | text |
| `--fg-muted` | secondary |
| `--fg-dim` | meta, comments |
| `--accent` | links, prompt |
| `--accent-hover` | hover |
| `--accent-visited` | visited |
| `--on-accent` | text on accent |
| `--accent-dim` | wash |
| `--amber` `--red` `--blue` `--green` `--purple` `--orange` | syntax and alerts |
| `--line` | 1px rules |
| `--line-strong` | frame, chips |
| `--selection` | `::selection` |

`--font` is the IBM Plex Mono stack. `--text-xs` `0.8125rem`, `--text-sm` `0.875rem`, `--text-base` `1rem`, `--text-lg` `1.125rem`, `--text-xl` `1.25rem`, `--text-2xl` `1.5rem`. `--space-1` through `--space-6` are `0.25rem`, `0.5rem`, `0.75rem`, `1rem`, `1.5rem`, `2rem`. `--radius` is `0`, `--rule` is `1px solid var(--line)`, `--frame` is `1px solid var(--line-strong)`, `--measure` is `68ch`. None of these change with the color scheme.

`color-scheme` is `dark`, and `light` inside the light media query, so scrollbars and form controls follow the theme.

## Type

IBM Plex Mono, self-hosted (latin woff2, SIL Open Font License, `static/fonts/OFL.txt`). Weights 400, 500, and 600, plus 400 italic. The face is limited to the latin `unicode-range`, so the footer signature and emoji fall through to a system font instead of the subset’s missing-glyph boxes. Fallback: `ui-monospace, "Cascadia Code", "Source Code Pro", Menlo, Consolas, monospace`.

Body is 16px / 1.65. Headings use 600 and a tighter 1.3 line-height. The prompt and dates use 500 and 400 at `--text-sm`. Code is `--text-sm` with 1.55 line-height. Italic is for quotations and the code-block title only.

The face is monospace on purpose, including prose. Density comes from the 16px body, the 68ch measure, and flat rules, not from shrinking the text below 13px.

## Spacing, radius, elevation

The space scale is 4, 8, 12, 16, 24, 32. Pages use `--space-4` as the main padding and `--space-5` between a heading and the next block.

Radius is 0. Terminal chrome is square.

Elevation is a border, not a shadow. The window sits on `--bg-void` with `--frame`. Regions inside it (title bar, TOC, code bar, alerts, listing header) change fill to `--bg-elev` and draw `--rule`. Focus is a 2px accent outline with 2px offset. Nothing blurs or floats.

## Motion

One animation: the header caret blinks 1.1s, step timing. It does not run under `prefers-reduced-motion`; the block stays visible. Smooth scrolling is on only when the user has not asked for reduced motion. Hovers change color immediately.

## Layout

The shell is a column, centered, `min(72rem, calc(100% - 2rem))`, at least the viewport tall, so the footer rests on the bottom edge of the window. On viewports under 768px the window is full bleed and the side borders drop.

```
┌ neil@blog ————————————————— tty1 ┐
│ neil@blog:~$ neilsriv blog █     │
│ > home   tech   now               │
│                                   │
│ $ cat tech/search.md              │
│ # title                           │
│ contents          prose …… 68ch   │
│                   code full col   │
│ exit 0                            │
└───────────────────────────────────┘
```

The title bar is a dashed rule between `neil@blog` and `tty1`. The first prompt line is the site name. The second prompt (`>`) is the nav. The current page is reverse video: accent fill, `--on-accent` text.

Prose, the post title, and the byline cap at 68ch. Code, diagrams, tables, and the post listing use the column width. A post with a table of contents puts that contents rail on the left, 15rem, sticky. The article column flexes beside it.

Under 768px the contents rail stacks above the article, scrolls inside 40vh, and loses sticky. Under 480px a listing stacks the date over the title and hides the column labels.

## Primitives

**Links.** Accent, underlined, offset from the baseline. Hover shifts to `--accent-hover` and a dim wash. Visited prose goes purple and still clears AA. Nav links are not underlined; the prompt and the reverse-video current item identify them. They keep a visible focus ring. The active item uses `aria-current="page"`.

**Headings.** One h1 per page (the site name is a link, not a heading). h1 is `--text-2xl`. h2 is `--text-xl` with a bottom rule. h3 is `--text-lg` with a 2px accent bar on the left. The permalink hash is the existing anchor, dim, shown on hover and always shown when hover is unavailable. Generated content is not used for heading text, so the accessible name stays the heading itself.

**Code.** A fenced block is a framed figure. The caption bar shows the language and, when the fence has a title, that title in italic. The code sits on `--bg-code` and scrolls horizontally inside the frame instead of wrapping mid-token. Line numbers are `--fg-dim` and not selectable. Inline code is amber, on `--bg-code`, with a hairline. Highlighting is class-based (Chroma `noClasses = false`) and colored with the syntax tokens above, so light and dark share one stylesheet.

**Blockquotes and admonitions.** A plain quote is italic, muted, with a dim left rule. GitHub alerts are still rendered by hugo-admonitions (`.admonition`, with its icon and label). The vendor card is restyled: square, no shadow, fill `--bg-elev`, 3px left border and header in the syntax color for that type (note blue, tip green, important purple, warning amber, error red). Inline code inside an alert uses the same amber chip as the rest of the page. The site’s alert render hook stays in place for any quote it still emits.

**Tables.** Full width, collapsed borders, hairline cells, header fill `--bg-elev`, left-aligned. On narrow screens the table scrolls inside itself.

**Images.** Max width 100%, height auto, hairline frame, elevated fill behind the pixels. Captions are centered, italic, muted.

**Tags.** `#name` chips. Hairline border, accent text, no fill. Hover and focus fill them with accent and `--on-accent`. They wrap.

**Nav.** Prompt line, then `home` and each main-menu entry in lowercase. Current page is reverse video, including descendants of a menu section. Targets are at least 32px tall. The row wraps.

**Footer.** Text links for Bluesky and GitHub (same URLs as before), then the existing made-with line, then a dim `exit 0` status. The status is decorative.

**TOC.** A sticky elevated panel labeled `contents`. Nested lists indent with a left rule. Links are muted, no underline, accent on hover. The label is a paragraph, not an h2, so it does not take over the outline.

**Post list.** A bordered index. Header row `date` / `name` (hidden from assistive tech because each row already has a time and a link). Rows are a date column plus the title. Hover washes the row. Visited titles use the purple. The section page opens with `$ ls ./section`. A tag page opens with `$ ls --tag name` and a `$ home` link that clears the filter. Empty state uses the existing “No posts yet” string.

**Home.** `$ cat ~/README`, then the page markdown. The recent-posts shortcode is the same index widget, headed `$ ls -t | head -5`.

**Single post.** `$ cat path/from/content`, the title, the date, contents beside the article, then the tag chips. No email reply line (the current template does not have one).

**404.** Heading `404`, then a terminal block: `cat: ./this-page: No such file or directory`, then a link home.

**Offline.** The PWA offline document, restyled as the same window. It still uses the module’s title, explanation, and the three actions (home, back, reload). It links the site stylesheet and carries a short inline fallback so the page is still a terminal if that file is not cached.

**Mermaid.** The pinned Mermaid 11.12.2 script is unchanged. `theme: 'base'` takes the palette: dark unless `prefers-color-scheme` is light. Diagrams sit in the same frame as code.

## Out of scope

No theme toggle, no scanline overlay, no search, no content rewrites, no new framework. Canonical tags, CNAME, the pinned Pages workflow, service-worker revalidation, the Mermaid integrity pin, the admonition render hook, and RSS/sitemap stay as they are.
