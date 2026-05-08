#!/usr/bin/env bash
# puma-tui-export.sh — Export all TUI app desktop entries and icons
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"
OUTPUT_DIR="$HOME/Documents/tui-apps-export"

die() { echo "Error: $1" >&2; exit 1; }

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/apps" "$OUTPUT_DIR/icons"

shopt -s nullglob
declare -a desktop_names=()
declare -a desktop_paths=()
for desktop in "$APPS_DIR"/*.desktop; do
    if grep -q 'Categories=ConsoleOnly;' "$desktop" 2>/dev/null; then
        desktop_names+=("$(basename "$desktop")")
        desktop_paths+=("$desktop")
    fi
done

if [[ ${#desktop_names[@]} -eq 0 ]]; then
    puma_style "No TUI apps found." --foreground yellow
    rm -rf "$OUTPUT_DIR"
    exit 0
fi

if [[ ${#desktop_names[@]} -gt 1 ]]; then
    puma_style "Select TUI apps to export (or press Enter for all):" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${desktop_names[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        selected="$(printf '%s\n' "${desktop_names[@]}")"
    fi
    IFS=$'\n' read -r -d '' -a chosen <<< "$selected" || true
else
    chosen=("${desktop_names[@]}")
fi

count=0
for name in "${chosen[@]}"; do
    for i in "${!desktop_names[@]}"; do
        if [[ "${desktop_names[$i]}" == "$name" ]]; then
            desktop="${desktop_paths[$i]}"
            cp "$desktop" "$OUTPUT_DIR/apps/$name"

            icon_path="$(grep -oP '^Icon=\K.*' "$desktop" 2>/dev/null || true)"
            if [[ -n "$icon_path" && -f "$icon_path" ]]; then
                cp "$icon_path" "$OUTPUT_DIR/icons/"
            fi

            puma_style "Exported: $name" --foreground green
            count=$((count + 1))
            break
        fi
    done
done

echo ""
tarball="$HOME/Documents/tui-apps-export.tar.gz"
puma_spin "Creating archive..." -- tar -czf "$tarball" -C "$OUTPUT_DIR" apps icons
rm -rf "$OUTPUT_DIR"

echo ""
puma_style "Exported $count TUI app(s) to $tarball" --bold --foreground green
echo ""
echo "To import on another machine:"
echo "  puma-tui-import.sh $tarball"
