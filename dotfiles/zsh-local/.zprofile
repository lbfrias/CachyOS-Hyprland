# Only run for login shells on TTY1, if Wayland is not running
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    exec start-hyprland > /dev/null 2>&1
fi
