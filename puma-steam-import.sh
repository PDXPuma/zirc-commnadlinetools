#!/usr/bin/env bash
# puma-steam-import.sh — Import Steam flatpak game desktop entries and icons
# into ~/.local/share/applications and ~/.local/share/icons
set -euo pipefail

STEAM_FLATPAK="$HOME/.var/app/com.valvesoftware.Steam"
SRC_APPS="$STEAM_FLATPAK/data/applications"
SRC_ICONS="$STEAM_FLATPAK/data/icons/hicolor"

DEST_APPS="$HOME/.local/share/applications"
DEST_ICONS="$HOME/.local/share/icons/hicolor"

FLATPAK_CMD="flatpak run com.valvesoftware.Steam"

die() { echo "Error: $1" >&2; exit 1; }

[[ -d "$SRC_APPS" ]]   || die "Steam flatpak applications dir not found: $SRC_APPS"
[[ -d "$SRC_ICONS" ]]  || die "Steam flatpak icons dir not found: $SRC_ICONS"

mkdir -p "$DEST_APPS" "$DEST_ICONS"

# --- Desktop files ---
apps_copied=0
apps_skipped=0

shopt -s nullglob
for src in "$SRC_APPS"/*.desktop; do
    name="$(basename "$src")"
    dest="$DEST_APPS/$name"

    # Replace Exec=steam with Exec=flatpak run com.valvesoftware.Steam
    sed "s|^Exec=steam |Exec=${FLATPAK_CMD} |" "$src" > "$dest"
    chmod +x "$dest"
    echo "Installed desktop: $name"
    apps_copied=$((apps_copied + 1))
done

# --- Icons (preserve hicolor size/apps structure) ---
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
echo "Done. $apps_copied desktop file(s) installed, $icons_copied icon(s) copied."

# Refresh desktop database if available
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DEST_APPS" 2>/dev/null && echo "Desktop database updated."
fi
