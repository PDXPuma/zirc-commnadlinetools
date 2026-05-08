#!/usr/bin/env bash
# puma-lib.sh — Shared helper library for Puma scripts with gum support
# Source this file in other scripts: source "$(dirname "${BASH_SOURCE[0]}")/puma-lib.sh"
# All functions gracefully degrade to plain behavior when gum is not installed.

# Detect if gum is available
PUMA_HAS_GUM=false
if command -v gum >/dev/null 2>&1; then
    PUMA_HAS_GUM=true
fi

# ── Spinner ───────────────────────────────────────────────────────────
# Usage: puma_spin "Doing something..." -- actual_command arg1 arg2
#        puma_spin "Doing something..." <<< "$(some_command)"
puma_spin() {
    local title="$1"
    shift
    if [[ $# -gt 0 && "$1" == "--" ]]; then
        shift
    fi
    if $PUMA_HAS_GUM; then
        if [[ $# -gt 0 ]]; then
            gum spin --title "$title" -- bash -c 'exec "$@"' _ "$@"
        else
            echo "[..] $title"
        fi
    else
        echo "[..] $title"
        if [[ $# -gt 0 ]]; then
            "$@"
        fi
    fi
}

# ── Confirm ───────────────────────────────────────────────────────────
# Usage: if puma_confirm "Proceed?"; then ... fi
puma_confirm() {
    local prompt="${1:-Proceed?}"
    if $PUMA_HAS_GUM; then
        gum confirm "$prompt"
    else
        local answer
        read -rp "$prompt [Y/n] " answer
        [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
    fi
}

# ── Input ─────────────────────────────────────────────────────────────
# Usage: result="$(puma_input "Enter value:" --placeholder "value")"
#        result="$(puma_input "Password:" --password)"
puma_input() {
    local prompt="$1"
    shift
    if $PUMA_HAS_GUM; then
        gum input --prompt "$prompt: " "$@"
    else
        local flags=""
        local is_password=false
        for arg in "$@"; do
            case "$arg" in
                --password) is_password=true ;;
                --placeholder) shift ;; # skip the placeholder value
            esac
        done
        if $is_password; then
            read -rsp "$prompt: "
        else
            read -rp "$prompt: "
        fi
        printf '%s' "$REPLY"
    fi
}

# ── Choose ────────────────────────────────────────────────────────────
# Usage: choice="$(puma_choose "Pick one:" "Option A" "Option B" "Option C")"
#        choices="$(puma_choose --no-limit "Pick many:" "A" "B" "C")"
puma_choose() {
    local header=""
    local limit=""
    local items=()
    local parsing_items=false

    for arg in "$@"; do
        if [[ "$arg" == "--no-limit" ]]; then
            limit="--no-limit"
        elif [[ "$arg" == --header=* ]]; then
            header="$arg"
        elif [[ "$arg" == "--header" ]]; then
            parsing_items=true
            continue
        elif $parsing_items; then
            header="--header=$arg"
            parsing_items=false
        else
            items+=("$arg")
        fi
    done

    if $PUMA_HAS_GUM; then
        if [[ -n "$header" ]]; then
            gum choose $limit "$header" "${items[@]}"
        else
            gum choose $limit "${items[@]}"
        fi
    else
        echo "$header"
        for i in "${!items[@]}"; do
            echo "  $((i + 1))) ${items[$i]}"
        done
        local answer
        read -rp "Select (number, or comma-separated for multiple): " answer
        if [[ -n "$limit" ]]; then
            local result=()
            IFS=',' read -ra indices <<< "$answer"
            for idx in "${indices[@]}"; do
                idx=$(echo "$idx" | tr -d ' ')
                if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#items[@]} )); then
                    result+=("${items[$((idx - 1))]}")
                fi
            done
            printf '%s\n' "${result[@]}"
        else
            answer=$(echo "$answer" | tr -d ' ')
            if [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= 1 && answer <= ${#items[@]} )); then
                echo "${items[$((answer - 1))]}"
            fi
        fi
    fi
}

# ── Style ─────────────────────────────────────────────────────────────
# Usage: puma_style "Some text" --bold --foreground green
puma_style() {
    local text="$1"
    shift
    if $PUMA_HAS_GUM; then
        gum style "$text" "$@"
    else
        local bold="" reset="" fg=""
        for arg in "$@"; do
            case "$arg" in
                --bold) bold=$(tput bold) ;;
                --foreground=*) fg=$(tput setaf $(color_name_to_num "${arg#--foreground=}")) ;;
                --foreground) shift; fg=$(tput setaf $(color_name_to_num "$1")) ;;
                --border*) ;; # ignore borders in fallback
            esac
        done
        reset=$(tput sgr0)
        printf '%s%s%s\n' "$bold$fg" "$text" "$reset"
    fi
}

color_name_to_num() {
    case "$1" in
        red) echo 1 ;; green) echo 2 ;; yellow) echo 3 ;;
        blue) echo 4 ;; magenta) echo 5 ;; cyan) echo 6 ;;
        white) echo 7 ;; *) echo 7 ;;
    esac
}

# ── Table ─────────────────────────────────────────────────────────────
# Usage: puma_table "Header1" "Header2" <<< "val1\tval2\nval3\tval4"
#        printf "a\tb\nc\td\n" | puma_table "Col1" "Col2"
puma_table() {
    local headers=("$@")
    local col_widths=()
    local rows=()
    local num_cols=${#headers[@]}

    for h in "${headers[@]}"; do
        col_widths+=(${#h})
    done

    while IFS=$'\t' read -ra fields; do
        [[ ${#fields[@]} -eq 0 ]] && continue
        rows+=("$(printf '%s\t' "${fields[@]}")")
        for i in "${!fields[@]}"; do
            if (( ${#fields[$i]} > col_widths[$i] )); then
                col_widths[$i]=${#fields[$i]}
            fi
        done
    done

    local fmt=""
    for w in "${col_widths[@]}"; do
        fmt+="%-$((w + 2))s"
    done
    fmt+="%s\n"

    printf "$fmt" "${headers[@]}"
    local sep=""
    for w in "${col_widths[@]}"; do
        sep+=$(printf '%*s' "$((w + 2))" '' | tr ' ' '-')
    done
    echo "$sep"

    for row in "${rows[@]}"; do
        IFS=$'\t' read -ra fields <<< "$row"
        printf "$fmt" "${fields[@]}"
    done
}

# ── Format ────────────────────────────────────────────────────────────
# Usage: puma_format "# Heading\n\nSome **bold** text"
puma_format() {
    local text="$1"
    if $PUMA_HAS_GUM; then
        gum format "$text"
    else
        echo "$text" | sed -E 's/\*\*(.*?)\*\*/\1/g; s/^# //; s/^## //'
    fi
}

# ── Filter ────────────────────────────────────────────────────────────
# Usage: choice="$(puma_filter "Search:" <<< "item1\nitem2\nitem3")"
puma_filter() {
    local prompt="${1:-Filter:}"
    if $PUMA_HAS_GUM; then
        gum filter --prompt "$prompt: "
    else
        cat
    fi
}
