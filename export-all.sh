#!/usr/bin/env bash
# export-all.sh — Export brew, flatpak, and steam to ~/Documents/puma-backup/
set -euo pipefail

BACKUP_DIR="$HOME/Documents/puma-backup"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

die() { echo "Error: $1" >&2; exit 1; }

mkdir -p "$BACKUP_DIR"

# ── Brew ──────────────────────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
    echo "── Exporting brew packages ──"
    "$SCRIPT_DIR/puma-brew-export.sh" 2>&1 || true
else
    echo "── Skipping brew (not installed) ──"
fi

# ── Flatpak ───────────────────────────────────────────────────────────
if command -v flatpak >/dev/null 2>&1; then
    echo ""
    echo "── Exporting flatpak apps ──"
    "$SCRIPT_DIR/puma-flatpak-export.sh" 2>&1 || true
else
    echo "── Skipping flatpak (not installed) ──"
fi

# ── Steam ─────────────────────────────────────────────────────────────
if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam \
    || [[ -d "$HOME/.local/share/Steam" ]] \
    || command -v steam >/dev/null 2>&1; then
    echo ""
    echo "── Exporting Steam games ──"
    "$SCRIPT_DIR/puma-steam-export.sh" 2>&1 || true
else
    echo "── Skipping steam (not installed) ──"
fi

# ── Move all exports into the backup directory ────────────────────────
echo ""
echo "── Collecting exports into $BACKUP_DIR/ ──"

for f in brew-list.txt flatpak-list.txt steam-games-list.txt; do
    if [[ -f "$HOME/Documents/$f" ]]; then
        cp "$HOME/Documents/$f" "$BACKUP_DIR/$f"
        echo "  Copied $f"
    fi
done

echo ""
echo "All exports saved to $BACKUP_DIR/"
ls -1 "$BACKUP_DIR"
