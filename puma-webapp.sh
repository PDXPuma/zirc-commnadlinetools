#!/usr/bin/env bash
# puma-webapp.sh — Create a Chromium flatpak PWA desktop entry
# Usage: puma-webapp.sh <name> <url> [icon-url]

set -euo pipefail

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"
CHROMIUM_APP="org.chromium.Chromium"

usage() {
    echo "Usage: $(basename "$0") <name> <url> [icon-url]"
    echo ""
    echo "  name      Display name for the webapp"
    echo "  url       URL to open in PWA mode"
    echo "  icon-url  (optional) Direct URL to an icon image"
    echo "            Defaults to Google's favicon service for the given URL"
    exit 1
}

die() { echo "Error: $1" >&2; exit 1; }

[[ $# -lt 2 ]] && usage

NAME="$1"
URL="$2"
ICON_URL="${3:-}"

# Derive a safe identifier from the name (lowercase, spaces to hyphens)
ID="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

ICON_PATH="$ICONS_DIR/${ID}.png"
DESKTOP_PATH="$APPS_DIR/${ID}.desktop"

# Check flatpak and chromium are available
command -v flatpak >/dev/null 2>&1 || die "flatpak is not installed"
flatpak info "$CHROMIUM_APP" >/dev/null 2>&1 || die "Flatpak app '$CHROMIUM_APP' is not installed"

mkdir -p "$APPS_DIR" "$ICONS_DIR"

# Determine icon URL if not provided
if [[ -z "$ICON_URL" ]]; then
    DOMAIN="$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|')"
    ICON_URL="https://www.google.com/s2/favicons?domain=${DOMAIN}&sz=128"
fi

echo "Fetching icon from: $ICON_URL"
curl -fsSL --max-time 10 -o "$ICON_PATH" "$ICON_URL" \
    || die "Failed to download icon from '$ICON_URL'"

# Verify we got an image (curl may succeed but return an error page)
file_type="$(file --brief --mime-type "$ICON_PATH" 2>/dev/null || true)"
if [[ "$file_type" != image/* ]]; then
    rm -f "$ICON_PATH"
    die "Downloaded file does not appear to be an image (got: $file_type)"
fi

echo "Icon saved to: $ICON_PATH"

# Write the .desktop file
cat > "$DESKTOP_PATH" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${NAME}
Exec=flatpak run ${CHROMIUM_APP} --app=${URL}
Icon=${ICON_PATH}
Terminal=false
Categories=Network;WebBrowser;
StartupWMClass=${ID}
EOF

chmod +x "$DESKTOP_PATH"

echo "Desktop entry saved to: $DESKTOP_PATH"
echo "Done. '${NAME}' webapp created."
