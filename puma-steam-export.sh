#!/usr/bin/env bash
# puma-steam-export.sh — Export Steam game AppIDs from flatpak or native Steam
set -euo pipefail

OUTPUT_FILE="$HOME/Documents/steam-games-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

# Detect Steam installation type
if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam; then
    STEAM_TYPE="flatpak"
    STEAM_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
    STEAM_CMD="flatpak run com.valvesoftware.Steam"
elif [[ -d "$HOME/.local/share/Steam" ]] || command -v steam >/dev/null 2>&1; then
    STEAM_TYPE="native"
    STEAM_DIR="$HOME/.local/share/Steam"
    STEAM_CMD="steam"
else
    die "No Steam installation found (flatpak or native)"
fi

STEAMAPPS="$STEAM_DIR/steamapps"

echo "Detected Steam: $STEAM_TYPE"
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
if [[ "$STEAM_TYPE" == "flatpak" ]]; then
    echo "To reinstall on another machine using flatpak SteamCMD:"
    echo "  flatpak run com.valvesoftware.Steam -steamcmd +login <username> +app_update <appid> +quit"
    echo ""
    echo "Or install all games in a loop:"
    echo "  while read appid; do flatpak run com.valvesoftware.Steam -steamcmd +login <username> +app_update \$appid +quit; done < $OUTPUT_FILE"
else
    echo "To reinstall on another machine using native SteamCMD:"
    echo "  steam -steamcmd +login <username> +app_update <appid> +quit"
    echo ""
    echo "Or install all games in a loop:"
    echo "  while read appid; do steam -steamcmd +login <username> +app_update \$appid +quit; done < $OUTPUT_FILE"
fi
