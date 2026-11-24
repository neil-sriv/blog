#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"

WRITING_DIR=${WRITING_DIR:-"$HOME/obsidian/neil/cs/writing"}
case $WRITING_DIR in
  "~") WRITING_DIR=$HOME ;;
  "~/"*) WRITING_DIR=$HOME/${WRITING_DIR#"~/"} ;;
esac

usage() {
  printf '%s\n' \
    "usage: writing.sh new <slug>" \
    "       writing.sh sync" \
    "       writing.sh preview" \
    >&2
}

need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '%s is not on PATH\n' "$1" >&2
    exit 1
  }
}

need_writing_dir() {
  [ -d "$WRITING_DIR" ] || {
    printf 'WRITING_DIR does not exist: %s\n' "$WRITING_DIR" >&2
    exit 1
  }
}

publish_is_true() {
  local file=$1 line val started=0
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}
    if [ "$started" -eq 0 ]; then
      [ "$line" = "---" ] || return 1
      started=1
      continue
    fi
    [ "$line" = "---" ] && return 1
    case $line in
      publish:*)
        val=${line#*:}
        val=${val#"${val%%[![:space:]]*}"}
        val=${val%"${val##*[![:space:]]}"}
        case $val in
          \"*\" | \'*\')
            val=${val#\"}
            val=${val%\"}
            val=${val#\'}
            val=${val%\'}
            ;;
          *)
            val=${val%% #*}
            val=${val%"${val##*[![:space:]]}"}
            ;;
        esac
        [ "$val" = "true" ] && return 0
        return 1
        ;;
    esac
  done < "$file"
  return 1
}

cmd_new() {
  local slug=$1 dest created
  [ -n "$slug" ] || {
    printf 'usage: make new post=<slug>\n' >&2
    exit 1
  }
  case $slug in
    *[!A-Za-z0-9_-]* | [!A-Za-z0-9]*)
      printf 'invalid slug: %s\n' "$slug" >&2
      exit 1
      ;;
  esac
  need hugo
  dest=$WRITING_DIR/$slug.md
  created=content/tech/$slug.md
  if [ -e "$dest" ]; then
    printf 'refusing to overwrite %s\n' "$dest" >&2
    exit 1
  fi
  if [ -e "$created" ]; then
    printf 'refusing to overwrite %s\n' "$created" >&2
    exit 1
  fi
  mkdir -p "$WRITING_DIR"
  hugo new "tech/$slug.md" >/dev/null
  if [ ! -f "$created" ]; then
    printf 'hugo new did not create %s\n' "$created" >&2
    exit 1
  fi
  if ! mv -n "$created" "$dest"; then
    rm -f "$created"
    printf 'refusing to overwrite %s\n' "$dest" >&2
    exit 1
  fi
  printf '%s\n' "$dest"
}

cmd_sync() {
  local file base copied=0
  need rsync
  need_writing_dir
  mkdir -p content/tech
  shopt -s nullglob
  for file in "$WRITING_DIR"/*.md; do
    [ -f "$file" ] || continue
    [ -L "$file" ] && continue
    publish_is_true "$file" || continue
    base=$(basename "$file")
    rsync -a -- "$file" content/tech/
    printf '%s\n' "content/tech/$base"
    copied=1
  done
  [ "$copied" -eq 1 ] || printf '%s\n' "no posts copied"
}

toml_quote() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '"%s"' "$s"
}

write_preview_config() {
  local src
  src=$(toml_quote "$WRITING_DIR")
  cat > hugo.preview.toml <<EOF
[[module.mounts]]
source = $src
target = "content/tech"
includeFiles = ["*.md"]

[[module.mounts]]
source = "content"
target = "content"

[[module.mounts]]
source = "data"
target = "data"

[[module.mounts]]
source = "layouts"
target = "layouts"

[[module.mounts]]
source = "i18n"
target = "i18n"

[[module.mounts]]
source = "archetypes"
target = "archetypes"

[[module.mounts]]
source = "assets"
target = "assets"

[[module.mounts]]
source = "static"
target = "static"
EOF
}

cmd_preview() {
  need hugo
  need_writing_dir
  write_preview_config
  trap 'rm -f hugo.preview.toml' EXIT INT TERM
  hugo server -D --config hugo.toml,hugo.preview.toml
}

case ${1:-} in
  new) cmd_new "${2:-}" ;;
  sync) cmd_sync ;;
  preview) cmd_preview ;;
  *) usage; exit 1 ;;
esac
