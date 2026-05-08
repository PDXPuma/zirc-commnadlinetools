#!/usr/bin/env bash
# import-all.sh — Import brew, flatpak, and steam from ~/Documents/puma-backup/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

BACKUP_DIR="${1:-$HOME/Documents/puma-backup}"

die() { echo "Error: $1" >&2; exit 1; }

[[ -d "$BACKUP_DIR" ]] || die "Backup directory not found: $BACKUP_DIR"

# Build list of available imports
available=()
[[ -f "$BACKUP_DIR/brew-list.txt" ]] && available+=("brew")
[[ -f "$BACKUP_DIR/flatpak-list.txt" ]] && available+=("flatpak")
[[ -f "$BACKUP_DIR/steam-games-list.txt" ]] && available+=("steam")

if [[ ${#available[@]} -eq 0 ]]; then
    die "No export files found in $BACKUP_DIR"
fi

# Let user select which subsystems to import
if [[ ${#available[@]} -gt 1 ]]; then
    puma_style "Select subsystems to import:" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${available[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        subsystems=("${available[@]}")
    else
        IFS=$'\n' read -r -d '' -a subsystems <<< "$selected" || true
    fi
else
    subsystems=("${available[@]}")
fi

# Import selected subsystems
for sub in "${subsystems[@]}"; do
    echo ""
    puma_style "── Importing $sub ──" --bold
    case "$sub" in
        brew)
            if command -v brew >/dev/null 2>&1; then
                "$SCRIPT_DIR/puma-brew-import.sh" "$BACKUP_DIR/brew-list.txt"
            else
                puma_style "  Skipping (brew not installed)" --foreground yellow
            fi
            ;;
        flatpak)
            if command -v flatpak >/dev/null 2>&1; then
                flatpak install -y < "$BACKUP_DIR/flatpak-list.txt"
            else
                puma_style "  Skipping (flatpak not installed)" --foreground yellow
            fi
            ;;
        steam)
            if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam \
                || [[ -d "$HOME/.local/share/Steam" ]] \
                || command -v steam >/dev/null 2>&1; then
                puma_style "  Installing desktop entries and icons..." --foreground cyan
                "$SCRIPT_DIR/puma-steam-import.sh"
                echo ""
                puma_style "  Installing games via SteamCMD..." --foreground cyan
                "$SCRIPT_DIR/puma-steam-import-list.sh"
            else
                puma_style "  Skipping (Steam not installed)" --foreground yellow
            fi
            ;;
    esac
done

echo ""
puma_style "All imports complete." --bold --foreground green
