---
name: verify-blog
description: >-
  Drive the neilsriv Hugo blog (blog.neilsriv.tech) in a browser from a local
  production hugo server. Use to prove the home list, a post, tag archives,
  RSS, or navigation on main or a redesign branch.
---

# Verify the blog

Reader-facing surface of this repo is the Hugo site in `ns-blog`, published to GitHub Pages at `https://blog.neilsriv.tech`. The same commands cover `main` and the redesign branches (Terminal, Swiss Grid, Neutral System, Editorial, Notebook). Selectors are pathnames and landmarks those layouts share. Do not drive theme classes such as `blog-posts` or `post-index`.

Run one server per checkout. A second checkout can take another `VERIFY_BLOG_PORT`. Stop the server before switching branches; `hugo server` watches the tree and would rebuild the other design in the same process.

## Launch

From the repo root:

```bash
.cursor/skills/verify-blog/scripts/verify-blog launch --evidence .cursor/skills/verify-blog/evidence/home
```

Prerequisites, matching `.github/workflows/hugo.yaml`:

- `hugo version` reports `v0.141.0` extended.
- `sass --version` reports Dart Sass `1.106.0`.
- `google-chrome` is on `PATH` (`CHROME` overrides the binary).
- `node` is on `PATH` (the drive helper uses the global `WebSocket`).

If `ns-blog/themes/hugo-bearcub/layouts/_default/baseof.html` is missing, launch runs `git submodule update --init --recursive` once. That is the theme the site renders with.

Launch starts `hugo server` in `ns-blog` with:

- `--environment production`, `--minify`, `--renderToMemory`, `--disableLiveReload`, `--disableFastRender`, `--appendPort=false`
- `--baseURL` set to `http://127.0.0.1:$VERIFY_BLOG_PORT/` (default port `4173`)
- `--bind 127.0.0.1`
- `TZ=America/Los_Angeles` and `HUGO_ENVIRONMENT=production`
- module cache at `/tmp/verify-blog/hugo-cache` (shared, not removed by cleanup)
- no `-D` / `--buildDrafts`

It does not run `hugo mod get`. Ready means the log contains `Web Server is available at http://127.0.0.1:4173/` and `Environment: "production"`, and `GET /` returns 200 with `main#main-content` and `neilsriv blog`. Launch prints `origin:`, `pid:`, and `ready:`. With `--evidence DIR`, it copies the server log to `DIR/build.txt` at that moment. `DIR` is relative to the repo root unless it is absolute.

Do not serve `ns-blog/public` with `python -m http.server`. That listing server exposes `/tags/` as a directory index and does not return Hugo's 404 page. This server returns Hugo's 404 document with HTTP 404.

## Doctor

```bash
.cursor/skills/verify-blog/scripts/verify-blog doctor
```

Run this before the first drive, and again after a failed drive, before retrying. Exit 0 prints:

```text
ok
origin: http://127.0.0.1:4173
port: 4173
pid: <hugo pid>
hugo: v0.141.0
environment: production
```

Doctor checks that the recorded pid is alive, its command is this production `hugo server` on that port, the log has the ready line and `hugo v0.141.0`, and `GET /` still contains `main#main-content` and `neilsriv blog`. When `ss` can see socket pids, the listener must be that pid. A failure means do not drive. When launch was given `--evidence`, doctor also writes `doctor.txt` there.

## Drive

The harness is headless Chrome against the launch origin. It keeps one tab for the run, bypasses the service worker, and starts at 1280×800. `drive` and `fetch` append their stdout to the evidence `action.txt` when launch was given `--evidence`.

```bash
.cursor/skills/verify-blog/scripts/verify-blog drive open /
.cursor/skills/verify-blog/scripts/verify-blog drive text 'a.skip-link'
.cursor/skills/verify-blog/scripts/verify-blog drive attr 'link[rel="alternate"][type="application/rss+xml"]' href
.cursor/skills/verify-blog/scripts/verify-blog drive count 'main a[href$="/tags/tech/"]'
.cursor/skills/verify-blog/scripts/verify-blog drive hrefs 'nav a'
.cursor/skills/verify-blog/scripts/verify-blog drive click 'nav a[href="/tech/"]'
.cursor/skills/verify-blog/scripts/verify-blog drive screenshot --width 1280 --height 800 --out .cursor/skills/verify-blog/evidence/home/desktop.png
.cursor/skills/verify-blog/scripts/verify-blog drive screenshot --width 390 --height 844 --out .cursor/skills/verify-blog/evidence/home/mobile.png
.cursor/skills/verify-blog/scripts/verify-blog fetch /index.xml
```

