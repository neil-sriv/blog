# Home and recent posts

The home page introduces the blog and lists the five newest published pages, with the site name and the primary links above that list.

## Sub-features

- `home-open` shows the intro heading `blog?` inside `main#main-content`.
- `home-recent` lists the five newest published pages in date order.
- `home-widths` shows that same list at desktop and mobile widths.

## How to get to it (user POV)

- Open the site root.
- Choose the nav link whose pathname is `/`.
- On Swiss Grid that link is labeled `index`, with a numeric prefix. On the other layouts it is labeled `home`.

## Driving it with verify-blog

Preconditions:

- `verify-blog doctor` prints `ok` for `http://127.0.0.1:4173`.
- Launch used `--evidence .cursor/skills/verify-blog/evidence/home`.

- **Open home.** Open the root. Run `verify-blog drive open /`. Status is `200`, path is `/`, and the title contains `neilsriv blog`.
- **Intro.** Read the heading. Run `verify-blog drive text 'main#main-content h1#blog'`. The text contains `blog?`.
- **Recent posts.** Read the five list links. Run `verify-blog drive hrefs 'main a[href$="/tech/search/"], main a[href$="/tech/db_migration/"], main a[href$="/tech/git_ctf/"], main a[href$="/tech/hugo/"], main a[href$="/now/"]'`. The pathnames, in order, are `/tech/search/`, `/tech/db_migration/`, `/tech/git_ctf/`, `/tech/hugo/`, `/now/`. Each label contains that page's title, ignoring case.
- **Drafts stay out.** Read the main text. Run `verify-blog drive text 'main#main-content'`. It does not contain `First Post` or `replacing git with jj`.
- **Desktop.** Capture the home page. Run `verify-blog drive screenshot --width 1280 --height 800 --out .cursor/skills/verify-blog/evidence/home/desktop.png`. The viewport shows `neilsriv blog`, `blog?`, and the five titles.
- **Mobile.** Capture the same page. Run `verify-blog drive screenshot --width 390 --height 844 --out .cursor/skills/verify-blog/evidence/home/mobile.png`. The same heading and the same five titles are in the viewport.

## Gotchas

- The heading text is `blog? #`. The `#` is the section anchor inside the heading. Assert `blog?`, not a string that excludes the anchor.
- List labels are lowercased on main, Terminal, Notebook, and Swiss Grid. Editorial and Neutral keep the title's original case. Assert the pathname.
- On Swiss Grid the number and the date sit inside the same anchor as the title, so the label is longer than the title. The pathname is still the proof.
- `/tech/hugo/` is a bad place to count `time` elements. Its body renders extra dates. This feature does not open it.
- Screenshots taken after a later `open` are not proof of home.
