#!/usr/bin/env bash
# install.sh — Install all scripts to ~/.local/bin
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$INSTALL_DIR"

installed=0
for script in "$SCRIPT_DIR"/*.sh; do
    name="$(basename "$script")"
    [[ "$name" == "install.sh" ]] && continue
    cp "$script" "$INSTALL_DIR/$name"
    chmod +x "$INSTALL_DIR/$name"
    echo "Installed: $INSTALL_DIR/$name"
    ((installed++))
done

echo "Done. $installed script(s) installed to $INSTALL_DIR."

# Remind the user if ~/.local/bin isn't on their PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "Note: $INSTALL_DIR is not in your PATH."
    echo "Add this to your shell config (~/.bashrc or ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
