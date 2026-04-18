#!/usr/bin/env bash
# yt-live.sh — Check if a YouTube channel is live; copy the link and open in mpv
# Usage: yt-live.sh <username>

set -euo pipefail

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

[[ $# -lt 1 ]] && usage

command -v yt-dlp  &>/dev/null || die "yt-dlp is not installed"
command -v mpv     &>/dev/null || die "mpv is not installed"

# Normalize handle: strip leading @ if present, then re-add it
HANDLE="${1#@}"
LIVE_URL="https://www.youtube.com/@${HANDLE}/live"

echo "Checking if @${HANDLE} is live..."

# Fetch the watch URL for the live stream (yt-dlp resolves /live → watch?v=...)
# --no-playlist ensures we only grab the current live video, not a playlist.
WATCH_URL="$(yt-dlp \
    --no-playlist \
    --no-warnings \
    --print webpage_url \
    "$LIVE_URL" 2>/dev/null)" || true

if [[ -z "$WATCH_URL" ]]; then
    echo "@${HANDLE} does not appear to be live right now."
    exit 0
fi

echo "Live stream found: $WATCH_URL"

# Copy to clipboard — prefer wl-copy (Wayland), fall back to xclip / xsel
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

if copy_to_clipboard "$WATCH_URL"; then
    echo "Link copied to clipboard."
fi

echo "Opening in mpv..."
mpv "$WATCH_URL"
