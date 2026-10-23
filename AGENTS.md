# blog

## Never write human posts

Agents never write real human posts. `ns-blog/hugo.toml` cascades `author = "Neil Srivastava"` onto every page, so agent writing under `ns-blog/content/` would carry Neil's byline.

- Do not create, rewrite, or "improve" a post, `now.md`, or any `_index.md` in `ns-blog/content/` unless Neil asked for that specific change in this task.
- Do not generate drafts, summaries, or new pages that would appear as Neil's.
- Fixing a typo, broken link, or build error he pointed at is fine. Keep the diff to that fix.
- Do not build an agent bulletin board or put agent writing in `ns-blog/content/` unless Neil asks for it in this task. Exploring that idea later is fine. If one is built, it must be a separate, clearly labeled section that never carries Neil's byline.

## Layout

- `ns-blog/data/styles/<id>.yaml` is the style catalog. Picker order is `weight`. `params.defaultStyle` is `classic`.
- `ns-blog/layouts/partials/style/boot.html` sets `html[data-style]` from a catalog `?style=`, else a catalog `localStorage` key `blog-style`, else `params.defaultStyle` if that id is in the catalog, else the lowest-weight id. A catalog `?style=` is saved to `blog-style`.
- Picker: `ns-blog/layouts/partials/style/picker.html`. Per-style CSS is `ns-blog/assets/styles/<id>.css`, plus `<id>-syntax.css` and `<id>-bridge.css` when present. `switcher.css` and `neutral.js` in that directory are not scoped style sheets. Fonts, except `classic`, are `ns-blog/static/fonts/<id>/`. Optional partials: `ns-blog/layouts/partials/styles/<id>/`.
- `ns-blog/scripts/scope_style.py` scopes style rules under `html[data-style="<style>"]`. `@font-face` and `@keyframes` stay global. Args: `style source dest`. Requires `tinycss2`.
- `ns-blog/hugo.toml` home outputs include `Offline`, `WebAppManifest`, and `SearchIndex`.

## Build

From `ns-blog/`, with submodules, Hugo extended 0.141.0, and Dart Sass 1.106.0:

```bash
hugo mod get
hugo --gc --minify --baseURL "<base url>/"
```

`baseURL` in `ns-blog/hugo.toml` is `https://blog.neilsriv.tech/`. `.github/workflows/hugo.yaml` passes `${{ steps.pages.outputs.base_url }}/` and sets `HUGO_ENVIRONMENT=production` and `TZ=America/Los_Angeles`.

## Deploy

A push to `main` builds and deploys to GitHub Pages. Pull requests and `workflow_dispatch` build only. A PR is ready when the `build` job of `Deploy Hugo site to Pages` passes.

## Rules

- Do not edit inside `ns-blog/themes/hugo-bearcub` (submodule of clente/hugo-bearcub). Override theme layouts and assets with the same path under `ns-blog/layouts/` or `ns-blog/assets/`. Override theme i18n under `ns-blog/i18n/`.
- Hugo and Dart Sass are pinned by version and SHA-256 in `.github/workflows/hugo.yaml`, and actions are pinned by commit SHA. When you bump one, update its checksum or SHA in the same change.
- Hugo modules (`ns-blog/go.mod`, `ns-blog/go.sum`) provide PWA and admonitions. Change them only with a reason, through `hugo mod`.
- Never commit `.env`, `ns-blog/public/`, `ns-blog/resources/_gen/`, `ns-blog/.hugo_build.lock`, or `ns-blog/assets/jsconfig.json`.
