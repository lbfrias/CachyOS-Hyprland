#!/usr/bin/env bash
# Watches Hyprland events and shows/hides the secondary waybar
# when a fullscreen window is active on DP-1.

MAIN_MONITOR="DP-1"
MONITOR_ID=$(hyprctl monitors -j | jq -r --arg monname $MAIN_MONITOR '.[] | select(.name == $monname) | .id')
bar_visible=false

show_bar() {
    if ! $bar_visible; then
        pkill -SIGUSR1 waybar 2>/dev/null
        # SIGUSR1 toggles, so we track state ourselves
        # Instead use waybar's show/hide via hyprctl layer rules or direct signal
        # We'll use pkill targeting by name via waybar's bar name class
        bar_visible=true
    fi
}

hide_bar() {
    if $bar_visible; then
        pkill -SIGUSR1 waybar 2>/dev/null
        bar_visible=false
    fi
}

check_fullscreen() {
    # Get the active workspace ID on DP-1
    local active_ws_on_main
    active_ws_on_main=$(hyprctl monitors -j | jq -r --arg monname "$MAIN_MONITOR" \
        '.[] | select(.name == $monname) | .activeWorkspace.id')

    # Count fullscreen windows on DP-1's currently visible workspace
    local fs_on_main
    fs_on_main=$(hyprctl clients -j | jq -r \
        --argjson mon "$MONITOR_ID" \
        --argjson ws "$active_ws_on_main" \
        '[.[] | select(.fullscreen > 0 and .monitor == $mon and .workspace.id == $ws)] | length')

    if [ "$fs_on_main" -gt 0 ]; then
        show_bar
    else
        hide_bar
    fi
}

# Listen to Hyprland socket events
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
while read -r line; do
    case "$line" in
        fullscreen*|activewindow*|closewindow*|movewindow*)
            check_fullscreen
            ;;
    esac
done
