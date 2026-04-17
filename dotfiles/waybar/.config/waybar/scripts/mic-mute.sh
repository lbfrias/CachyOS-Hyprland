#!/usr/bin/env bash

print_status() {
    SOURCE=$(pactl get-default-source)
    MUTED=$(pactl get-source-mute "$SOURCE" | awk '{print $2}')
    SOURCE_NAME=$(pactl list sources | grep -A 15 "$SOURCE" | grep 'Description:' | awk -F'Description: ' '{print $2}')

    if [ "$MUTED" = "yes" ]; then
        ICON=""
        COLOR="#ff5555"
        TEXT="Muted"
    else
        ICON=""
        COLOR="#50fa7b"
        TEXT="On"
    fi

    echo "{\"text\":\"$ICON\",\"tooltip\":\"$SOURCE_NAME\nMic: $TEXT\",\"class\":\"$MUTED\",\"color\":\"$COLOR\"}"
}

print_status
pactl subscribe | grep --line-buffered "source" | while read -r _; do
    print_status
done
