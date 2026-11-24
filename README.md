# neil-sriv blog

This repository is how I host my blog.

Built with Hugo and hosted on github pages.

## Writing

Posts are written in Obsidian at `~/obsidian/neil/cs/writing`. Set `WRITING_DIR` to use another directory. The vault note is the source of truth. `make sync` overwrites the copy in `ns-blog/content/tech/`, so edit the vault note.

From `ns-blog/`:

1. `make new post=<slug>` runs `hugo new tech/<slug>.md` and moves the file into the vault. The archetype sets `title`, `date`, `draft: true`, and `publish: false`. The command refuses to overwrite an existing file and prints the vault path.
2. Write the post in Obsidian.
3. `make sync` copies each note whose front matter sets publish to true into `content/tech/` with rsync. YAML is `publish: true`. TOML is `publish = true`. Notes without front matter, and notes with publish false, are skipped. The filename is kept as-is, including spaces. A name with spaces prints a warning, because the URL is awkward. Set `slug` in the note for a cleaner URL. Sync does not write to the vault.
4. `make preview` runs `hugo server -D` and mounts vault notes that start with `---` or `+++` onto `content/tech`. Notes that do not are printed and left out, so a plain Obsidian list does not stop the server. Drafts and unpublished notes in that set show up, and saving one reloads the page. A new note with front matter shows up without restarting preview. Preview does not copy files and does not change the vault or `content/tech/`.
5. Set `draft: false` when the post should go live.
6. Commit the synced file and push. GitHub Actions deploys `main`.

`publish` is only a sync flag. A normal `hugo` build still uses `draft`, and the preview config is not part of the GitHub Actions build.
