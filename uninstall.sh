#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now download-juggler.service 2>/dev/null || true
rm -f -- "${HOME}/.config/systemd/user/download-juggler.service"
rm -f -- "${HOME}/.local/bin/download-juggler"
systemctl --user daemon-reload 2>/dev/null || true
printf '%s\n' 'Download Juggler has been uninstalled.'
printf '%s\n' 'Previously organized files and category folders were left unchanged.'
