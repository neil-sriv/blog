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

version_ge() {
  local IFS=. i av bv
  local -a a b
  read -r -a a <<< "$1"
  read -r -a b <<< "$2"
  for i in 0 1 2; do
    av=${a[i]:-0}
    bv=${b[i]:-0}
    if [ "$av" -gt "$bv" ]; then
      return 0
    fi
    if [ "$av" -lt "$bv" ]; then
      return 1
    fi
  done
  return 0
}

mount_pattern_key() {
  local ver
  ver=$(hugo version | sed -n 's/.*v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')
  [ -n "$ver" ] || {
    printf 'could not parse hugo version\n' >&2
    exit 1
  }
  if version_ge "$ver" 0.153.0; then
    printf '%s' files
  else
    printf '%s' includeFiles
  fi
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

note_names() {
  local file want=$1 base
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    if has_front_matter "$file"; then
      [ "$want" = eligible ] || continue
    else
      [ "$want" = skipped ] || continue
    fi
    base=$(basename "$file")
    printf '%s\n' "$base"
  done < <(each_note) | sort
}

publish_is_true() {
  local file=$1 line val closer="" started=0 compact
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
      ""|[[:space:]]*|\#*) continue ;;
    esac
    line=${line%% #*}
    compact=${line//[[:space:]]/}
    case $compact in
      publish=true|publish:true|publish=\"true\"|publish:\"true\"|publish=\'true\'|publish:\'true\')
        return 0
        ;;
      publish=*|publish:*)
        return 1
        ;;
    esac
  done < "$file"
  return 1
}

warn_spaces() {
  local name
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    case $name in
      *" "*)
        printf 'warning: %s has spaces; set slug in front matter for a cleaner URL\n' "$name" >&2
        ;;
    esac
  done
}

added_names() {
  local old=$1 new=$2
  [ -n "$new" ] || return 0
  if [ -z "$old" ]; then
    printf '%s\n' "$new"
    return 0
  fi
  comm -13 <(printf '%s\n' "$old") <(printf '%s\n' "$new")
}

toml_quote() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '"%s"' "$s"
}

glob_escape() {
  local s=$1 i=0 c out=""
  while [ "$i" -lt "${#s}" ]; do
    c=${s:i:1}
    case $c in
      \\|\*|\[|\]|\?|\{|\}) out="$out\\$c" ;;
      *) out="$out$c" ;;
    esac
    i=$((i + 1))
  done
  printf '%s' "$out"
}

write_preview_config() {
  local key src name quoted patterns="" tmp
  key=$(mount_pattern_key)
  src=$(toml_quote "$WRITING_DIR")
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    quoted=$(toml_quote "$(glob_escape "$name")")
    if [ -n "$patterns" ]; then
      patterns="$patterns, $quoted"
    else
      patterns=$quoted
    fi
  done < <(note_names eligible)
  if [ -z "$patterns" ]; then
    patterns='".no-vault-notes"'
  fi
  tmp=hugo.preview.toml.tmp
  cat > "$tmp" <<EOF
[[module.mounts]]
source = $src
target = "content/tech"
$key = [$patterns]

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
  mv "$tmp" hugo.preview.toml
}

print_skips() {
  local name
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    printf 'skip %s\n' "$name"
  done
}

cleanup_preview() {
  trap - EXIT INT TERM
  if [ -n "${hugo_pid:-}" ] && kill -0 "$hugo_pid" 2>/dev/null; then
    kill "$hugo_pid" 2>/dev/null || true
    wait "$hugo_pid" 2>/dev/null || true
  fi
  rm -f hugo.preview.toml hugo.preview.toml.tmp
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
  shopt -s nullglob
  for file in "$WRITING_DIR"/*.md; do
    [ -f "$file" ] || continue
    [ -L "$file" ] && continue
    publish_is_true "$file" || continue
    base=$(basename "$file")
    warn_spaces <<< "$base"
    mkdir -p content/tech
    rsync -a -- "$file" content/tech/
    printf '%s\n' "content/tech/$base"
    copied=1
  done
  [ "$copied" -eq 1 ] || printf '%s\n' "no posts copied"
}

cmd_preview() {
  local prev_e prev_s cur_e cur_s added status
  need hugo
  need_writing_dir
  trap cleanup_preview EXIT
  trap 'cleanup_preview; exit 130' INT
  trap 'cleanup_preview; exit 143' TERM
  prev_e=$(note_names eligible)
  prev_s=$(note_names skipped)
  write_preview_config
  print_skips <<< "$prev_s"
  warn_spaces <<< "$prev_e"
  PORT=${PORT:-1313}
  case $PORT in
    *[!0-9]*)
      printf 'PORT must be a number\n' >&2
      exit 1
      ;;
  esac
  if [ "$((10#$PORT))" -lt 1 ] || [ "$((10#$PORT))" -gt 65535 ]; then
    printf 'PORT must be from 1 to 65535\n' >&2
    exit 1
  fi
  hugo server -D --port "$PORT" --config hugo.toml,hugo.preview.toml &
  hugo_pid=$!
  while kill -0 "$hugo_pid" 2>/dev/null; do
    sleep 1
    kill -0 "$hugo_pid" 2>/dev/null || break
    cur_e=$(note_names eligible)
    cur_s=$(note_names skipped)
    if [ "$cur_e" != "$prev_e" ]; then
      write_preview_config
      added=$(added_names "$prev_e" "$cur_e")
      warn_spaces <<< "$added"
      prev_e=$cur_e
    fi
    if [ "$cur_s" != "$prev_s" ]; then
      added=$(added_names "$prev_s" "$cur_s")
      print_skips <<< "$added"
      prev_s=$cur_s
    fi
  done
  wait "$hugo_pid" || status=$?
  hugo_pid=
  exit "${status:-0}"
}

case ${1:-} in
  new) cmd_new "${2:-}" ;;
  sync) cmd_sync ;;
  preview) cmd_preview ;;
  *) usage; exit 1 ;;
esac
