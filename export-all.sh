#!/usr/bin/env bash
# export-all.sh — Export brew, flatpak, and steam to ~/Documents/puma-backup/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

BACKUP_DIR="$HOME/Documents/puma-backup"

die() { echo "Error: $1" >&2; exit 1; }

mkdir -p "$BACKUP_DIR"

# Build list of available subsystems
available=()
command -v brew >/dev/null 2>&1 && available+=("brew")
command -v flatpak >/dev/null 2>&1 && available+=("flatpak")
(flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam \
    || [[ -d "$HOME/.local/share/Steam" ]] \
    || command -v steam >/dev/null 2>&1) && available+=("steam")

if [[ ${#available[@]} -eq 0 ]]; then
    die "No supported subsystems found (brew, flatpak, or steam)"
fi

# Let user select which subsystems to export
if [[ ${#available[@]} -gt 1 ]]; then
    puma_style "Select subsystems to export:" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${available[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        subsystems=("${available[@]}")
    else
        IFS=$'\n' read -r -d '' -a subsystems <<< "$selected" || true
    fi
else
    subsystems=("${available[@]}")
fi

# Export selected subsystems
for sub in "${subsystems[@]}"; do
    echo ""
    puma_style "── Exporting $sub ──" --bold
    case "$sub" in
        brew)
            "$SCRIPT_DIR/puma-brew-export.sh" 2>&1 || true
            ;;
        flatpak)
            "$SCRIPT_DIR/puma-flatpak-export.sh" 2>&1 || true
            ;;
        steam)
            "$SCRIPT_DIR/puma-steam-export.sh" 2>&1 || true
            ;;
    esac
done

# Collect exports into backup directory
echo ""
puma_style "── Collecting exports into $BACKUP_DIR/ ──" --bold

for f in brew-list.txt flatpak-list.txt steam-games-list.txt; do
    if [[ -f "$HOME/Documents/$f" ]]; then
        cp "$HOME/Documents/$f" "$BACKUP_DIR/$f"
        puma_style "  Copied $f" --foreground cyan
    fi
done

echo ""
puma_style "All exports saved to $BACKUP_DIR/" --bold --foreground green
ls -1 "$BACKUP_DIR"
