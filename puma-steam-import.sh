#!/usr/bin/env bash
# puma-steam-import.sh — Import Steam game desktop entries and icons
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

die() { echo "Error: $1" >&2; exit 1; }

if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam; then
    STEAM_TYPE="flatpak"
    STEAM_FLATPAK="$HOME/.var/app/com.valvesoftware.Steam"
    SRC_APPS="$STEAM_FLATPAK/data/applications"
    SRC_ICONS="$STEAM_FLATPAK/data/icons/hicolor"
elif [[ -d "$HOME/.local/share/Steam" ]] || command -v steam >/dev/null 2>&1; then
    STEAM_TYPE="native"
    STEAM_DIR="$HOME/.local/share/Steam"
    SRC_APPS="$STEAM_DIR/data/applications"
    SRC_ICONS="$STEAM_DIR/data/icons/hicolor"
else
    die "No Steam installation found (flatpak or native)"
fi

DEST_APPS="$HOME/.local/share/applications"
DEST_ICONS="$HOME/.local/share/icons/hicolor"

puma_style "Detected Steam: $STEAM_TYPE" --bold

if [[ "$STEAM_TYPE" == "native" ]]; then
    puma_style "Native Steam integrates desktop entries and icons automatically." --foreground cyan
    puma_style "No import needed." --foreground green
    exit 0
fi

[[ -d "$SRC_APPS" ]]   || die "Steam flatpak applications dir not found: $SRC_APPS"
[[ -d "$SRC_ICONS" ]]  || die "Steam flatpak icons dir not found: $SRC_ICONS"

FLATPAK_CMD="flatpak run com.valvesoftware.Steam"

mkdir -p "$DEST_APPS" "$DEST_ICONS"

# --- Desktop files ---
apps_copied=0
shopt -s nullglob
for src in "$SRC_APPS"/*.desktop; do
    name="$(basename "$src")"
    dest="$DEST_APPS/$name"
    puma_spin "Installing desktop: $name" -- sed "s|^Exec=steam |Exec=${FLATPAK_CMD} |" "$src" > "$dest"
    chmod +x "$dest"
    apps_copied=$((apps_copied + 1))
done

# --- Icons ---
icons_copied=0
for size_dir in "$SRC_ICONS"/*/; do
    size="$(basename "$size_dir")"
    src_apps_dir="$size_dir/apps"
    [[ -d "$src_apps_dir" ]] || continue
    dest_apps_dir="$DEST_ICONS/$size/apps"
    mkdir -p "$dest_apps_dir"
    for icon in "$src_apps_dir"/*; do
        [[ -f "$icon" ]] || continue
        cp "$icon" "$dest_apps_dir/"
        icons_copied=$((icons_copied + 1))
    done
done

echo ""
puma_style "Done. $apps_copied desktop file(s) installed, $icons_copied icon(s) copied." --bold --foreground green

if command -v update-desktop-database >/dev/null 2>&1; then
    puma_spin "Updating desktop database..." -- update-desktop-database "$DEST_APPS" 2>/dev/null && \
        puma_style "Desktop database updated." --foreground green
fi
