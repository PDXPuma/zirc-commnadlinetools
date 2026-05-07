#!/usr/bin/env bash
# puma-webapp-export.sh — Export all Chromium webapp desktop entries and icons
set -euo pipefail

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"
OUTPUT_DIR="$HOME/Documents/webapps-export"

die() { echo "Error: $1" >&2; exit 1; }

command -v flatpak >/dev/null 2>&1 || die "flatpak is not installed"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/apps" "$OUTPUT_DIR/icons"

count=0
shopt -s nullglob
for desktop in "$APPS_DIR"/*.desktop; do
    if grep -q 'Exec=flatpak run org.chromium.Chromium --app=' "$desktop" 2>/dev/null; then
        name="$(basename "$desktop")"
        cp "$desktop" "$OUTPUT_DIR/apps/$name"

        icon_path="$(grep -oP '^Icon=\K.*' "$desktop" 2>/dev/null || true)"
        if [[ -n "$icon_path" && -f "$icon_path" ]]; then
            cp "$icon_path" "$OUTPUT_DIR/icons/"
        fi

        echo "Exported: $name"
        count=$((count + 1))
    fi
done

if [[ $count -eq 0 ]]; then
    echo "No webapps found."
    rm -rf "$OUTPUT_DIR"
    exit 0
fi

tarball="$HOME/Documents/webapps-export.tar.gz"
tar -czf "$tarball" -C "$OUTPUT_DIR" apps icons
rm -rf "$OUTPUT_DIR"

echo ""
echo "Exported $count webapp(s) to $tarball"
echo ""
echo "To import on another machine:"
echo "  puma-webapp-import.sh $tarball"
