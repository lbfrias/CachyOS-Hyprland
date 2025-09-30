#!/usr/bin/env bash

STATE_FILE="/tmp/brightness_current"
DEBOUNCE_FILE="/tmp/brightness_debounce"

# debounce repeated calls
if [ ! -f "$DEBOUNCE_FILE" ]; then
touch "$DEBOUNCE_FILE"

    # Ensure state file exists
    if [[ ! -f "$STATE_FILE" ]]; then
        touch "$STATE_FILE"
    fi

    usage() {
        echo "Usage: $0 {up|down|set} <value> <bus_number>"
        echo "Example: $0 up 10 5"
        rm "$DEBOUNCE_FILE"
        exit 1
    }

    [[ $# -ne 3 ]] && usage
    ACTION=$1
    VALUE=$2
    BUS=$3

    if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
        echo "Error: value must be an integer"
        rm "$DEBOUNCE_FILE"
        usage
    fi

    # Get current brightness from state or query
    CURRENT=$(grep "^$BUS=" "$STATE_FILE" | cut -d= -f2)
    if [[ -z "$CURRENT" ]]; then
        CURRENT=$(ddcutil --bus=$BUS getvcp 10 | awk -F 'current value = ' '{print $2}' | awk '{print $1}' | tr -d ',')
        [[ -z "$CURRENT" ]] && CURRENT=50
        echo "$BUS=$CURRENT" >> "$STATE_FILE"
    fi

    # Sanitize just in case
    CURRENT=$(echo "$CURRENT" | tr -d ',')

    NEW=$CURRENT
    case $ACTION in
        up)
            NEW=$((CURRENT + VALUE))
            ;;
        down)
            NEW=$((CURRENT - VALUE))
            ;;
        set)
            NEW=$VALUE
            ;;
        *)
            usage
            ;;
    esac

    # Clamp 0–100
    if [[ $NEW -gt 100 ]]; then
        NEW=100
    elif [[ $NEW -lt 0 ]]; then
        NEW=0
    fi

    # Apply brightness with extra options
    sudo ddcutil --bus=$BUS setvcp 10 $NEW \
        --enable-dynamic-sleep \
        --noverify \
        --maxtries 1,1,1 \
        --enable-capabilities-cache \
        --skip-ddc-checks

    # Update state
    sed -i "/^$BUS=/d" "$STATE_FILE"
    echo "$BUS=$NEW" >> "$STATE_FILE"
        
    # Print new value for consumption of wob
    echo "$NEW"
    
rm "$DEBOUNCE_FILE"
fi