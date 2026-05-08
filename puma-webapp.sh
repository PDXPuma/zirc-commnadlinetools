#!/usr/bin/env bash
# puma-webapp.sh — Create a Chromium flatpak PWA desktop entry
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

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

if [[ $# -ge 2 ]]; then
    NAME="$1"
    URL="$2"
    ICON_URL="${3:-}"
else
    NAME="$(puma_input "Web app name" --placeholder "My Web App")"
    [[ -z "$NAME" ]] && exit 0
    URL="$(puma_input "URL" --placeholder "https://example.com")"
    [[ -z "$URL" ]] && exit 0
    ICON_URL="$(puma_input "Icon URL (optional)" --placeholder "https://example.com/icon.png")"
fi

ID="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

ICON_PATH="$ICONS_DIR/${ID}.png"
DESKTOP_PATH="$APPS_DIR/${ID}.desktop"

command -v flatpak >/dev/null 2>&1 || die "flatpak is not installed"
flatpak info "$CHROMIUM_APP" >/dev/null 2>&1 || die "Flatpak app '$CHROMIUM_APP' is not installed"

mkdir -p "$APPS_DIR" "$ICONS_DIR"

if [[ -z "$ICON_URL" ]]; then
    DOMAIN="$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|')"
    ICON_URL="https://www.google.com/s2/favicons?domain=${DOMAIN}&sz=128"
fi

if ! puma_confirm "Create webapp '$NAME' for $URL?"; then
    echo "Cancelled."
    exit 0
fi

puma_spin "Fetching icon from: $ICON_URL" -- curl -fsSL --max-time 10 -o "$ICON_PATH" "$ICON_URL" \
    || die "Failed to download icon from '$ICON_URL'"

file_type="$(file --brief --mime-type "$ICON_PATH" 2>/dev/null || true)"
if [[ "$file_type" != image/* ]]; then
    rm -f "$ICON_PATH"
    die "Downloaded file does not appear to be an image (got: $file_type)"
fi

puma_style "Icon saved to: $ICON_PATH" --foreground green

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

echo ""
puma_style "Desktop entry saved to: $DESKTOP_PATH" --bold --foreground green
puma_style "'$NAME' webapp created." --bold --foreground green
