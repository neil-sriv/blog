# neil-sriv blog

This repository is how I host my blog.

Built with Hugo and hosted on github pages.

## Writing

Everything under `ns-blog/content/` is written in Obsidian at `~/obsidian/neil/cs/writing`: posts, the `now` page, the home page, and section index pages. Set `WRITING_DIR` to use another directory. The vault is the source of truth and `ns-blog/content/` is generated output: `make sync` rewrites it from the vault, so never edit files there by hand.

### Where a note goes

Each note's front matter decides its path in `content/`:

- `section`: the folder under `content/`. Defaults to `tech`. `section = ""` is the content root, so the `now` note lands at `content/now.md`. Nested folders work, such as `section = "tech/ring_tutorial"`.
- `slug`: the filename, so `slug = "git_ctf"` gives `git_ctf.md`, and also the URL (`/tech/git_ctf/`). Without a slug, the vault filename is used. A filename with spaces then prints a warning, because the URL gets spaces too.
- `index = true`: the note is the folder's `_index.md` (section list page or home page), and `slug` is ignored.

Two notes that route to the same path stop sync with an error. The vault filename never affects the URL when `slug` is set, so name notes however reads best in Obsidian.

Images and other files the posts link to live in `ns-blog/static/` (for example `static/tech/hugo/blockquote.png` is `/tech/hugo/blockquote.png`). They are not synced from the vault.

### Workflow

From `ns-blog/`:

1. `make new post=<slug>` runs `hugo new tech/<slug>.md` and moves the file into the vault. The archetype sets `title`, `date`, `draft: true`, and `publish: false`. The command refuses to overwrite an existing file and prints the vault path.
2. Write the note in Obsidian. `make preview` runs `hugo server -D` on a copy of every vault note that starts with `---` or `+++`, routed the same way sync routes them, so you see the whole site as it will be after sync, drafts included. It listens on port 1313; if that port is taken, `make preview PORT=1414`. Notes without front matter are printed and left out. New and edited notes show up within a second or two without a restart. A deleted note can linger until you restart preview (Ctrl-C, then `make preview`), because `hugo server` keeps pages it already rendered. Preview does not change the vault or `content/`.
3. In the note, set publish to true and draft to false. YAML is `publish: true` and `draft: false`. TOML is `publish = true` and `draft = false`.
4. `make sync` makes `content/` match the vault: every note with publish true is copied to its routed path, and any file in `content/` that no note produces is removed. Notes without front matter, and notes with publish false, are skipped, so setting publish back to false unpublishes a post on the next sync. If no note has publish true, sync changes nothing. Sync does not write to the vault.
5. Review `jj diff`, commit, and push. GitHub Actions deploys `main`.

`publish`, `section`, and `index` are only sync fields. A normal `hugo` build still uses `draft`, and the preview config is not part of the GitHub Actions build.
