#!/usr/bin/env bash
# install.sh — Install all scripts to ~/.local/bin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

installed=0
skipped=0

for script in "$SCRIPT_DIR"/*.sh; do
    name="$(basename "$script")"
    [[ "$name" == "install.sh" ]] && continue

    if [[ -f "$INSTALL_DIR/$name" ]]; then
        if puma_confirm "$name already exists. Overwrite?"; then
            cp "$script" "$INSTALL_DIR/$name"
            chmod +x "$INSTALL_DIR/$name"
            puma_style "Updated: $name" --foreground cyan
            installed=$((installed + 1))
        else
            puma_style "Skipped: $name" --foreground yellow
            skipped=$((skipped + 1))
        fi
    else
        cp "$script" "$INSTALL_DIR/$name"
        chmod +x "$INSTALL_DIR/$name"
        puma_style "Installed: $name" --foreground green
        installed=$((installed + 1))
    fi
done

echo ""
puma_style "Done. $installed script(s) installed to $INSTALL_DIR." --bold
if [[ $skipped -gt 0 ]]; then
    puma_style "$skipped script(s) skipped." --foreground yellow
fi

if ! $PUMA_HAS_GUM; then
    echo ""
    puma_style "gum not found — scripts will run in plain mode." --foreground yellow
    puma_style "Install gum for enhanced TUI: https://github.com/charmbracelet/gum" --foreground yellow
fi

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    puma_style "Note: $INSTALL_DIR is not in your PATH." --bold --foreground red
    echo "Add this to your shell config (~/.bashrc or ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
