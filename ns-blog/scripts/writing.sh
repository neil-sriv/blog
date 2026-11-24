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

each_note() {
  local file
  shopt -s nullglob
  for file in "$WRITING_DIR"/*.md; do
    [ -f "$file" ] || continue
    [ -L "$file" ] && continue
    printf '%s\n' "$file"
  done
}

first_line() {
  local line
  IFS= read -r line < "$1" || true
  line=${line%$'\r'}
  printf '%s' "$line"
}

has_front_matter() {
  case $(first_line "$1") in
    ---|+++) return 0 ;;
  esac
  return 1
}

# fm_get FILE KEY prints the value of a top-level front matter key, without
# quotes. It fails when the key is missing. Handles `key = v` (TOML) and
# `key: v` (YAML).
fm_get() {
  local file=$1 key=$2 line closer="" started=0 val
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}
    if [ "$started" -eq 0 ]; then
      case $line in
        ---) closer='---' ;;
        +++) closer='+++' ;;
        *) return 1 ;;
      esac
      started=1
      continue
    fi
    [ "$line" = "$closer" ] && return 1
    case $line in
      "$key"[[:space:]]*=*|"$key="*) val=${line#*=} ;;
      "$key"[[:space:]]*:*|"$key:"*) val=${line#*:} ;;
      *) continue ;;
    esac
    val=${val#"${val%%[![:space:]]*}"}
    case $val in
      \"*) val=${val#\"}; val=${val%%\"*} ;;
      \'*) val=${val#\'}; val=${val%%\'*} ;;
      *) val=${val%%[[:space:]]#*}; val=${val%"${val##*[![:space:]]}"} ;;
    esac
    printf '%s' "$val"
    return 0
  done < "$1"
  return 1
}

fm_true() {
  local val
  val=$(fm_get "$1" "$2") || return 1
  [ "$val" = true ]
}

# note_dest FILE prints where the note goes, relative to content/:
# <section>/<name>.md. section defaults to tech; section = "" is the content
# root. name is _index when index = true, else slug, else the vault filename.
note_dest() {
  local file=$1 section name
  section=$(fm_get "$file" section) || section=tech
  section=${section#/}
  section=${section%/}
  if fm_true "$file" index; then
    name=_index
  elif name=$(fm_get "$file" slug) && [ -n "$name" ]; then
    :
  else
    name=$(basename "$file" .md)
  fi
  case /$section/$name/ in
    */../*|*/./*)
      printf 'bad section or slug in %s\n' "$file" >&2
      return 1
      ;;
  esac
  case $name in
    */*)
      printf 'slug has a slash in %s\n' "$file" >&2
      return 1
      ;;
  esac
  if [ -n "$section" ]; then
    printf '%s/%s.md' "$section" "$name"
  else
    printf '%s.md' "$name"
  fi
}

# stage OUT MODE copies notes into OUT at their routed paths. MODE publish
# takes notes with publish true; MODE preview takes every note with front
# matter. Prints each destination.
stage() {
  local out=$1 mode=$2 file dest base
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    if ! has_front_matter "$file"; then
      [ "$mode" = preview ] && printf 'skip %s\n' "$(basename "$file")" >&2
      continue
    fi
    if [ "$mode" = publish ]; then
      fm_true "$file" publish || continue
    fi
    dest=$(note_dest "$file") || return 1
    if [ -e "$out/$dest" ]; then
      printf 'two notes go to content/%s; one is %s\n' "$dest" "$(basename "$file")" >&2
      return 1
    fi
    base=$(basename "$file")
    case $(basename "$dest") in
      *" "*)
        printf 'warning: %s has spaces; set slug in front matter for a cleaner URL\n' "$base" >&2
        ;;
    esac
    mkdir -p "$out/$(dirname "$dest")" || return 1
    cp -p -- "$file" "$out/$dest" || return 1
    printf '%s\n' "$dest"
  done < <(each_note)
}

