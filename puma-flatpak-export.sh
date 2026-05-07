#!/usr/bin/env bash
# puma-flatpak-export.sh — Export installed flatpak app IDs to a file
set -euo pipefail

die() { echo "Error: $1" >&2; exit 1; }

OUTPUT_FILE="$HOME/Documents/flatpak-list.txt"

command -v flatpak >/dev/null 2>&1 || die "flatpak is not installed"

mkdir -p "$HOME/Documents"

flatpak list --app --columns=application | sort > "$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_FILE")

echo "Exported $count flatpak app(s) to $OUTPUT_FILE"
echo ""
echo "To reinstall on another machine:"
echo "  flatpak install -y < $OUTPUT_FILE"
