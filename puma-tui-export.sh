#!/usr/bin/env bash
# puma-tui-export.sh — Export all TUI app desktop entries and icons
set -euo pipefail

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"
OUTPUT_DIR="$HOME/Documents/tui-apps-export"

die() { echo "Error: $1" >&2; exit 1; }

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/apps" "$OUTPUT_DIR/icons"

count=0
shopt -s nullglob
for desktop in "$APPS_DIR"/*.desktop; do
    if grep -q 'Categories=ConsoleOnly;' "$desktop" 2>/dev/null; then
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
    echo "No TUI apps found."
    rm -rf "$OUTPUT_DIR"
    exit 0
fi

tarball="$HOME/Documents/tui-apps-export.tar.gz"
tar -czf "$tarball" -C "$OUTPUT_DIR" apps icons
rm -rf "$OUTPUT_DIR"

echo ""
echo "Exported $count TUI app(s) to $tarball"
echo ""
echo "To import on another machine:"
echo "  puma-tui-import.sh $tarball"
