#!/usr/bin/env bash
# puma-brew-import.sh — Install brew packages and casks from an export list
set -euo pipefail

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 1 ]] && die "Usage: $(basename "$0") <brew-list.txt>"

INPUT_FILE="$1"
[[ -f "$INPUT_FILE" ]] || die "File not found: $INPUT_FILE"
command -v brew >/dev/null 2>&1 || die "brew is not installed"

total=0
failed=0
section="none"

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments and blank lines
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Track which section we're in
    if [[ "$line" == "# Taps" ]]; then
        section="tap"
        continue
    elif [[ "$line" == "# Formulae" ]]; then
        section="formula"
        continue
    elif [[ "$line" == "# Casks" ]]; then
        section="cask"
        continue
    fi

    total=$((total + 1))
    if [[ "$section" == "tap" ]]; then
        echo "Tapping: $line"
        if brew tap "$line"; then
            echo "  -> OK"
        else
            echo "  -> FAILED (may already exist)" >&2
            failed=$((failed + 1))
        fi
    elif [[ "$section" == "formula" ]]; then
        echo "Installing formula: $line"
        if brew install "$line"; then
            echo "  -> OK"
        else
            echo "  -> FAILED" >&2
            failed=$((failed + 1))
        fi
    elif [[ "$section" == "cask" ]]; then
        echo "Installing cask: $line"
        if brew install --cask "$line"; then
            echo "  -> OK"
        else
            echo "  -> FAILED" >&2
            failed=$((failed + 1))
        fi
    fi
done < "$INPUT_FILE"

echo ""
echo "Done. $((total - failed))/$total package(s) installed."
if [[ $failed -gt 0 ]]; then
    echo "$failed package(s) failed to install."
fi
