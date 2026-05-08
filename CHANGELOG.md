# Changelog

## [Unreleased]

### Added
- `puma.sh` — Central interactive menu with `gum filter` for searchable command selection
- `puma-lib.sh` — Shared helper library with gum wrappers and graceful fallback (`puma_spin`, `puma_confirm`, `puma_input`, `puma_choose`, `puma_style`, `puma_table`, `puma_format`, `puma_filter`)

### Changed
- `install.sh` — Overwrite confirmation, styled output, gum availability check
- `export-all.sh` — Interactive subsystem selection with "Select All" option, styled output
- `import-all.sh` — Interactive subsystem selection with "Select All" option, styled output
- `puma-brew-export.sh` — Spinners per export phase, table output for counts
- `puma-brew-import.sh` — Selective package installation with "Select All", spinners per package, styled results
- `puma-flatpak-export.sh` — Spinner, styled summary
- `puma-steam-export.sh` — Game names alongside AppIDs, table display, "Select All" for selective export
- `puma-steam-import.sh` — Detection spinner, spinners per desktop file install
- `puma-steam-import-list.sh` — `gum input --password` for credentials, "Select All" for game selection, spinners per install
- `puma-tui.sh` — Terminal chooser via `gum choose`, confirmation prompt, styled prompts, stdin support for automation
- `puma-tui-export.sh` — "Select All" for selective app export, archive spinner
- `puma-tui-import.sh` — "Select All" for selective app import, extraction spinner
- `puma-webapp.sh` — Interactive mode (no args required), confirmation prompt, styled prompts
- `puma-webapp-export.sh` — "Select All" for selective app export, archive spinner
- `puma-webapp-import.sh` — "Select All" for selective app import, extraction spinner
- `puma-yt-live.sh` — Interactive handle input, spinner while checking, confirm before opening in mpv
- `README.md` — Full documentation for gum features, install instructions, interactive menu

### Fixed
- `puma_spin` — Fixed `gum confirm` prompt flag (positional, not `--prompt`)
- `puma_spin` — Fixed `bash -c` argument passing to preserve special characters in URLs
- `puma_spin` — Removed infinite spinner when called without a command
- `puma_table` — Replaced unreliable `gum table` with printf-based tabular output
- `puma.sh` — Menu no longer crashes when called scripts exit non-zero
- `puma.sh` — Fixed variable name bug in `run_create_webapp` (`$URL` → `$url`)

## [Previous]

### Changed
- `puma-steam-export.sh` — Auto-detects flatpak or native Steam installations
- `puma-steam-import-list.sh` — Auto-detects flatpak or native Steam installations
- `puma-steam-import.sh` — Auto-detects flatpak or native Steam; exits early for native (integration is automatic)

### Added
- `export-all.sh` — Export brew, flatpak, and steam to `~/Documents/puma-backup/` using existing individual scripts
- `import-all.sh` — Import brew, flatpak, and steam from `~/Documents/puma-backup/` (or custom path) using existing individual scripts
- `README.md` — Documentation for all scripts in the collection
- `puma-flatpak-export.sh` — Export all installed flatpak apps and addons to `~/Documents/flatpak-list.txt`
- `puma-steam-export.sh` — Export Steam game AppIDs to `~/Documents/steam-games-list.txt`
- `puma-steam-import-list.sh` — Install Steam games from an exported AppID list using SteamCMD
- `puma-webapp-export.sh` — Export Chromium webapp desktop entries and icons to `~/Documents/webapps-export.tar.gz`
- `puma-webapp-import.sh` — Import webapp desktop entries and icons from a tarball export
- `puma-tui-export.sh` — Export TUI app desktop entries and icons to `~/Documents/tui-apps-export.tar.gz`
- `puma-tui-import.sh` — Import TUI app desktop entries and icons from a tarball export
- `puma-brew-export.sh` — Export brew taps, formulae, and casks to `~/Documents/brew-list.txt`
- `puma-brew-import.sh` — Install brew taps, formulae, and casks from an export list

### Fixed
- `puma-steam-export.sh` — Fixed grep pattern to handle leading tab in `appmanifest_*.acf` files (was exporting zero games)
- `puma-flatpak-export.sh` — Changed from `--app` only to include `addon` types alongside `app` types
