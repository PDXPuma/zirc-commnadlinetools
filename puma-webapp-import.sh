#!/usr/bin/env bash
# puma-webapp-import.sh — Import webapp desktop entries and icons from an export
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 1 ]] && die "Usage: $(basename "$0") <webapps-export.tar.gz>"

tarball="$1"
[[ -f "$tarball" ]] || die "File not found: $tarball"

mkdir -p "$APPS_DIR" "$ICONS_DIR"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

puma_spin "Extracting archive..." -- tar -xzf "$tarball" -C "$tmpdir"

shopt -s nullglob
declare -a desktop_names=()
declare -a desktop_paths=()
for desktop in "$tmpdir/apps"/*.desktop; do
    desktop_names+=("$(basename "$desktop")")
    desktop_paths+=("$desktop")
done

if [[ ${#desktop_names[@]} -eq 0 ]]; then
    die "No webapps found in archive"
fi

if [[ ${#desktop_names[@]} -gt 1 ]]; then
    puma_style "Select webapps to import (or press Enter for all):" --bold
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

            icon_path="$(grep -oP '^Icon=\K.*' "$desktop" 2>/dev/null || true)"
            if [[ -n "$icon_path" ]]; then
                icon_name="$(basename "$icon_path")"
                if [[ -f "$tmpdir/icons/$icon_name" ]]; then
                    cp "$tmpdir/icons/$icon_name" "$ICONS_DIR/"
                    sed -i "s|^Icon=.*|Icon=$ICONS_DIR/$icon_name|" "$desktop"
                fi
            fi

            cp "$desktop" "$APPS_DIR/$name"
            chmod +x "$APPS_DIR/$name"
            puma_style "Installed: $name" --foreground green
            count=$((count + 1))
            break
        fi
    done
done

echo ""
puma_style "Imported $count webapp(s)." --bold --foreground green

if command -v update-desktop-database >/dev/null 2>&1; then
    puma_spin "Updating desktop database..." -- update-desktop-database "$APPS_DIR" 2>/dev/null && \
        puma_style "Desktop database updated." --foreground green
fi
