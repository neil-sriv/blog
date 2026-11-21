# Blog verification map

This directory is the maintained source for verifying the reader-facing Hugo site. Read the index, then follow one feature file.

## Baseline preconditions

- One `verify-blog launch` server for this checkout, default `http://127.0.0.1:4173`.
- `verify-blog doctor` prints `ok` for that origin before the first drive.
- The production server, so drafts are absent.
- Evidence for the feature goes in `.cursor/skills/verify-blog/evidence/<feature>/`.
- Do not drive a server this run did not start.

## Driving conventions

- Start from `/` unless the feature names another entry.
- Assert pathnames (`hrefs` output, `path:` lines). Link text changes case and extra words across redesigns.
- Treat every command as literal.
- `verify-blog drive` and `verify-blog fetch` append stdout to `action.txt` when launch received `--evidence`.
- Cleanup removes the server and the scratch dir. It does not remove the evidence directory.

## Proof and skip reporting

- Record the command and the page it produced: `action.txt`, both screenshots, `build.txt`, and `doctor.txt`.
- A UI proof shows `neilsriv blog` in the viewport.
- RSS proof is the `fetch` transcript, not a screenshot.
- An unreachable entry stays unverified. Record the command and the unmet precondition. Do not substitute another path and call this one done.

## Feature entry contract

Each feature file has an H1, one opening paragraph, then these H2 sections in order:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with verify-blog`
4. `Gotchas`

## Features

- [Home and recent posts](./home.md) covers the root intro and the five newest published pages.
- [Post page](./post.md) covers opening `/tech/search/` and reading its title, date, and a section.
- [Tags and the tech archive](./tags.md) covers `/tech/`, `/tags/tech/`, and the `/tags/` 404.
- [RSS](./rss.md) covers the alternate feed link and `/index.xml`.
- [Navigation](./navigation.md) covers the skip link and the home, now, and tech links.
