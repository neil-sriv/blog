# Post page

Opening a post shows its title, its published date, and the section headings from the article. The search post is the fixture.

## Sub-features

- `post-open` reaches `/tech/search/` from the home list.
- `post-title` shows the original title in `main h1`.
- `post-date` shows `2025-06-02` on the single date element.
- `post-section` shows the heading `why is search interesting?`.

## How to get to it (user POV)

- On the home page, choose `building semantic and keyword search on cockroachDB` (the label may be lowercased).
- Open `/tech/search/` directly.

## Driving it with verify-blog

Preconditions:

- `verify-blog doctor` prints `ok` for `http://127.0.0.1:4173`.
- The home recent list contains `/tech/search/`.
- Launch used `--evidence .cursor/skills/verify-blog/evidence/post`.

- **Open from home.** Start at the root and choose the search post. Run `verify-blog drive open /` and `verify-blog drive click 'main a[href$="/tech/search/"]'`. Status is `200` and path is `/tech/search/`.
- **Title.** Read the article heading. Run `verify-blog drive text 'main h1'`. The text is `building semantic and keyword search on cockroachDB`.
- **Date.** Read the date. Run `verify-blog drive attr 'main time' datetime`. The value is `2025-06-02`.
- **Section.** Read the first section heading. Run `verify-blog drive text 'h2#why-is-search-interesting'`. The text contains `why is search interesting?`.
- **Proof.** Capture both widths on this post, not on home. Run `verify-blog drive screenshot --width 1280 --height 800 --out .cursor/skills/verify-blog/evidence/post/desktop.png` and `verify-blog drive screenshot --width 390 --height 844 --out .cursor/skills/verify-blog/evidence/post/mobile.png`. Both show the title and `neilsriv blog`.

## Gotchas

- Assert the h1 inside `main`. The site name is also a heading in the header on main, outside `main`.
- The h1 keeps the title's case (`cockroachDB`). Home list labels often lowercase it.
- `h2#why-is-search-interesting` includes the section anchor `#` in its text.
- `/tech/hugo/` renders more than one `time`, so `main time` is not unique there. Use `/tech/search/`.
- Notebook hides the entry heading on pages that set `menu = "main"`. `/now/` is one of those. This post does not.
