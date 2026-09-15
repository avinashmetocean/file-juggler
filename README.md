# Download Juggler for Ubuntu

A lightweight Bash-based alternative to File Juggler for Ubuntu. The script organizes files in the directory where it is stored, making it especially convenient for keeping your `Downloads` folder tidy.

## Features

- Organizes existing files with a single command
- Watches for newly completed downloads in real time
- Includes a dry-run mode for safely previewing changes
- Sorts files into practical category folders
- Handles filenames containing spaces and special characters
- Avoids overwriting files by generating unique names
- Ignores temporary and incomplete browser downloads
- Never moves the organizer script itself
- Does not modify files already stored in subfolders
- Uses its own location instead of a hardcoded Downloads path

## File Categories

The script creates category folders only when they are needed.

- `Documents`: PDF, DOCX, TXT, EPUB, and similar files
- `Spreadsheets`: XLSX, CSV, ODS, TSV, and similar files
- `Presentations`: PPTX, ODP, KEY, and similar files
- `Images`: JPG, PNG, GIF, SVG, WEBP, HEIC, and similar files
- `Videos`: MP4, MKV, AVI, MOV, WEBM, and similar files
- `Audio`: MP3, WAV, FLAC, AAC, OGG, and similar files
- `Archives`: ZIP, RAR, 7Z, TAR, GZ, and similar files
- `Packages`: DEB, RPM, AppImage, and similar files
- `Disk-Images`: ISO and IMG files
- `Code`: Shell scripts, Python, JavaScript, JSON, YAML, HTML, CSS, and other source files
- `Torrents`: TORRENT files
- `Other`: Unknown extensions and files without extensions

## Requirements

For one-time organization and dry-run mode:

- Ubuntu or another Linux distribution
- Bash
- Standard utilities including `find`, `mv`, `mkdir`, `basename`, and `readlink`

For continuous watch mode:

- `inotify-tools`

Install the watch-mode dependency on Ubuntu:

```bash
sudo apt update
sudo apt install inotify-tools
```

## Installation

1. Download the `download-juggler.sh` script.
2. Move both the script and this README into your Downloads folder.
3. Open a terminal and change to that folder:

```bash
cd ~/Downloads
```

4. Make the script executable:

```bash
chmod +x download-juggler.sh
```

The script always organizes the folder in which the script itself is located. If your Downloads directory uses a different path or localized name, placing the script inside that directory is sufficient.

## Usage

### Display help

```bash
./download-juggler.sh --help
```

### Preview changes

Use dry-run mode first to see where files would be moved without changing anything:

```bash
./download-juggler.sh --dry-run
```

Example output:

```text
[DRY RUN] /home/user/Downloads/report.pdf -> /home/user/Downloads/Documents/report.pdf
[DRY RUN] /home/user/Downloads/photo.jpg -> /home/user/Downloads/Images/photo.jpg
```

### Organize existing files once

```bash
./download-juggler.sh --once
```

Because one-time organization is the default mode, this also works:

```bash
./download-juggler.sh
```

### Watch for new downloads

```bash
./download-juggler.sh --watch
```

The script first organizes existing files and then watches for new completed downloads. Press `Ctrl+C` to stop it.

Watch mode requires `inotifywait`, which is provided by the `inotify-tools` package.

### Quiet mode

Suppress normal status messages:

```bash
./download-juggler.sh --once --quiet
```

Options can be combined:

```bash
./download-juggler.sh --watch --quiet
```

## Command-Line Options

```text
--once       Organize existing files once, then exit. This is the default.
--watch      Keep watching the folder and organize new completed downloads.
--dry-run    Preview actions without moving files.
--quiet      Suppress normal status messages.
--directory   Organize a specified directory instead of the script folder.
-h, --help   Show the help message.
```

## Duplicate Filename Handling

The script never intentionally overwrites an existing destination file. If a file with the same name already exists, it creates a unique filename.

For example:

```text
report.pdf
report (1).pdf
report (2).pdf
```

## Incomplete Downloads

The following temporary download formats are ignored:

