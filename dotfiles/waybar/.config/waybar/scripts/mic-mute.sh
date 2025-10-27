#!/usr/bin/env bash

while true; do
    clear
    # Get the default source (microphone)
    SOURCE=$(pactl get-default-source)

    # Check mute status
    MUTED=$(pactl get-source-mute "$SOURCE" | awk '{print $2}')

    if [ "$MUTED" = "yes" ]; then
        ICON=""   # mic mute icon (Font Awesome)
        COLOR="#ff5555"
        TEXT="Muted"
    else
        ICON=""   # mic active icon
        COLOR="#50fa7b"
        TEXT="On"
    fi

    # Output JSON for Waybar
    echo "{\"text\": \"$ICON\", \"tooltip\": \"Mic: $TEXT\", \"class\": \"$MUTED\", \"color\": \"$COLOR\"}"
    sleep 0.2
done