#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

cp "$PROJECT_DIR/file-juggler.sh" "$TEST_DIR/file-juggler.sh"
chmod +x "$TEST_DIR/file-juggler.sh"

touch "$TEST_DIR/report.pdf"
touch "$TEST_DIR/photo.JPG"
touch "$TEST_DIR/archive.zip"
touch "$TEST_DIR/program.py"
touch "$TEST_DIR/unfinished.crdownload"
touch "$TEST_DIR/noextension"

"$TEST_DIR/file-juggler.sh" --once --quiet

test -f "$TEST_DIR/Documents/report.pdf"
test -f "$TEST_DIR/Images/photo.JPG"
test -f "$TEST_DIR/Archives/archive.zip"
test -f "$TEST_DIR/Code/program.py"
test -f "$TEST_DIR/Other/noextension"
test -f "$TEST_DIR/unfinished.crdownload"
test -f "$TEST_DIR/file-juggler.sh"

# Confirm duplicate-safe naming.
touch "$TEST_DIR/report.pdf"
"$TEST_DIR/file-juggler.sh" --once --quiet
test -f "$TEST_DIR/Documents/report (1).pdf"

printf '%s\n' 'All tests passed.'