```text
*.crdownload
*.part
*.partial
*.tmp
*.download
```

This helps prevent the script from moving files before a browser or download manager has finished writing them.

## Customizing Categories

Open the script in a text editor:

```bash
nano ~/Downloads/download-juggler.sh
```

Find the `category_for()` function. Each `case` entry maps file extensions to a destination folder.

Example:

```bash
pdf|doc|docx|odt|rtf|txt|md|tex|epub|mobi)
  printf '%s' "Documents" ;;
```

To place Markdown files in a separate folder, remove `md` from the Documents entry and add a new rule before the final fallback rule:

```bash
md)
  printf '%s' "Markdown" ;;
```

Extension names should be written without a leading period. The script converts filenames to lowercase before matching, so uppercase and lowercase extensions are handled automatically.

After editing, verify the script syntax:

```bash
bash -n ~/Downloads/download-juggler.sh
```

No output means Bash found no syntax errors.

## Running Automatically After Login

You can configure the script as a user-level systemd service.

### 1. Create the service directory

```bash
mkdir -p ~/.config/systemd/user
```

### 2. Create the service file

```bash
nano ~/.config/systemd/user/download-juggler.service
```

Add the following content, replacing `%h/Downloads` if your Downloads directory has a different path:

```ini
[Unit]
Description=Download Juggler file organizer
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/Downloads/download-juggler.sh --watch --quiet
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

### 3. Enable and start the service

```bash
systemctl --user daemon-reload
systemctl --user enable --now download-juggler.service
```

### 4. Check its status

```bash
systemctl --user status download-juggler.service
```

### 5. View recent logs

```bash
journalctl --user -u download-juggler.service -n 50
```

### 6. Stop and disable it

```bash
systemctl --user disable --now download-juggler.service
```

If you move or rename the script after creating the service, update `ExecStart` in the service file and run `systemctl --user daemon-reload` again.

## Troubleshooting

### Permission denied

Make the script executable:

```bash
chmod +x ~/Downloads/download-juggler.sh
```

Alternatively, run it through Bash:

```bash
bash ~/Downloads/download-juggler.sh --once
```

### `inotifywait` command not found

Install `inotify-tools`:

```bash
sudo apt install inotify-tools
```

### Files are being organized in the wrong directory

The script organizes the directory containing the script, not necessarily `~/Downloads`. Move the script into the folder you want it to manage.

### A file was placed in `Other`

Its extension is not currently included in the `category_for()` rules. Add the extension to an existing category or create a new category rule.

### A newly downloaded file was not moved

Check the following:

1. Confirm that watch mode is running.
2. Confirm that `inotify-tools` is installed.
3. Make sure the file is directly inside the watched folder.
4. Check whether the filename ends in a temporary extension such as `.part` or `.crdownload`.
5. Run the script without `--quiet` to see status or error messages.

## Safety Notes

- Run `--dry-run` before the first real organization pass.
- The script moves files but does not inspect their contents.
- Existing subfolders are left unchanged.
- Unknown file types are moved into `Other`.
- Back up important files before substantially modifying the organization rules.
- Do not run the script with `sudo`; it is intended to manage files owned by your user account.

## Uninstallation

Stop and disable the user service first if you enabled it:

```bash
systemctl --user disable --now download-juggler.service
rm -f ~/.config/systemd/user/download-juggler.service
systemctl --user daemon-reload
```

Remove the script and README:

```bash
rm -f ~/Downloads/download-juggler.sh
rm -f ~/Downloads/README.md
```

Removing the script does not move files back to their original locations and does not delete the category folders.

## Repository Quick Start

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/download-juggler.git
cd download-juggler
```

Run the test suite:

```bash
bash tests/test.sh
```

For the simplest setup, copy the organizer into Downloads:

```bash
cp download-juggler.sh ~/Downloads/
chmod +x ~/Downloads/download-juggler.sh
~/Downloads/download-juggler.sh --dry-run
```

Replace `YOUR-USERNAME` with your GitHub username after publishing the repository.

## License

This script is provided as-is. You may use, modify, and distribute it for personal or organizational purposes.
