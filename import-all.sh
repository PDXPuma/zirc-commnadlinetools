#!/usr/bin/env bash
# import-all.sh — Import brew, flatpak, and steam from ~/Documents/puma-backup/
set -euo pipefail

BACKUP_DIR="${1:-$HOME/Documents/puma-backup}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

die() { echo "Error: $1" >&2; exit 1; }

[[ -d "$BACKUP_DIR" ]] || die "Backup directory not found: $BACKUP_DIR"

# ── Brew ──────────────────────────────────────────────────────────────
if [[ -f "$BACKUP_DIR/brew-list.txt" ]]; then
    echo "── Importing brew packages ──"
    if command -v brew >/dev/null 2>&1; then
        "$SCRIPT_DIR/puma-brew-import.sh" "$BACKUP_DIR/brew-list.txt"
    else
        echo "  Skipping (brew not installed)"
    fi
else
    echo "── Skipping brew (no export found) ──"
fi

# ── Flatpak ───────────────────────────────────────────────────────────
if [[ -f "$BACKUP_DIR/flatpak-list.txt" ]]; then
    echo ""
    echo "── Importing flatpak apps ──"
    if command -v flatpak >/dev/null 2>&1; then
        flatpak install -y < "$BACKUP_DIR/flatpak-list.txt"
    else
        echo "  Skipping (flatpak not installed)"
    fi
else
    echo "── Skipping flatpak (no export found) ──"
fi

# ── Steam ─────────────────────────────────────────────────────────────
if [[ -f "$BACKUP_DIR/steam-games-list.txt" ]]; then
    echo ""
    echo "── Importing Steam games ──"
    if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam \
        || [[ -d "$HOME/.local/share/Steam" ]] \
        || command -v steam >/dev/null 2>&1; then
        echo "  Installing desktop entries and icons..."
        "$SCRIPT_DIR/puma-steam-import.sh"
        echo ""
        echo "  Installing games via SteamCMD..."
        "$SCRIPT_DIR/puma-steam-import-list.sh"
    else
        echo "  Skipping (Steam not installed)"
    fi
else
    echo "── Skipping steam (no export found) ──"
fi

echo ""
echo "All imports complete."
