#!/usr/bin/env bash
# puma-steam-export.sh — Export Steam game AppIDs from flatpak or native Steam
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

OUTPUT_FILE="$HOME/Documents/steam-games-list.txt"

die() { echo "Error: $1" >&2; exit 1; }

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

puma_style "Detected Steam: $STEAM_TYPE" --bold
[[ -d "$STEAMAPPS" ]] || die "Steam apps directory not found: $STEAMAPPS"

mkdir -p "$HOME/Documents"

> "$OUTPUT_FILE"

count=0
declare -a game_ids=()
declare -a game_names=()
declare -a game_labels=()
shopt -s nullglob
for manifest in "$STEAMAPPS"/appmanifest_*.acf; do
    appid=$(grep -oP '"appid"\s*"\K[0-9]+' "$manifest" 2>/dev/null || true)
    name=$(grep -oP '"name"\s*"\K[^"]+' "$manifest" 2>/dev/null || true)
    if [[ -n "$appid" ]]; then
        game_ids+=("$appid")
        game_names+=("${name:-Unknown}")
        game_labels+=("${name:-Unknown} ($appid)")
        count=$((count + 1))
    fi
done

if [[ $count -eq 0 ]]; then
    puma_style "No Steam games found." --foreground yellow
    exit 0
fi

echo ""
for i in "${!game_ids[@]}"; do
    printf '%s\t%s\n' "${game_ids[$i]}" "${game_names[$i]}"
done | puma_table "AppID" "Game Name"
echo ""

# Let user select which games to export
if [[ ${#game_labels[@]} -gt 1 ]]; then
    puma_style "Select games to export (or press Enter for all):" --bold
    selected="$(puma_choose --no-limit --header "" "Select All" "${game_labels[@]}")"
    if [[ -z "$selected" || "$selected" == "Select All" ]]; then
        chosen_indices=("${!game_ids[@]}")
    else
        IFS=$'\n' read -r -d '' -a chosen_labels <<< "$selected" || true
        chosen_indices=()
        for label in "${chosen_labels[@]}"; do
            for i in "${!game_labels[@]}"; do
                if [[ "${game_labels[$i]}" == "$label" ]]; then
                    chosen_indices+=("$i")
                    break
                fi
            done
        done
    fi
else
    chosen_indices=(0)
fi

> "$OUTPUT_FILE"
for i in "${chosen_indices[@]}"; do
    echo "${game_ids[$i]}" >> "$OUTPUT_FILE"
done

puma_style "Exported ${#chosen_indices[@]} game(s) to $OUTPUT_FILE" --bold --foreground green
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
