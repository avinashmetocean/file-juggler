# Contributing

Contributions are welcome. Please keep changes focused, portable, and safe for files in a user's Downloads directory.

## Development setup

Clone the repository and enter it:

```bash
git clone https://github.com/YOUR-USERNAME/download-juggler.git
cd download-juggler
```

Check Bash syntax:

```bash
bash -n download-juggler.sh
bash -n install.sh
bash -n uninstall.sh
```

Run the test suite:

```bash
bash tests/test.sh
```

## Contribution guidelines

1. Create a branch for the change.
2. Add or update tests when behavior changes.
3. Run syntax checks and tests locally.
4. Update the README and changelog when appropriate.
5. Submit a pull request with a concise description and test results.

## Safety expectations

- Do not overwrite destination files.
- Do not process incomplete downloads.
- Do not require root access for normal operation.
- Quote shell variables that contain paths or filenames.
- Preserve support for spaces and unusual characters in filenames.
