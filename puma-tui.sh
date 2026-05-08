#!/usr/bin/env bash
# puma-tui.sh — Create a desktop entry that launches a TUI app in a terminal
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"

usage() {
    echo "Usage: $(basename "$0") <name> <command>"
    echo ""
    echo "  name     Display name for the app"
    echo "  command  Command (and args) to run inside the terminal"
    echo ""
    echo "You will be prompted for an optional icon URL."
    exit 1
}

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 2 ]] && usage

NAME="$1"
shift
CMD_BIN="$1"
shift || true
CMD_ARGS="$*"

CMD_BIN_PATH="$(command -v "$CMD_BIN" 2>/dev/null)" \
    || die "Command not found: $CMD_BIN"
COMMAND="${CMD_BIN_PATH}${CMD_ARGS:+ $CMD_ARGS}"

ID="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

ICON_PATH="$ICONS_DIR/${ID}.png"
DESKTOP_PATH="$APPS_DIR/${ID}.desktop"

if [[ ! -t 0 ]]; then
    read -r ICON_URL
else
    ICON_URL="$(puma_input "Icon URL (leave blank for default)" --placeholder "https://example.com/icon.png")"
fi

detect_terminal() {
    local terminals=(
        "kitty:kitty"
        "alacritty:alacritty -e"
        "foot:foot"
        "wezterm:wezterm start --"
        "xterm:xterm -e"
        "gnome-terminal:gnome-terminal --"
        "konsole:konsole -e"
        "xfce4-terminal:xfce4-terminal -e"
    )
    local available=()
    local exec_map=()
    for entry in "${terminals[@]}"; do
        local bin="${entry%%:*}"
        local exec_prefix="${entry#*:}"
        if command -v "$bin" >/dev/null 2>&1; then
            local bin_path
            bin_path="$(command -v "$bin")"
            available+=("$bin")
            exec_map+=("${exec_prefix/$bin/$bin_path}")
        fi
    done
    if [[ ${#available[@]} -eq 0 ]]; then
        die "No supported terminal emulator found. Install kitty, alacritty, foot, wezterm, or xterm."
    fi
    if [[ ${#available[@]} -gt 1 ]]; then
        local chosen
        chosen="$(puma_choose --header "Select terminal:" "${available[@]}")"
        for i in "${!available[@]}"; do
            if [[ "${available[$i]}" == "$chosen" ]]; then
                echo "${exec_map[$i]}"
                return
            fi
        done
    fi
    echo "${exec_map[0]}"
}

TERM_EXEC="$(detect_terminal)"
puma_style "Using terminal: ${TERM_EXEC%% *}" --foreground cyan

mkdir -p "$APPS_DIR" "$ICONS_DIR"

if ! puma_confirm "Create desktop entry for '$NAME'?"; then
    echo "Cancelled."
    exit 0
fi

if [[ -n "$ICON_URL" ]]; then
    puma_spin "Fetching icon from: $ICON_URL" -- curl -fsSL --max-time 10 -o "$ICON_PATH" "$ICON_URL" \
        || die "Failed to download icon from '$ICON_URL'"

    file_type="$(file --brief --mime-type "$ICON_PATH" 2>/dev/null || true)"
    if [[ "$file_type" != image/* ]]; then
        rm -f "$ICON_PATH"
        die "Downloaded file does not appear to be an image (got: $file_type)"
    fi

    puma_style "Icon saved to: $ICON_PATH" --foreground green
    ICON_VALUE="$ICON_PATH"
else
    ICON_VALUE="utilities-terminal"
fi

cat > "$DESKTOP_PATH" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${NAME}
Exec=${TERM_EXEC} ${COMMAND}
Icon=${ICON_VALUE}
Terminal=false
Categories=ConsoleOnly;
StartupWMClass=${ID}
EOF

chmod +x "$DESKTOP_PATH"

echo ""
puma_style "Desktop entry saved to: $DESKTOP_PATH" --bold --foreground green
puma_style "'$NAME' TUI app created." --bold --foreground green
