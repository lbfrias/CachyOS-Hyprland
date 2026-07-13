local M = {}

M.filemanager = "pcmanfm"
M.applauncher = [[pkill rofi || rofi -show drun -sorting-method "fzf"]]
M.windowswitcher = [[rofi -show window -sorting-method "fzf"]]
M.emojiselector = [[rofi -show emoji -sorting-method "fzf"]]

M.terminal = "kitty"
M.browser = "brave"
M.chatapps = [[discord --enable-features=UseOzonePlatform --ozone-platform=wayland & Telegram & ID=$(firefoxpwa profile list | grep -i messenger | awk -F'[()]' '{print $2}') && { pgrep -f "$ID" > /dev/null || firefoxpwa site launch "$ID" & }]]
M.homeassistant = [[firefoxpwa site launch $(firefoxpwa profile list | grep -i "home assistant" | awk -F'[()]' '{print $2}')]]
M.ide = "code"
M.idlehandler = [[swayidle -w timeout 300 'swaylock -f -c 000000' before-sleep 'swaylock -f -c 000000']]
M.passwordmanager = "bitwarden-desktop"

M.brightnessScript = "$HOME/.config/hypr/scripts/brightness_set.sh"

M.shotregion = "hyprshot -m region --clipboard-only --freeze --silent"
M.shotwindow = "hyprshot -m window --clipboard-only --freeze --silent"

M.wobSocket = "$XDG_RUNTIME_DIR/wob.sock"

return M
