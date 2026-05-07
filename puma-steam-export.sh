#!/usr/bin/env bash
# puma-steam-export.sh — Export Steam game AppIDs from flatpak Steam
set -euo pipefail

STEAM_FLATPAK="$HOME/.var/app/com.valvesoftware.Steam"
STEAM_DIR="$STEAM_FLATPAK/.local/share/Steam"
STEAMAPPS="$STEAM_DIR/steamapps"

OUTPUT_FILE="$HOME/Documents/steam-games-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

[[ -d "$STEAMAPPS" ]] || die "Steam apps directory not found: $STEAMAPPS"

mkdir -p "$HOME/Documents"

> "$OUTPUT_FILE"

count=0
shopt -s nullglob
for manifest in "$STEAMAPPS"/appmanifest_*.acf; do
    appid=$(grep -oP '"appid"\s*"\K[0-9]+' "$manifest" 2>/dev/null || true)
    if [[ -n "$appid" ]]; then
        echo "$appid" >> "$OUTPUT_FILE"
        count=$((count + 1))
    fi
done

echo "Exported $count game(s) to $OUTPUT_FILE"
echo ""
echo "To reinstall on another machine using flatpak SteamCMD:"
echo "  flatpak run com.valvesoftware.Steam -steamcmd +login <username> +app_update <appid> +quit"
echo ""
echo "Or install all games in a loop:"
echo "  while read appid; do flatpak run com.valvesoftware.Steam -steamcmd +login <username> +app_update \$appid +quit; done < $OUTPUT_FILE"
