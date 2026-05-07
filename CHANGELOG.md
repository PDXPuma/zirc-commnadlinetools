# Changelog

## [Unreleased]

### Changed
- `puma-steam-export.sh` — Auto-detects flatpak or native Steam installations
- `puma-steam-import-list.sh` — Auto-detects flatpak or native Steam installations
- `puma-steam-import.sh` — Auto-detects flatpak or native Steam; exits early for native (integration is automatic)

### Added
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
