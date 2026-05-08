#!/usr/bin/env bash
# puma.sh — Central interactive menu for Puma Command Line Tools
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

APP_NAME="Puma Command Line Tools"

show_header() {
    if $PUMA_HAS_GUM; then
        gum style \
            --border rounded \
            --border-foreground 5 \
            --padding "0 1" \
            --margin "0 1" \
            "$APP_NAME"
        echo ""
    else
        echo ""
        puma_style "$APP_NAME" --bold
        echo ""
    fi
}

run_export_all() {
    "$SCRIPT_DIR/export-all.sh" || true
}

run_import_all() {
    local dir
    dir="$(puma_input "Backup directory" --placeholder "$HOME/Documents/puma-backup")"
    if [[ -n "$dir" ]]; then
        "$SCRIPT_DIR/import-all.sh" "$dir" || true
    else
        "$SCRIPT_DIR/import-all.sh" || true
    fi
}

run_create_tui() {
    local name cmd icon_url
    name="$(puma_input "App name" --placeholder "My TUI App")"
    [[ -z "$name" ]] && return 0
    cmd="$(puma_input "Command to run" --placeholder "htop")"
    [[ -z "$cmd" ]] && return 0
    icon_url="$(puma_input "Icon URL (optional)" --placeholder "https://example.com/icon.png")"
    if [[ -n "$icon_url" ]]; then
        echo "$icon_url" | "$SCRIPT_DIR/puma-tui.sh" "$name" "$cmd" || true
    else
        echo "" | "$SCRIPT_DIR/puma-tui.sh" "$name" "$cmd" || true
    fi
}

run_create_webapp() {
    local name url icon_url
    name="$(puma_input "Web app name" --placeholder "My Web App")"
    [[ -z "$name" ]] && return 0
    url="$(puma_input "URL" --placeholder "https://example.com")"
    [[ -z "$url" ]] && return 0
    icon_url="$(puma_input "Icon URL (optional)" --placeholder "https://example.com/icon.png")"
    if [[ -n "$icon_url" ]]; then
        "$SCRIPT_DIR/puma-webapp.sh" "$name" "$url" "$icon_url" || true
    else
        "$SCRIPT_DIR/puma-webapp.sh" "$name" "$url" || true
    fi
}

run_yt_live() {
    local handle
    handle="$(puma_input "YouTube channel handle" --placeholder "@channel")"
    [[ -z "$handle" ]] && return 0
    "$SCRIPT_DIR/puma-yt-live.sh" "$handle" || true
}

run_tui_export() {
    "$SCRIPT_DIR/puma-tui-export.sh" || true
}

run_tui_import() {
    local file
    file="$(puma_input "Tarball path" --placeholder "$HOME/Documents/tui-apps-export.tar.gz")"
    [[ -z "$file" ]] && return 0
    "$SCRIPT_DIR/puma-tui-import.sh" "$file" || true
}

run_webapp_export() {
    "$SCRIPT_DIR/puma-webapp-export.sh" || true
}

run_webapp_import() {
    local file
    file="$(puma_input "Tarball path" --placeholder "$HOME/Documents/webapps-export.tar.gz")"
    [[ -z "$file" ]] && return 0
    "$SCRIPT_DIR/puma-webapp-import.sh" "$file" || true
}

run_steam_export() {
    "$SCRIPT_DIR/puma-steam-export.sh" || true
}

run_steam_import() {
    local file
    file="$(puma_input "Steam games list path" --placeholder "$HOME/Documents/steam-games-list.txt")"
    [[ -z "$file" ]] && return 0
    "$SCRIPT_DIR/puma-steam-import-list.sh" || true
}

run_brew_export() {
    "$SCRIPT_DIR/puma-brew-export.sh" || true
}

run_brew_import() {
    local file
    file="$(puma_input "Brew list path" --placeholder "$HOME/Documents/brew-list.txt")"
    [[ -z "$file" ]] && return 0
    "$SCRIPT_DIR/puma-brew-import.sh" "$file" || true
}

run_flatpak_export() {
    "$SCRIPT_DIR/puma-flatpak-export.sh" || true
}

# ── Main Menu ─────────────────────────────────────────────────────────

MENU_ITEMS=(
    "── All ──"
    "Export All"
    "Import All"
    ""
    "── Create ──"
    "Create TUI App"
    "Create Web App"
    ""
    "── TUI Apps ──"
    "Export TUI Apps"
    "Import TUI Apps"
    ""
    "── Web Apps ──"
    "Export Web Apps"
    "Import Web Apps"
    ""
    "── Steam ──"
    "Export Steam Games"
    "Import Steam Games"
    ""
    "── Packages ──"
    "Export Brew Packages"
    "Export Flatpak Apps"
    ""
    "── Utilities ──"
    "Check YouTube Live"
    ""
    "Exit"
)

ACTIONABLE_ITEMS=(
    "Export All"
    "Import All"
    "Create TUI App"
    "Create Web App"
    "Export TUI Apps"
    "Import TUI Apps"
    "Export Web Apps"
    "Import Web Apps"
    "Export Steam Games"
    "Import Steam Games"
    "Export Brew Packages"
    "Export Flatpak Apps"
    "Check YouTube Live"
    "Exit"
)

is_actionable() {
    local item="$1"
    for actionable in "${ACTIONABLE_ITEMS[@]}"; do
        [[ "$item" == "$actionable" ]] && return 0
    done
    return 1
}

main_menu() {
    while true; do
        show_header
        local choice
        if $PUMA_HAS_GUM; then
            while true; do
                choice="$(printf '%s\n' "${MENU_ITEMS[@]}" | gum choose \
                    --header "Select an action" \
                    --cursor "→" \
                    --cursor-prefix "" \
                    --selected-prefix "✓ " \
                    --height 20)"
                [[ -z "$choice" ]] && { echo "Goodbye!"; exit 0; }
                if is_actionable "$choice"; then
                    break
                fi
            done
        else
            choice="$(puma_choose --header "Select an action:" "${ACTIONABLE_ITEMS[@]}")"
        fi

        case "$choice" in
            "Export All") run_export_all ;;
            "Import All") run_import_all ;;
            "Create TUI App") run_create_tui ;;
            "Create Web App") run_create_webapp ;;
            "Check YouTube Live") run_yt_live ;;
            "Export TUI Apps") run_tui_export ;;
            "Import TUI Apps") run_tui_import ;;
            "Export Web Apps") run_webapp_export ;;
            "Import Web Apps") run_webapp_import ;;
            "Export Steam Games") run_steam_export ;;
            "Import Steam Games") run_steam_import ;;
            "Export Brew Packages") run_brew_export ;;
            "Export Flatpak Apps") run_flatpak_export ;;
            "Exit")
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Unknown action: $choice"
                ;;
        esac

        echo ""
        if ! puma_confirm "Return to menu?"; then
            echo "Goodbye!"
            exit 0
        fi
        clear 2>/dev/null || true
    done
}

main_menu
