# RSS

Every HTML page advertises the site feed. Fetching that URL returns the published pages, newest first, with the original titles.

## Sub-features

- `rss-link` exposes an alternate link to `/index.xml` from the home page.
- `rss-feed` returns a channel named `neilsriv blog` and the five published pages.
- `rss-section` also publishes `/tech/index.xml` for the tech section.

## How to get to it (user POV)

- Open any HTML page and follow the document's alternate RSS link.
- Open `/index.xml`.
- On Swiss Grid, a footer link labeled `RSS` points at the same feed. The other layouts do not draw that link.

## Driving it with verify-blog

Preconditions:

- `verify-blog doctor` prints `ok` for `http://127.0.0.1:4173`.
- Launch used `--evidence .cursor/skills/verify-blog/evidence/rss`.

- **Advertise.** Open home and read the alternate link. Run `verify-blog drive open /` and `verify-blog drive attr 'link[rel="alternate"][type="application/rss+xml"]' href`. The value ends with `/index.xml`.
- **Feed.** Fetch it. Run `verify-blog fetch /index.xml`. Status is `200`, content-type is `application/xml`, and `channel:` is `neilsriv blog`.
- **Items.** The first five `item:` lines, in order, name `building semantic and keyword search on cockroachDB` at `/tech/search/`, `migrating my aws database to cockroach labs in 12 hours` at `/tech/db_migration/`, `git ctf` at `/tech/git_ctf/`, `setting up a personal blog with hugo` at `/tech/hugo/`, and `now` at `/now/`. Item titles keep their original case. Links use the local origin.
- **Section feed.** Fetch the tech feed. Run `verify-blog fetch /tech/index.xml`. Status is `200`, the channel is `tech on neilsriv blog`, and the items include `/tech/search/` and do not include `/now/`.
- **Proof.** The `fetch` lines in `action.txt` are the proof. Do not screenshot the XML.

## Gotchas

- Hugo answers the feed with `application/xml`. The alternate link's type is `application/rss+xml`. Assert both, as themselves.
- A visible `RSS` anchor exists on Swiss Grid only. Do not require one on main or the other redesigns.
- Drafts are absent. `First Post` in an item is a failed production build.
- Feed links are absolute. Check the pathname, not a hard-coded host, when `VERIFY_BLOG_PORT` is not 4173. On the default port the host is `127.0.0.1:4173`.
