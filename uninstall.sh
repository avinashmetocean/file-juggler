#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now file-juggler.service 2>/dev/null || true
rm -f -- "${HOME}/.config/systemd/user/file-juggler.service"
rm -f -- "${HOME}/.local/bin/file-juggler"
systemctl --user daemon-reload 2>/dev/null || true
printf '%s\n' 'Download Juggler has been uninstalled.'
printf '%s\n' 'Previously organized files and category folders were left unchanged.'
