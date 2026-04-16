#!/usr/bin/env bash
# puma-tui.sh — Create a desktop entry that launches a TUI app in a terminal
# Usage: puma-tui.sh <name> <command>

set -euo pipefail

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

# Resolve the command binary to an absolute path
CMD_BIN_PATH="$(command -v "$CMD_BIN" 2>/dev/null)" \
    || die "Command not found: $CMD_BIN"
COMMAND="${CMD_BIN_PATH}${CMD_ARGS:+ $CMD_ARGS}"

# Derive a safe identifier from the name (lowercase, spaces to hyphens)
ID="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

ICON_PATH="$ICONS_DIR/${ID}.png"
DESKTOP_PATH="$APPS_DIR/${ID}.desktop"

# Prompt for icon URL
read -rp "Icon URL (leave blank to use system terminal icon): " ICON_URL

# Detect an available terminal emulator
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
    for entry in "${terminals[@]}"; do
        local bin="${entry%%:*}"
        local exec_prefix="${entry#*:}"
        if command -v "$bin" >/dev/null 2>&1; then
            local bin_path
            bin_path="$(command -v "$bin")"
            echo "${exec_prefix/$bin/$bin_path}"
            return
        fi
    done
    die "No supported terminal emulator found. Install kitty, alacritty, foot, wezterm, or xterm."
}

TERM_EXEC="$(detect_terminal)"
echo "Using terminal: ${TERM_EXEC%% *}"

mkdir -p "$APPS_DIR" "$ICONS_DIR"

# Handle icon
if [[ -n "$ICON_URL" ]]; then
    echo "Fetching icon from: $ICON_URL"
    curl -fsSL --max-time 10 -o "$ICON_PATH" "$ICON_URL" \
        || die "Failed to download icon from '$ICON_URL'"

    file_type="$(file --brief --mime-type "$ICON_PATH" 2>/dev/null || true)"
    if [[ "$file_type" != image/* ]]; then
        rm -f "$ICON_PATH"
        die "Downloaded file does not appear to be an image (got: $file_type)"
    fi

    echo "Icon saved to: $ICON_PATH"
    ICON_VALUE="$ICON_PATH"
else
    ICON_VALUE="utilities-terminal"
fi

# Write the .desktop file
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

echo "Desktop entry saved to: $DESKTOP_PATH"
echo "Done. '${NAME}' TUI app created."
