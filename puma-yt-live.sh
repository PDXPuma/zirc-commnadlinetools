#!/usr/bin/env bash
# yt-live.sh — Check if a YouTube channel is live; copy the link and open in mpv
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/puma-lib.sh"

usage() {
    echo "Usage: $(basename "$0") <username>"
    echo ""
    echo "  username  YouTube channel handle (with or without @)"
    echo ""
    echo "Checks if the channel is live. If so, copies the stream URL to the"
    echo "clipboard and opens it in mpv."
    exit 1
}

die() { echo "Error: $1" >&2; exit 1; }

command -v yt-dlp  &>/dev/null || die "yt-dlp is not installed"
command -v mpv     &>/dev/null || die "mpv is not installed"

if [[ $# -lt 1 ]]; then
    HANDLE="$(puma_input "YouTube channel handle" --placeholder "@channel")"
    [[ -z "$HANDLE" ]] && exit 0
else
    HANDLE="$1"
fi

copy_to_clipboard() {
    local url="$1"
    if command -v wl-copy &>/dev/null; then
        printf '%s' "$url" | wl-copy
    elif command -v xclip &>/dev/null; then
        printf '%s' "$url" | xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        printf '%s' "$url" | xsel --clipboard --input
    else
        echo "Warning: no clipboard tool found (wl-copy/xclip/xsel). Link not copied." >&2
        return 1
    fi
}

HANDLE="${HANDLE#@}"
LIVE_URL="https://www.youtube.com/@${HANDLE}/live"

puma_spin "Checking if @${HANDLE} is live..." -- yt-dlp \
    --no-playlist \
    --no-warnings \
    --print webpage_url \
    "$LIVE_URL" 2>/dev/null > /dev/null || true

WATCH_URL="$(yt-dlp \
    --no-playlist \
    --no-warnings \
    --print webpage_url \
    "$LIVE_URL" 2>/dev/null)" || true

if [[ -z "$WATCH_URL" ]]; then
    puma_style "@${HANDLE} does not appear to be live right now." --foreground yellow
    exit 0
fi

puma_style "Live stream found: $WATCH_URL" --bold --foreground green

if copy_to_clipboard "$WATCH_URL"; then
    puma_style "Link copied to clipboard." --foreground green
fi

if puma_confirm "Open stream in mpv?"; then
    mpv "$WATCH_URL"
fi
