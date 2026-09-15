#!/usr/bin/env bash
# download-juggler.sh
# A lightweight File Juggler-style organizer for Ubuntu.
# Place this script inside your Downloads folder.

set -u

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
TARGET_DIR="$(dirname "$SCRIPT_PATH")"
MODE="once"
DRY_RUN=0
QUIET=0

usage() {
  cat <<'EOF'
Usage: ./download-juggler.sh [OPTIONS]

Organizes files in the same folder as this script.

Options:
  --once       Organize existing files once, then exit. This is the default.
  --watch      Keep watching the folder and organize new completed downloads.
  --dry-run    Preview actions without moving files.
  --quiet      Suppress normal status messages.
  -h, --help   Show this help message.

Examples:
  chmod +x download-juggler.sh
  ./download-juggler.sh --dry-run
  ./download-juggler.sh --once
  ./download-juggler.sh --watch
EOF
}

log() {
  if [[ "$QUIET" -eq 0 ]]; then
    printf '%s\n' "$*"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --once) MODE="once" ;;
    --watch) MODE="watch" ;;
    --dry-run) DRY_RUN=1 ;;
    --quiet) QUIET=1 ;;
    --directory)
      shift
      [[ $# -gt 0 ]] || { printf "Missing path for --directory\n" >&2; exit 2; }
      TARGET_DIR="$(readlink -f -- "$1")"
      [[ -d "$TARGET_DIR" ]] || { printf "Directory not found: %s\n" "$TARGET_DIR" >&2; exit 2; }
      ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

category_for() {
  local filename="$1"
  local lower="${filename,,}"
  local ext="${lower##*.}"

  # Files without an extension
  if [[ "$lower" != *.* ]]; then
    printf '%s' "Other"
    return
  fi

  case "$ext" in
    pdf|doc|docx|odt|rtf|txt|md|tex|epub|mobi)
      printf '%s' "Documents" ;;
    xls|xlsx|ods|csv|tsv)
      printf '%s' "Spreadsheets" ;;
    ppt|pptx|odp|key)
      printf '%s' "Presentations" ;;
    jpg|jpeg|png|gif|webp|bmp|tif|tiff|svg|heic|avif)
      printf '%s' "Images" ;;
    mp4|mkv|avi|mov|webm|flv|wmv|m4v|mpeg|mpg)
      printf '%s' "Videos" ;;
    mp3|wav|flac|aac|ogg|m4a|opus|wma)
      printf '%s' "Audio" ;;
    zip|rar|7z|tar|gz|bz2|xz|tgz|tbz2|txz)
      printf '%s' "Archives" ;;
    deb|rpm|appimage|snap|flatpakref)
      printf '%s' "Packages" ;;
    iso|img)
      printf '%s' "Disk-Images" ;;
    sh|bash|zsh|fish|py|js|ts|jsx|tsx|java|c|h|cpp|hpp|cs|go|rs|rb|php|pl|lua|sql|html|htm|css|scss|json|xml|yaml|yml|toml)
      printf '%s' "Code" ;;
    torrent)
      printf '%s' "Torrents" ;;
    *)
      printf '%s' "Other" ;;
  esac
}

unique_destination() {
  local directory="$1"
  local filename="$2"
  local candidate="$directory/$filename"
  local stem ext n

  if [[ ! -e "$candidate" ]]; then
    printf '%s' "$candidate"
    return
  fi

  if [[ "$filename" == *.* && "$filename" != .* ]]; then
    stem="${filename%.*}"
    ext=".${filename##*.}"
  else
    stem="$filename"
    ext=""
  fi

  n=1
  while [[ -e "$directory/${stem} ($n)${ext}" ]]; do
    ((n++))
  done
  printf '%s' "$directory/${stem} ($n)${ext}"
}

organize_file() {
  local source="$1"
  local filename category destination_dir destination

  [[ -f "$source" ]] || return 0

  filename="$(basename "$source")"

  # Never move this script or temporary/incomplete download files.
  [[ "$(readlink -f "$source")" == "$SCRIPT_PATH" ]] && return 0
  case "${filename,,}" in
    *.crdownload|*.part|*.partial|*.tmp|*.download) return 0 ;;
  esac

  category="$(category_for "$filename")"
  destination_dir="$TARGET_DIR/$category"
  destination="$(unique_destination "$destination_dir" "$filename")"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[DRY RUN] %q -> %q\n' "$source" "$destination"
    return 0
  fi

  mkdir -p -- "$destination_dir"
  if mv -- "$source" "$destination"; then
    log "Moved: $filename -> $category/$(basename "$destination")"
  else
    printf 'Failed to move: %s\n' "$source" >&2
    return 1
  fi
}

organize_existing() {
  local file
  while IFS= read -r -d '' file; do
    organize_file "$file"
  done < <(find "$TARGET_DIR" -maxdepth 1 -type f -print0)
}

watch_folder() {
  if ! command -v inotifywait >/dev/null 2>&1; then
    printf '%s\n' "The --watch option requires inotifywait." >&2
    printf '%s\n' "Install it with: sudo apt install inotify-tools" >&2
    exit 1
  fi

  organize_existing
  log "Watching: $TARGET_DIR"
  log "Press Ctrl+C to stop."

  # close_write catches completed writes; moved_to catches files moved into Downloads.
  while IFS= read -r -d '' file; do
    # A small delay helps browsers finish renaming temporary downloads.
    sleep 1
    organize_file "$file"
  done < <(inotifywait -m -q -e close_write -e moved_to --format '%w%f%0' --no-newline "$TARGET_DIR")
}

log "Download Juggler folder: $TARGET_DIR"

case "$MODE" in
  once) organize_existing ;;
  watch) watch_folder ;;
esac
