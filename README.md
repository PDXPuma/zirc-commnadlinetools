# Puma Command Line Tools

A collection of bash scripts for exporting and importing application configurations, game libraries, and desktop entries across Linux machines.

Enhanced with [gum](https://github.com/charmbracelet/gum) for interactive TUI. All scripts work without gum installed — they gracefully fall back to plain text mode.

## Quick Start

```bash
# Install all scripts
./install.sh

# Launch the interactive menu (requires gum for full experience)
puma.sh
```

### Installing gum

For the enhanced TUI experience, install gum:

```bash
# Arch Linux
sudo pacman -S gum

# Debian/Ubuntu
sudo apt install gum

# Fedora
sudo dnf install gum

# macOS (Homebrew)
brew install gum

# Go
go install github.com/charmbracelet/gum@latest
```

## All-in-One Export/Import

### `export-all.sh`

Export brew, flatpak, and steam to `~/Documents/puma-backup/`. With gum, you can select which subsystems to export interactively.

```bash
./export-all.sh
```

### `import-all.sh`

Import brew, flatpak, and steam from `~/Documents/puma-backup/` (or a custom path). With gum, you can select which subsystems to import.

```bash
./import-all.sh                          # uses ~/Documents/puma-backup/
./import-all.sh /path/to/puma-backup     # uses custom path
```

## Steam

### `puma-steam-export.sh`

Export installed Steam game AppIDs to `~/Documents/steam-games-list.txt`. Displays results in a formatted table with gum.

```bash
./puma-steam-export.sh
```

### `puma-steam-import-list.sh`

Install Steam games from an exported AppID list using SteamCMD. With gum, you can select which games to install and enter credentials via styled password input.

```bash
./puma-steam-import-list.sh
```

### `puma-steam-import.sh`

Import Steam game desktop entries and icons into `~/.local/share/`. For flatpak Steam, copies and rewrites desktop files to use the flatpak command.

```bash
./puma-steam-import.sh
```

## Flatpak

### `puma-flatpak-export.sh`

Export all installed flatpak app and addon IDs to `~/Documents/flatpak-list.txt`.

```bash
./puma-flatpak-export.sh
```

Reinstall on another machine:

```bash
flatpak install -y < ~/Documents/flatpak-list.txt
```

## Brew (macOS / Linux)

### `puma-brew-export.sh`

Export installed brew taps, formulae, and casks to `~/Documents/brew-list.txt`. Displays counts in a formatted table with gum.

```bash
./puma-brew-export.sh
```

### `puma-brew-import.sh`

Install brew taps, formulae, and casks from an exported list. With gum, you can select which packages to install.

```bash
./puma-brew-import.sh ~/Documents/brew-list.txt
```

## Web Apps (Chromium PWA)

### `puma-webapp.sh`

Create a Chromium flatpak PWA desktop entry with optional icon. With gum, prompts for all fields interactively if no arguments are provided.

```bash
./puma-webapp.sh <name> <url> [icon-url]
# or just:
./puma-webapp.sh
```

### `puma-webapp-export.sh`

Export all Chromium webapp desktop entries and icons. With gum, you can select which webapps to export.

```bash
./puma-webapp-export.sh
```

### `puma-webapp-import.sh`

Import webapp desktop entries and icons from a tarball export. With gum, you can select which webapps to import.

```bash
./puma-webapp-import.sh ~/Documents/webapps-export.tar.gz
```

## TUI Apps

### `puma-tui.sh`

Create a desktop entry that launches a TUI app inside a terminal emulator. With gum, you can pick from available terminals, confirm creation, and see styled prompts.

```bash
./puma-tui.sh <name> <command>
```

### `puma-tui-export.sh`

Export TUI app desktop entries and icons. With gum, you can select which apps to export.

```bash
./puma-tui-export.sh
```

### `puma-tui-import.sh`

Import TUI app desktop entries and icons from a tarball export. With gum, you can select which apps to import.

```bash
./puma-tui-import.sh ~/Documents/tui-apps-export.tar.gz
```

## Utilities

### `puma-yt-live.sh`

Check if a YouTube channel is currently live. With gum, prompts for the channel handle if not provided, shows a spinner while checking, and asks for confirmation before opening in mpv.

```bash
./puma-yt-live.sh <username>
# or just:
./puma-yt-live.sh
```

Requires: `yt-dlp`, `mpv`, and a clipboard tool (`wl-copy`, `xclip`, or `xsel`).

## Interactive Menu

### `puma.sh`

Launch the central interactive menu. Provides a searchable, filterable TUI for accessing all Puma tools without remembering individual script names. Type to filter options instantly.

```bash
./puma.sh
# or after install:
puma.sh
```

## Shared Library

### `puma-lib.sh`

Internal helper library that provides gum wrapper functions with graceful fallback:

- `puma_spin` — Animated spinner for long operations
- `puma_confirm` — Yes/no confirmation prompts
- `puma_input` — Styled text input (supports `--password`)
- `puma_choose` — Interactive multi-select menus
- `puma_style` — Colored/bold text formatting
- `puma_table` — Formatted table output
- `puma_format` — Markdown-style text rendering

All functions work without gum installed, degrading to plain terminal behavior.
