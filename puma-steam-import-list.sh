#!/usr/bin/env bash
# puma-steam-import-list.sh — Install Steam games from an exported AppID list
set -euo pipefail

INPUT_FILE="$HOME/Documents/steam-games-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

# Detect Steam installation type
if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam; then
    STEAM_TYPE="flatpak"
    FLATPAK_CMD="flatpak run com.valvesoftware.Steam -steamcmd"
elif command -v steam >/dev/null 2>&1 || [[ -d "$HOME/.local/share/Steam" ]]; then
    STEAM_TYPE="native"
    FLATPAK_CMD="steam -steamcmd"
else
    die "No Steam installation found (flatpak or native)"
fi

echo "Detected Steam: $STEAM_TYPE"

[[ -f "$INPUT_FILE" ]] || die "Steam games list not found: $INPUT_FILE"

read -rp "Steam username: " username
read -rsp "Steam password: " password
echo ""

total=$(wc -l < "$INPUT_FILE")
current=0
failed=0

while read -r appid || [[ -n "$appid" ]]; do
    [[ -z "$appid" ]] && continue
    current=$((current + 1))
    echo ""
    echo "[$current/$total] Installing app $appid..."
    if $FLATPAK_CMD +login "$username" "$password" +app_update "$appid" +quit; then
        echo "Successfully installed app $appid"
    else
        echo "Failed to install app $appid" >&2
        failed=$((failed + 1))
    fi
done < "$INPUT_FILE"

echo ""
echo "Done. $((total - failed))/$total game(s) installed."
if [[ $failed -gt 0 ]]; then
    echo "$failed game(s) failed to install."
fi
