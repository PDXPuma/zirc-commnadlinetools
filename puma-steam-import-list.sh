#!/usr/bin/env bash
# puma-steam-import-list.sh — Install Steam games from an exported AppID list
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

INPUT_FILE="$HOME/Documents/steam-games-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

if flatpak list --columns=application 2>/dev/null | grep -q com.valvesoftware.Steam; then
    STEAM_TYPE="flatpak"
    FLATPAK_CMD="flatpak run com.valvesoftware.Steam -steamcmd"
elif command -v steam >/dev/null 2>&1 || [[ -d "$HOME/.local/share/Steam" ]]; then
    STEAM_TYPE="native"
    FLATPAK_CMD="steam -steamcmd"
else
    die "No Steam installation found (flatpak or native)"
fi

puma_style "Detected Steam: $STEAM_TYPE" --bold

[[ -f "$INPUT_FILE" ]] || die "Steam games list not found: $INPUT_FILE"

# Read all AppIDs
mapfile -t all_appids < "$INPUT_FILE"

# Let user select which games to install
if [[ ${#all_appids[@]} -gt 1 ]]; then
    puma_style "Select games to install (or press Enter for all):" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${all_appids[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        appids=("${all_appids[@]}")
    else
        IFS=$'\n' read -r -d '' -a appids <<< "$selected" || true
    fi
else
    appids=("${all_appids[@]}")
fi

# Get credentials
username="$(puma_input "Steam username" --placeholder "username")"
[[ -z "$username" ]] && die "Username is required"
password="$(puma_input "Steam password" --password --placeholder "password")"
[[ -z "$password" ]] && die "Password is required"

total=${#appids[@]}
current=0
failed=0

for appid in "${appids[@]}"; do
    [[ -z "$appid" ]] && continue
    current=$((current + 1))
    echo ""
    puma_style "[$current/$total] Installing app $appid..." --bold
    if $FLATPAK_CMD +login "$username" "$password" +app_update "$appid" +quit; then
        puma_style "Successfully installed app $appid" --foreground green
    else
        puma_style "Failed to install app $appid" --foreground red
        failed=$((failed + 1))
    fi
done

echo ""
if [[ $failed -eq 0 ]]; then
    puma_style "Done. $total/$total game(s) installed." --bold --foreground green
else
    puma_style "Done. $((total - failed))/$total game(s) installed." --bold
    puma_style "$failed game(s) failed to install." --foreground red
fi
