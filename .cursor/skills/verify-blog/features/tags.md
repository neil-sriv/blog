# Tags and the tech archive

The tech section lists every published tech post. Choosing `#tech` opens the tech tag, which lists those same posts. The bare tag index does not exist.

## Sub-features

- `archive-section` lists the four tech posts at `/tech/`.
- `archive-tag` opens `/tags/tech/` and lists those four posts.
- `archive-clear` leaves the tag page through the link whose pathname is `/`.
- `archive-root` requests `/tags/` and gets a 404.

## How to get to it (user POV)

- Choose `tech` in the nav. The pathname is `/tech/`.
- On that page, choose `#tech`.
- On the home page, choose the word `tech` in the intro. It points at `/tags/tech/`.
- Choose the control that returns to the root. Its pathname is `/`. Its label is `Remove filter` on main, Swiss Grid, Neutral System, Editorial, and Notebook, and `home` on Terminal.

## Driving it with verify-blog

Preconditions:

- `verify-blog doctor` prints `ok` for `http://127.0.0.1:4173`.
- Launch used `--evidence .cursor/skills/verify-blog/evidence/tags`.

- **Section.** Open the tech archive. Run `verify-blog drive open /tech/`. Status is `200`, path is `/tech/`, and the title contains `tech`.
- **Section posts.** Read the post links. Run `verify-blog drive hrefs 'main a[href$="/tech/search/"], main a[href$="/tech/db_migration/"], main a[href$="/tech/git_ctf/"], main a[href$="/tech/hugo/"]'`. The pathnames are `/tech/search/`, `/tech/db_migration/`, `/tech/git_ctf/`, `/tech/hugo/`. `/now/` is not in this list.
- **Tag chip.** Count the tech tag link. Run `verify-blog drive count 'main a[href$="/tags/tech/"]'`. The count is `1`.
- **Open the tag.** Choose that link. Run `verify-blog drive click 'main a[href$="/tags/tech/"]'`. Status is `200`, path is `/tags/tech/`, and the title contains `Tech`.
- **Tag posts.** Read the same four pathnames with the section-posts `hrefs` command. They are present in the same order.
- **Clear.** Choose the root link inside main. Run `verify-blog drive click 'main a[href="/"]'`. Path is `/` and the title contains `home`.
- **Tag index.** Request the bare tag index. Run `verify-blog drive open /tags/`. Status is `404` and the title contains `404`.
- **Proof.** Open the archive again and capture it. Run `verify-blog drive open /tech/`, then `verify-blog drive screenshot --width 1280 --height 800 --out .cursor/skills/verify-blog/evidence/tags/desktop.png` and `verify-blog drive screenshot --width 390 --height 844 --out .cursor/skills/verify-blog/evidence/tags/mobile.png`. Both show the four tech titles and `neilsriv blog`.

## Gotchas

- `/tags/` is a 404. Term pages such as `/tags/tech/` are real. Do not treat the 404 as a broken tag.
- The filter heading is `Filtering for "Tech"` on main. Terminal does not use that sentence; it shows `#tech`. Assert the document title and the post pathnames.
- The clear control's label is not stable. Its pathname is `/`.
- Tag and section links built with a permalink are absolute under the local origin. `href$=` still matches.
- Do not require an h1 inside `main` on `/tech/`. Main's section page has none. Redesigns add one.