toml_quote() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '"%s"' "$s"
}

write_preview_config() {
  local src
  src=$(toml_quote "$1/content")
  cat > "$1/hugo.preview.toml" <<CONF
[[module.mounts]]
source = $src
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
CONF
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

# sync makes content/ an exact copy of the published vault notes: routed
# notes are written and anything in content/ no note produces is removed.
cmd_sync() {
  local tmp listed removed
  need rsync
  need_writing_dir
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/ns-blog-sync.XXXXXX")
  sync_tmp=$tmp
  trap 'rm -rf "$sync_tmp"' EXIT
  listed=$(stage "$tmp" publish)
  if [ -z "$listed" ]; then
    printf '%s\n' "no notes have publish true; content/ left alone"
    return 0
  fi
  mkdir -p content
  removed=$(comm -23 \
    <(cd content && find . -type f ! -name .DS_Store | sed 's|^\./||' | sort) \
    <(printf '%s\n' "$listed" | sort))
  rsync -a --delete --exclude .DS_Store -- "$tmp/" content/
  printf '%s\n' "$listed" | sed 's|^|wrote content/|'
  if [ -n "$removed" ]; then
    printf '%s\n' "$removed" | sed 's|^|removed content/|'
  fi
}

cmd_preview() {
  local stage_dir status
  need hugo
  need rsync
  need_writing_dir
  PORT=${PORT:-1313}
  case $PORT in
    ""|*[!0-9]*)
      printf 'PORT must be a number\n' >&2
      exit 1
      ;;
  esac
  if [ "$((10#$PORT))" -lt 1 ] || [ "$((10#$PORT))" -gt 65535 ]; then
    printf 'PORT must be from 1 to 65535\n' >&2
    exit 1
  fi
  stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/ns-blog-preview.XXXXXX")
  preview_dir=$stage_dir
  mkdir -p "$stage_dir/content" "$stage_dir/next"
  trap 'cleanup_preview' EXIT
  trap 'cleanup_preview; exit 130' INT
  trap 'cleanup_preview; exit 143' TERM
  refresh_preview "$stage_dir" 1
  write_preview_config "$stage_dir"
  hugo server -D --port "$PORT" --config "hugo.toml,$stage_dir/hugo.preview.toml" &
  hugo_pid=$!
  while kill -0 "$hugo_pid" 2>/dev/null; do
    sleep 1
    kill -0 "$hugo_pid" 2>/dev/null || break
    refresh_preview "$stage_dir" 0 || true
  done
  wait "$hugo_pid" || status=$?
  hugo_pid=
  exit "${status:-0}"
}

# refresh_preview DIR LOUD restages every vault note and syncs changed files
# into DIR/content, so new, edited, and deleted notes show without a restart.
refresh_preview() {
  local dir=$1 loud=$2 err
  rm -rf "$dir/next"
  mkdir -p "$dir/next"
  if ! err=$(stage "$dir/next" preview 2>&1 >/dev/null); then
    if [ "$err" != "${last_err:-}" ]; then
      printf '%s\n' "$err" >&2
    fi
    last_err=$err
    return 1
  fi
  if [ "$loud" -eq 1 ] && [ -n "$err" ]; then
    printf '%s\n' "$err" >&2
  fi
  last_err=
  rsync -a --delete -- "$dir/next/" "$dir/content/"
}

cleanup_preview() {
  trap - EXIT INT TERM
  if [ -n "${hugo_pid:-}" ] && kill -0 "$hugo_pid" 2>/dev/null; then
    kill "$hugo_pid" 2>/dev/null || true
    wait "$hugo_pid" 2>/dev/null || true
  fi
  if [ -n "${preview_dir:-}" ]; then
    rm -rf "$preview_dir"
  fi
}

case ${1:-} in
  new) cmd_new "${2:-}" ;;
  sync) cmd_sync ;;
  preview) cmd_preview ;;
  *) usage; exit 1 ;;
esac
