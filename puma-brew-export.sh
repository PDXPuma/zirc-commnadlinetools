#!/usr/bin/env bash
# puma-brew-export.sh — Export installed brew packages and casks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

OUTPUT_FILE="$HOME/Documents/brew-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

command -v brew >/dev/null 2>&1 || die "brew is not installed"

mkdir -p "$HOME/Documents"

puma_spin "Exporting taps..." -- brew tap 2>/dev/null > /dev/null || true
puma_spin "Exporting formulae..." -- brew list --formula 2>/dev/null > /dev/null || true
puma_spin "Exporting casks..." -- brew list --cask 2>/dev/null > /dev/null || true

{
    echo "# Taps"
    brew tap 2>/dev/null || true
    echo ""
    echo "# Formulae"
    brew list --formula 2>/dev/null || true
    echo ""
    echo "# Casks"
    brew list --cask 2>/dev/null || true
} > "$OUTPUT_FILE"

taps=$(brew tap 2>/dev/null | wc -l)
formulas=$(brew list --formula 2>/dev/null | wc -l)
casks=$(brew list --cask 2>/dev/null | wc -l)

echo ""
printf "Taps\t%s\nFormulae\t%s\nCasks\t%s\n" "$taps" "$formulas" "$casks" | puma_table "Category" "Count"
echo ""
puma_style "Exported to $OUTPUT_FILE" --bold --foreground green
echo ""
echo "To reinstall on another machine:"
echo "  puma-brew-import.sh $OUTPUT_FILE"
