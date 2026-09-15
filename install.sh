#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
SERVICE_DIR="${HOME}/.config/systemd/user"
DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD 2>/dev/null || true)"

if [[ -z "$DOWNLOADS_DIR" ]]; then
  DOWNLOADS_DIR="${HOME}/Downloads"
fi

mkdir -p -- "$BIN_DIR" "$SERVICE_DIR"
install -m 0755 "$SOURCE_DIR/download-juggler.sh" "$BIN_DIR/download-juggler"

sed \
  -e "s|@EXECUTABLE@|$BIN_DIR/download-juggler|g" \
  -e "s|@WATCH_DIRECTORY@|$DOWNLOADS_DIR|g" \
  "$SOURCE_DIR/systemd/download-juggler.service" \
  > "$SERVICE_DIR/download-juggler.service"

printf 'Installed executable: %s\n' "$BIN_DIR/download-juggler"
printf 'Installed service:    %s\n' "$SERVICE_DIR/download-juggler.service"
printf '\nTo start automatic organization, run:\n'
printf '  systemctl --user daemon-reload\n'
printf '  systemctl --user enable --now download-juggler.service\n'
printf '\nNote: the current script organizes its own directory. For direct Downloads use,\n'
printf 'copy download-juggler.sh into %s and run it there.\n' "$DOWNLOADS_DIR"
