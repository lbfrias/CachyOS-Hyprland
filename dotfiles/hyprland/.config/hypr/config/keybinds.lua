local defaults = require("config/defaults")

---------- Helper functions ----------
local dsp = hl.dsp
local cmd = dsp.exec_cmd
local function change_volume(action, step)
    local socket = defaults.wobSocket
    -- Fallback to "5%" if no specific granularity is provided
    local local_step = step or "5"

    if action == "increase" then
        return [[pactl set-sink-volume @DEFAULT_SINK@ +]] .. local_step .. [[% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>150) system("pactl set-sink-volume @DEFAULT_SINK@ 150%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > ]] .. socket

    elseif action == "decrease" then
        return [[pactl set-sink-volume @DEFAULT_SINK@ -]] .. local_step .. [[% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>150) system("pactl set-sink-volume @DEFAULT_SINK@ 150%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > ]] .. socket

    elseif action == "mute" then
        return [[pactl set-sink-mute @DEFAULT_SINK@ toggle && (pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo 0 > ]] .. socket .. [[ || pactl get-sink-volume @DEFAULT_SINK@ | sed -En 's/.*front-left: [0-9]+ \/ *([0-9]+)% .*/\1/p' > ]] .. socket .. [[)]]

    else
        return "echo 'Invalid audio action'"
    end
end

---------- Application Shortcuts ----------

hl.bind("SUPER + RETURN", cmd(defaults.terminal), { description = "Opens preferred terminal emulator" })
hl.bind("SUPER + B", cmd(defaults.browser), { description = "Opens preferred browser" })
hl.bind("SUPER + H", cmd(defaults.homeassistant), { description = "Opens Home Assistant" })
hl.bind("SUPER + E", cmd(defaults.filemanager), { description = "Opens File Manager" })
hl.bind("SUPER + M", cmd(defaults.chatapps), { description = "Opens chat apps" })
hl.bind("SUPER + P", cmd(defaults.passwordmanager), { description = "Opens password manager" })
hl.bind("SUPER + SPACE", cmd(defaults.applauncher), { description = "Opens Application Launcher" })
hl.bind("SUPER + TAB", cmd(defaults.windowswitcher), { description = "Opens Window Switcher" })
hl.bind("SUPER + SHIFT + E", cmd(defaults.emojiselector), { description = "Opens Emoji Selector" })
hl.bind("SUPER + SHIFT + S", cmd(defaults.shotregion), { description = "Screenshot an area" })
hl.bind("SUPER + CTRL + SHIFT + S", cmd(defaults.shotwindow), { description = "Screenshot a window" })

---------- Volume Control ----------

hl.bind("XF86AudioRaiseVolume", cmd(change_volume("increase", "5")), { description = "Increase volume", repeating = true })
hl.bind("XF86AudioLowerVolume", cmd(change_volume("decrease", "5")), { description = "Decrease volume", repeating = true })
hl.bind("XF86AudioMute", cmd(change_volume("mute")), { description = "Mute volume" })
hl.bind("CTRL + XF86AudioMute", cmd([[pactl set-source-mute @DEFAULT_SOURCE@ toggle]]), { description = "Mute microphone" })

---------- Playback Control ----------

hl.bind("XF86AudioPlay", cmd([[playerctl play-pause]]), { description = "Play/Pause" })
hl.bind("XF86AudioNext", cmd([[playerctl next]]), { description = "Next track" })
hl.bind("XF86AudioPrev", cmd([[playerctl previous]]), { description = "Previous track" })

---------- Brightness Control ----------

hl.bind("XF86MonBrightnessUp", cmd(defaults.brightnessScript .. [[ up 5 6 | cat > ]] .. defaults.wobSocket), { description = "Increase monitor ID 6 brightness by 5%" })
hl.bind("XF86MonBrightnessDown", cmd(defaults.brightnessScript .. [[ down 5 6 | cat > ]] .. defaults.wobSocket), { description = "Decrease monitor ID 6 brightness by 5%" })
hl.bind("CTRL + XF86MonBrightnessUp", cmd(defaults.brightnessScript .. [[ up 5 8 | cat > ]] .. defaults.wobSocket), { description = "Increase monitor ID 8 brightness by 5%" })
hl.bind("CTRL + XF86MonBrightnessDown", cmd(defaults.brightnessScript .. [[ down 5 8 | cat > ]] .. defaults.wobSocket), { description = "Decrease monitor ID 8 brightness by 5%" })
hl.bind("ALT + XF86MonBrightnessUp", cmd(defaults.brightnessScript .. [[ up 5 7 | cat > ]] .. defaults.wobSocket), { description = "Increase monitor ID 7 brightness by 5%" })
hl.bind("ALT + XF86MonBrightnessDown", cmd(defaults.brightnessScript .. [[ down 5 7 | cat > ]] .. defaults.wobSocket), { description = "Decrease monitor ID 7 brightness by 5%" })

---------- Other System Control ----------
hl.bind("SUPER + L", cmd("hyprlock"), { description = "Locks the screen" })
hl.bind("SUPER + SHIFT + F", function() SecondaryWaybar.toggle() end, {description = "Toggle secondary waybars"})
hl.bind("SUPER + O", cmd("pkill -9 waybar; waybar"), { description = "Restarts waybar" })

---------- Window Control and Navigation ----------

hl.bind("SUPER + mouse:272", dsp.window.drag(), { description = "Moves window in specified direction" })
hl.bind("SUPER + mouse:273", dsp.window.resize(), { description = "Resizes window in specified direction" })
hl.bind("SUPER + V", dsp.window.float({ action = "toggle" }), { description = "Toggle window float" })
hl.bind("SUPER + F", dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle window fullscreen" })
hl.bind("SUPER + Q", dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + left", dsp.focus({ direction = "left" }), { description = "Move focus to the left" })
hl.bind("SUPER + right", dsp.focus({ direction = "right" }), { description = "Move focus to the right" })
hl.bind("SUPER + up", dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind("SUPER + down", dsp.focus({ direction = "down" }), { description = "Move focus down" })
hl.bind("SUPER + SHIFT + left", dsp.window.move({ direction = "left" }), { description = "Move active window to the left" })
hl.bind("SUPER + SHIFT + right", dsp.window.move({ direction = "right" }), { description = "Move active window to the right" })
hl.bind("SUPER + SHIFT + up", dsp.window.move({ direction = "up" }), { description = "Move active window up" })
hl.bind("SUPER + SHIFT + down", dsp.window.move({ direction = "down" }), { description = "Move active window down" })

---------- Workspace Control and Navigation ----------

hl.bind("SUPER + 1", dsp.focus({ workspace = 1 }), { description = "Switch to workspace 1" })
hl.bind("SUPER + 2", dsp.focus({ workspace = 2 }), { description = "Switch to workspace 2" })
hl.bind("SUPER + 3", dsp.focus({ workspace = 3 }), { description = "Switch to workspace 3" })
hl.bind("SUPER + 4", dsp.focus({ workspace = 4 }), { description = "Switch to workspace 4" })
hl.bind("SUPER + 5", dsp.focus({ workspace = 5 }), { description = "Switch to workspace 5" })
hl.bind("SUPER + 6", dsp.focus({ workspace = 6 }), { description = "Switch to workspace 6" })
hl.bind("SUPER + 7", dsp.focus({ workspace = 7 }), { description = "Switch to workspace 7" })
hl.bind("SUPER + 8", dsp.focus({ workspace = 8 }), { description = "Switch to workspace 8" })
hl.bind("SUPER + 9", dsp.focus({ workspace = 9 }), { description = "Switch to workspace 9" })
hl.bind("SUPER + 0", dsp.focus({ workspace = 10 }), { description = "Switch to workspace 10" })
hl.bind("SUPER + A", dsp.focus({ workspace = "name:homeassistant" }), { description = "Switch to left monitor" })
hl.bind("SUPER + D", dsp.focus({ workspace = "name:chat" }), { description = "Switch to right monitor" })
hl.bind("SUPER + G", dsp.focus({ workspace = "name:game" }), { description = "Switch to game workspace" })
hl.bind("SUPER + S", dsp.workspace.toggle_special("spotify"))
hl.bind("SUPER + T", dsp.workspace.toggle_special("steam"))
-- hl.bind("SUPER + G", dsp.workspace.toggle_special("game"))
hl.bind("SUPER + CTRL + 1", dsp.window.move({ workspace = 1 }), { description = "Move window and switch to workspace 1" })
hl.bind("SUPER + CTRL + 2", dsp.window.move({ workspace = 2 }), { description = "Move window and switch to workspace 2" })
hl.bind("SUPER + CTRL + 3", dsp.window.move({ workspace = 3 }), { description = "Move window and switch to workspace 3" })
hl.bind("SUPER + CTRL + 4", dsp.window.move({ workspace = 4 }), { description = "Move window and switch to workspace 4" })
hl.bind("SUPER + CTRL + 5", dsp.window.move({ workspace = 5 }), { description = "Move window and switch to workspace 5" })
hl.bind("SUPER + CTRL + 6", dsp.window.move({ workspace = 6 }), { description = "Move window and switch to workspace 6" })
hl.bind("SUPER + CTRL + 7", dsp.window.move({ workspace = 7 }), { description = "Move window and switch to workspace 7" })
hl.bind("SUPER + CTRL + 8", dsp.window.move({ workspace = 8 }), { description = "Move window and switch to workspace 8" })
hl.bind("SUPER + CTRL + 9", dsp.window.move({ workspace = 9 }), { description = "Move window and switch to workspace 9" })
hl.bind("SUPER + CTRL + 0", dsp.window.move({ workspace = 10 }), { description = "Move window and switch to workspace 10" })
hl.bind("SUPER + SHIFT + 1", dsp.window.move({ workspace = 1, follow = false }), { description = "Move window silently to workspace 1" })
hl.bind("SUPER + SHIFT + 2", dsp.window.move({ workspace = 2, follow = false }), { description = "Move window silently to workspace 2" })
hl.bind("SUPER + SHIFT + 3", dsp.window.move({ workspace = 3, follow = false }), { description = "Move window silently to workspace 3" })
hl.bind("SUPER + SHIFT + 4", dsp.window.move({ workspace = 4, follow = false }), { description = "Move window silently to workspace 4" })
hl.bind("SUPER + SHIFT + 5", dsp.window.move({ workspace = 5, follow = false }), { description = "Move window silently to workspace 5" })
hl.bind("SUPER + SHIFT + 6", dsp.window.move({ workspace = 6, follow = false }), { description = "Move window silently to workspace 6" })
hl.bind("SUPER + SHIFT + 7", dsp.window.move({ workspace = 7, follow = false }), { description = "Move window silently to workspace 7" })
hl.bind("SUPER + SHIFT + 8", dsp.window.move({ workspace = 8, follow = false }), { description = "Move window silently to workspace 8" })
hl.bind("SUPER + SHIFT + 9", dsp.window.move({ workspace = 9, follow = false }), { description = "Move window silently to workspace 9" })
hl.bind("SUPER + SHIFT + 0", dsp.window.move({ workspace = 10, follow = false }), { description = "Move window silently to workspace 10" })
