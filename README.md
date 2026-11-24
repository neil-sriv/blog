# neil-sriv blog

This repository is how I host my blog.

Built with Hugo and hosted on github pages.

## Writing

Posts are written in Obsidian at `~/obsidian/neil/cs/writing`. Set `WRITING_DIR` to use another directory. The vault note is the source of truth. `make sync` overwrites the copy in `ns-blog/content/tech/`, so edit the vault note.

From `ns-blog/`:

1. `make new post=<slug>` runs `hugo new tech/<slug>.md` and moves the file into the vault. The archetype sets `title`, `date`, `draft: true`, and `publish: false`. The command refuses to overwrite an existing file and prints the vault path.
2. Write the post in Obsidian.
3. `make sync` copies each note whose YAML front matter has `publish: true` into `content/tech/` with rsync. Notes without front matter, and notes with `publish: false`, are skipped. Sync does not write to the vault.
4. `make preview` runs `hugo server -D` and mounts the vault on `content/tech` for that session. Drafts and notes with `publish: false` show up, and saving a note reloads the page. Every `.md` file in the vault directory is visible, including notes sync would skip. Preview does not copy files and does not change the vault or `content/tech/`.
5. Set `draft: false` when the post should go live.
6. Commit the synced file and push. GitHub Actions deploys `main`.

`publish` is only a sync flag. A normal `hugo` build still uses `draft`, and the preview config is not part of the GitHub Actions build.