`open` and `click` print `status`, `url`, `path`, and `title`. `text`, `attr`, and `click` require one match. `hrefs` prints `pathname`, a tab, then the link's text, in DOM order. `click` fails when the URL does not change. `fetch` prints `status`, `content-type`, and either the HTML `title` or the RSS `channel` plus the first eight `item` lines. HTTP 404 is a successful observation; a connection failure is not.

Stable handles on every current layout:

- `a.skip-link` text `Skip to main content`
- `main#main-content`
- `nav a[href="/"]`, `nav a[href="/now/"]`, `nav a[href="/tech/"]`
- home heading `main#main-content h1#blog`
- post links `a[href$="/tech/search/"]`, `a[href$="/tech/db_migration/"]`, `a[href$="/tech/git_ctf/"]`, `a[href$="/tech/hugo/"]`, `a[href$="/now/"]`
- tag term `a[href$="/tags/tech/"]`
- feed `link[rel="alternate"][type="application/rss+xml"]` and `GET /index.xml`

Published pages, newest first: `/tech/search/`, `/tech/db_migration/`, `/tech/git_ctf/`, `/tech/hugo/`, `/now/`. Drafts (`First Post`, `replacing git with jj (jujutsu)`, `Ring_tutorial`) are not in this server.

## Evidence

Write proof under `.cursor/skills/verify-blog/evidence/<feature>/`. Cleanup never deletes that tree. The directory is gitignored.

For a UI feature, capture the action and the page it produced:

- `build.txt` — Hugo's startup log, including the page count and `Environment: "production"`.
- `doctor.txt` — the `ok` line, origin, pid, and version.
- `action.txt` — every `drive` and `fetch` stdout from the run.
- `desktop.png` — the same page at 1280×800.
- `mobile.png` — the same page at 390×844.

Screenshots are of the viewport after `document.fonts.ready`. The site name `neilsriv blog` has to be visible. Take both widths after the action that put the page in the state you are proving, not of a later page. RSS proof is the `fetch /index.xml` lines in `action.txt` plus the alternate-link `drive attr` line; there is no feed screenshot. There is no database and no write side effect. Do not mock pages. The local server is the stand-in for GitHub Pages; read `blog.neilsriv.tech` only with GET.

Name a comparison directory per branch (`evidence/home-terminal`) so screenshots do not overwrite each other.

## Cleanup

```bash
.cursor/skills/verify-blog/scripts/verify-blog cleanup
```

Cleanup reads the checkout lock, and only if `/proc/<pid>/cmdline` still contains the recorded command it sends `SIGTERM` to that process group (Chrome profile path, Hugo `--port`). It does not kill by process name. It then deletes the scratch dir (`/tmp/verify-blog/<checkout>-<port>`) and the lock. It leaves `.cursor/skills/verify-blog/evidence/` and `/tmp/verify-blog/hugo-cache/` in place. Run cleanup after a failed launch too, so a half-started server does not keep the port. After cleanup, the evidence files must still be non-empty.

## Helpers

The executable entry point is `.cursor/skills/verify-blog/scripts/verify-blog`.

```bash
.cursor/skills/verify-blog/scripts/verify-blog launch [--evidence DIR]
.cursor/skills/verify-blog/scripts/verify-blog doctor
.cursor/skills/verify-blog/scripts/verify-blog fetch PATH
.cursor/skills/verify-blog/scripts/verify-blog drive open PATH
.cursor/skills/verify-blog/scripts/verify-blog drive text SELECTOR
.cursor/skills/verify-blog/scripts/verify-blog drive attr SELECTOR NAME
.cursor/skills/verify-blog/scripts/verify-blog drive count SELECTOR
.cursor/skills/verify-blog/scripts/verify-blog drive hrefs SELECTOR
.cursor/skills/verify-blog/scripts/verify-blog drive click SELECTOR
.cursor/skills/verify-blog/scripts/verify-blog drive screenshot --width N --height N --out FILE
.cursor/skills/verify-blog/scripts/verify-blog cleanup
```

`verify-blog drive` exports `VERIFY_BLOG_ORIGIN`, `VERIFY_BLOG_CDP`, and `VERIFY_BLOG_SCRATCH`, then runs:

```bash
node .cursor/skills/verify-blog/scripts/drive.mjs <command> ...
```

Call `verify-blog`. Do not start Chrome or `drive.mjs` yourself.

Feature recipes live in `features/`. When the map drifts, use `/maintain-verification-skill`.
