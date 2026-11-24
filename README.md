# neil-sriv blog

This repository is how I host my blog.

Built with Hugo and hosted on github pages.

## Writing

Posts are written in Obsidian at `~/obsidian/neil/cs/writing`. Set `WRITING_DIR` to use another directory. The vault note is the source of truth. `make sync` overwrites the copy in `ns-blog/content/tech/`, so edit the vault note.

From `ns-blog/`:

1. `make new post=<slug>` runs `hugo new tech/<slug>.md` and moves the file into the vault. The archetype sets `title`, `date`, `draft: true`, and `publish: false`. The command refuses to overwrite an existing file and prints the vault path.
2. Write the post in Obsidian. `make preview` runs `hugo server -D` and mounts vault notes that start with `---` or `+++` onto `content/tech`, so you can read a draft before it is copied. It listens on port 1313. If that port is taken, `make preview PORT=1414`. Notes that do not start with front matter are printed and left out, so a plain Obsidian list does not stop the server. Saving a mounted note reloads the page. A new note with front matter shows up without restarting preview, after the mount list rewrites. Preview does not copy files and does not change the vault or `content/tech/`.
3. In the vault note, set publish to true and draft to false. YAML is `publish: true` and `draft: false`. TOML is `publish = true` and `draft = false`.
4. `make sync` copies each note whose front matter sets publish to true into `content/tech/` with rsync. That copy includes the flags from the vault, so set them before sync. Notes without front matter, and notes with publish false, are skipped. The filename is kept as-is, including spaces. A name with spaces prints a warning, because the URL is awkward. Set `slug` in the note for a cleaner URL. Sync does not write to the vault.
5. Commit the synced file and push. GitHub Actions deploys `main`.

`publish` is only a sync flag. A normal `hugo` build still uses `draft`, and the preview config is not part of the GitHub Actions build.
