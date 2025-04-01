#!/bin/bash

#
# rounded_box() - Print text inside a visually formatted box with rounded corners.
#
# Usage:
#   rounded_box [-t "Title"] [-w width] "Content"
#
# Options:
#   -t  Title text to display in the top border.
#   -w  Set the width of the box (default: 78 characters).
#   -h  Display this help message.
#
# Description:
#   This function formats and prints text within a Unicode box with rounded corners.
#   It supports multi-line content, automatic text wrapping, and adjustable width.
#   If a title is specified, it is aligned with the top border.
#
# Features:
#   - Customizable box width.
#   - Optional title display.
#   - Multi-line content handling with word wrapping


rounded_box() {
    local u_left u_right b_left b_right h_bar v_bar h_width title content
    u_left="\xe2\x95\xad"   # upper left corner
    u_right="\xe2\x95\xae"  # upper right corner
    b_left="\xe2\x95\xb0"   # bottom left corner
    b_right="\xe2\x95\xaf"  # bottom right corner
    h_bar="\xe2\x94\x80"    # horizontal bar
    v_bar="\xe2\x94\x82"    # vertical bar
    h_width="78"            # default horizontal width

    # Reset OPTIND
    OPTIND=1

    while getopts ":ht:w:" flags; do
        case "${flags}" in
            (h)
                printf -- '%s\n' "rounded_box (-t [title] -w [width in columns]) [content]" >&2
                return 0
            ;;
            (t) title="${OPTARG}" ;;
            (w) h_width="$(( OPTARG - 2 ))" ;;
            (*) : ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    # What remains after getopts is our content
    # We store it this way to support multi-line input
    content=$(printf -- '%s ' "${@}")

    # Print our top bar
    printf -- '%b' "${u_left}"
    # If the title is defined, then make space for it within the top bar
    if [[ -n "${title}" ]]; then
        # Calculate visual width of title (accounting for UTF-8)
        title_visual_width=$(printf -- '%s' "${title}" | wc -m)
        title_padding=$(( h_width - title_visual_width - 2 ))

        printf -- '%b %s ' "${h_bar}" "${title}"
        for (( i=0; i<title_padding; i++)); do
            printf -- '%b' "${h_bar}"
        done
    # Otherwise, just print the full bar
    else
        for (( i=0; i<h_width; i++)); do
            printf -- '%b' "${h_bar}"
        done
    fi
    printf -- '%b\n' "${h_bar}${u_right}"

    # Print our content
    if [[ -n "${content}" ]]; then
        # Replace literal "\n" with actual newlines
        processed_content=$(printf -- '%s' "${content}" | sed 's/\\n/\n/g')

        # Process each line, including empty lines
        while IFS= read -r line || [[ -n "${line}" ]]; do
            # Wrap long lines with fold
            while IFS= read -r folded_line; do
                line_visual_width=$(printf -- '%s' "${folded_line}" | wc -m)
                padding_width=$(( h_width - line_visual_width ))
                printf -- '%b %s' "${v_bar}" "${folded_line}"
                printf -- '%*s' "$padding_width"
                printf -- ' %b\n' "${v_bar}"
            done < <(printf '%s\n' "${line}" | fold -s -w "${h_width}")
        done < <(printf -- '%s\n' "${processed_content}")
    else
        # Empty content - print one blank line
        printf -- '%b %*s %b\n' "${v_bar}" "$h_width" "" "${v_bar}"
    fi

    # Print our bottom bar
    printf -- '%b' "${b_left}${h_bar}"
    for (( i=0; i<h_width; i++)); do
        printf -- '%b' "${h_bar}"
    done
    printf -- '%b\n' "${h_bar}${b_right}"
}


rounded_box -t Warning -w 120 "Ignored build scripts: bcrypt, sharp.\nRun \"pnpm approve-builds\" to pick which dependencies should be allowed to run scripts."
