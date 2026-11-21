# Navigation

Every page offers a skip link and three primary links: home, now, and tech. Their pathnames stay the same when a redesign changes the label.

## Sub-features

- `nav-skip` moves to `#main-content` with the skip link.
- `nav-tech` opens the tech archive.
- `nav-now` opens the now page.
- `nav-home` returns to the root.

## How to get to it (user POV)

- Use `Skip to main content` at the start of a page.
- Choose `home`, `now`, or `tech` in the header nav.
- On Swiss Grid the root link is labeled `index` with a numeric prefix. `now` and `tech` keep those words and gain a numeric prefix. The pathnames are still `/`, `/now/`, and `/tech/`.

## Driving it with verify-blog

Preconditions:

- `verify-blog doctor` prints `ok` for `http://127.0.0.1:4173`.
- Launch used `--evidence .cursor/skills/verify-blog/evidence/navigation`.

- **Links.** Open home and read the nav. Run `verify-blog drive open /` and `verify-blog drive hrefs 'nav a'`. The pathnames, in order, are `/`, `/now/`, `/tech/`.
- **Skip link.** Read it. Run `verify-blog drive text 'a.skip-link'`. The text is `Skip to main content`. Activate it. Run `verify-blog drive click 'a.skip-link'`. The URL ends in `#main-content`.
- **Tech.** Choose the tech link. Run `verify-blog drive click 'nav a[href="/tech/"]'`. Path is `/tech/` and status is `200`.
- **Now.** Choose the now link. Run `verify-blog drive click 'nav a[href="/now/"]'`. Path is `/now/` and the title contains `now`.
- **Home.** Choose the root link. Run `verify-blog drive click 'nav a[href="/"]'`. Path is `/`. Read the heading. Run `verify-blog drive text 'main#main-content h1#blog'`. The text contains `blog?`.
- **Proof.** Screenshot the home nav at both widths. Run `verify-blog drive screenshot --width 1280 --height 800 --out .cursor/skills/verify-blog/evidence/navigation/desktop.png` and `verify-blog drive screenshot --width 390 --height 844 --out .cursor/skills/verify-blog/evidence/navigation/mobile.png`. Both show `neilsriv blog` and the three nav labels for this layout.

## Gotchas

- Do not click a link named `home` and expect Swiss Grid to match. Match `nav a[href="/"]`.
- The header wordmark is also a link to `/`, and it is outside `nav` on these layouts. `nav a[href="/"]` is the primary link. It is one match.
- `/now/` is a menu page. Notebook does not render an h1 for it. Assert the path and the document title.
- The skip link is present in the DOM even when it is visually hidden until focus. `drive text` still reads it.
- Footer links to Bluesky and GitHub are not this nav. Leave them out of the three-link assertion.
