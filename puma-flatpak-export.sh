#!/usr/bin/env bash
# puma-flatpak-export.sh — Export installed flatpak app IDs to a file
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

OUTPUT_FILE="$HOME/Documents/flatpak-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

command -v flatpak >/dev/null 2>&1 || die "flatpak is not installed"

mkdir -p "$HOME/Documents"

puma_spin "Exporting flatpak apps..." -- flatpak list --app --columns=application | sort > "$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_FILE")

echo ""
puma_style "Exported $count flatpak app(s) to $OUTPUT_FILE" --bold --foreground green
echo ""
echo "To reinstall on another machine:"
echo "  flatpak install -y < $OUTPUT_FILE"
