#!/usr/bin/env bash
# puma-tui-import.sh — Import TUI app desktop entries and icons from an export
set -euo pipefail

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 1 ]] && die "Usage: $(basename "$0") <tui-apps-export.tar.gz>"

tarball="$1"
[[ -f "$tarball" ]] || die "File not found: $tarball"

mkdir -p "$APPS_DIR" "$ICONS_DIR"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tar -xzf "$tarball" -C "$tmpdir"

count=0
shopt -s nullglob
for desktop in "$tmpdir/apps"/*.desktop; do
    name="$(basename "$desktop")"

    icon_path="$(grep -oP '^Icon=\K.*' "$desktop" 2>/dev/null || true)"
    if [[ -n "$icon_path" && "$icon_path" != "utilities-terminal" ]]; then
        icon_name="$(basename "$icon_path")"
        if [[ -f "$tmpdir/icons/$icon_name" ]]; then
            cp "$tmpdir/icons/$icon_name" "$ICONS_DIR/"
            sed -i "s|^Icon=.*|Icon=$ICONS_DIR/$icon_name|" "$desktop"
        fi
    fi

    cp "$desktop" "$APPS_DIR/$name"
    chmod +x "$APPS_DIR/$name"
    echo "Installed: $name"
    count=$((count + 1))
done

if [[ $count -eq 0 ]]; then
    die "No TUI apps found in archive"
fi

echo ""
echo "Imported $count TUI app(s)."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" 2>/dev/null && echo "Desktop database updated."
fi
