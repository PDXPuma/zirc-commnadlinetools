# Puma Command Line Tools

A collection of bash scripts for exporting and importing application configurations, game libraries, and desktop entries across Linux machines.

## All-in-One Export/Import

### `export-all.sh`

Export brew, flatpak, and steam to `~/Documents/puma-backup/`. Runs the individual export scripts and collects all output files into a single directory you can copy to a new machine.

```bash
./export-all.sh
```

### `import-all.sh`

Import brew, flatpak, and steam from `~/Documents/puma-backup/` (or a custom path). Installs desktop entries/icons for Steam and uses SteamCMD to download games (prompts for credentials).

```bash
./import-all.sh                          # uses ~/Documents/puma-backup/
./import-all.sh /path/to/puma-backup     # uses custom path
```

## Steam

### `puma-steam-export.sh`

Export installed Steam game AppIDs to `~/Documents/steam-games-list.txt`.

Auto-detects flatpak or native Steam installations.

```bash
./puma-steam-export.sh
```

### `puma-steam-import-list.sh`

Install Steam games from an exported AppID list using SteamCMD. Prompts for Steam credentials.

```bash
./puma-steam-import-list.sh
```

### `puma-steam-import.sh`

Import Steam game desktop entries and icons into `~/.local/share/`. For flatpak Steam, copies and rewrites desktop files to use the flatpak command. For native Steam, exits early since integration is automatic.

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

Export installed brew taps, formulae, and casks to `~/Documents/brew-list.txt`.

```bash
./puma-brew-export.sh
```

### `puma-brew-import.sh`

Install brew taps, formulae, and casks from an exported list.

```bash
./puma-brew-import.sh ~/Documents/brew-list.txt
```

## Web Apps (Chromium PWA)

### `puma-webapp.sh`

Create a Chromium flatpak PWA desktop entry with optional icon.

```bash
./puma-webapp.sh <name> <url> [icon-url]
```

### `puma-webapp-export.sh`

Export all Chromium webapp desktop entries and icons to `~/Documents/webapps-export.tar.gz`.

```bash
./puma-webapp-export.sh
```

### `puma-webapp-import.sh`

Import webapp desktop entries and icons from a tarball export.

```bash
./puma-webapp-import.sh ~/Documents/webapps-export.tar.gz
```

## TUI Apps

### `puma-tui.sh`

Create a desktop entry that launches a TUI app inside a terminal emulator. Auto-detects available terminals (kitty, alacritty, foot, wezterm, xterm, etc.).

```bash
./puma-tui.sh <name> <command>
```

### `puma-tui-export.sh`

Export all TUI app desktop entries and icons (identified by `Categories=ConsoleOnly;`) to `~/Documents/tui-apps-export.tar.gz`.

```bash
./puma-tui-export.sh
```

### `puma-tui-import.sh`

Import TUI app desktop entries and icons from a tarball export.

```bash
./puma-tui-import.sh ~/Documents/tui-apps-export.tar.gz
```

## Utilities

### `puma-yt-live.sh`

Check if a YouTube channel is currently live. If so, copies the stream URL to the clipboard and opens it in mpv.

```bash
./puma-yt-live.sh <username>
```

Requires: `yt-dlp`, `mpv`, and a clipboard tool (`wl-copy`, `xclip`, or `xsel`).
