#!/usr/bin/env bash
# puma-brew-import.sh — Install brew packages and casks from an export list
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 1 ]] && die "Usage: $(basename "$0") <brew-list.txt>"

INPUT_FILE="$1"
[[ -f "$INPUT_FILE" ]] || die "File not found: $INPUT_FILE"
command -v brew >/dev/null 2>&1 || die "brew is not installed"

# Parse the file into sections
declare -a taps=() formulae=() casks=()
section="none"

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && {
        [[ "$line" == "# Taps" ]] && { section="tap"; continue; }
        [[ "$line" == "# Formulae" ]] && { section="formula"; continue; }
        [[ "$line" == "# Casks" ]] && { section="cask"; continue; }
        continue
    }
    case "$section" in
        tap) taps+=("$line") ;;
        formula) formulae+=("$line") ;;
        cask) casks+=("$line") ;;
    esac
done < "$INPUT_FILE"

# Let user select what to install
all_items=()
all_types=()
for t in "${taps[@]}"; do all_items+=("$t"); all_types+=("tap"); done
for f in "${formulae[@]}"; do all_items+=("$f"); all_types+=("formula"); done
for c in "${casks[@]}"; do all_items+=("$c"); all_types+=("cask"); done

if [[ ${#all_items[@]} -gt 1 ]]; then
    puma_style "Select packages to install (or press Enter for all):" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${all_items[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        selected="$(printf '%s\n' "${all_items[@]}")"
    fi
    IFS=$'\n' read -r -d '' -a chosen <<< "$selected" || true
else
    chosen=("${all_items[@]}")
fi

total=0
failed=0

for item in "${chosen[@]}"; do
    # Find the type of this item
    item_type=""
    for i in "${!all_items[@]}"; do
        if [[ "${all_items[$i]}" == "$item" ]]; then
            item_type="${all_types[$i]}"
            break
        fi
    done

    total=$((total + 1))
    case "$item_type" in
        tap)
            puma_spin "Tapping: $item" -- brew tap "$item" 2>/dev/null || {
                puma_style "  -> FAILED (may already exist)" --foreground red
                failed=$((failed + 1))
                continue
            }
            ;;
        formula)
            puma_spin "Installing formula: $item" -- brew install "$item" || {
                puma_style "  -> FAILED" --foreground red
                failed=$((failed + 1))
                continue
            }
            ;;
        cask)
            puma_spin "Installing cask: $item" -- brew install --cask "$item" || {
                puma_style "  -> FAILED" --foreground red
                failed=$((failed + 1))
                continue
            }
            ;;
    esac
    puma_style "  -> OK" --foreground green
done

echo ""
if [[ $failed -eq 0 ]]; then
    puma_style "Done. $total/$total package(s) installed." --bold --foreground green
else
    puma_style "Done. $((total - failed))/$total package(s) installed." --bold
    puma_style "$failed package(s) failed to install." --foreground red
fi
