#!/usr/bin/env bash
# puma-brew-export.sh — Export installed brew packages and casks
set -euo pipefail

OUTPUT_FILE="$HOME/Documents/brew-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

command -v brew >/dev/null 2>&1 || die "brew is not installed"

mkdir -p "$HOME/Documents"

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

echo "Exported $taps tap(s), $formulas formula(e), and $casks cask(s) to $OUTPUT_FILE"
echo ""
echo "To reinstall on another machine:"
echo "  puma-brew-import.sh $OUTPUT_FILE"
