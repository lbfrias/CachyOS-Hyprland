local colors = require("config/colors")
local wr = hl.window_rule
local lr = hl.layer_rule

-- Float Necessary Windows
wr({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
wr({ match = { class = "^()$", title = "^[Pp]icture[ -][Ii]n[ -][Pp]icture$" }, float = true })
wr({ match = { class = "^()$", title = "^(Save File)$" }, float = true })
wr({ match = { class = "^()$", title = "^(Open File)$" }, float = true })
wr({ match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland|hyprland-share-picker|hyprland-preview-share-picker)(.*)$" }, float = true })
wr({ match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" }, float = true })
wr({ match = { class = "^(CachyOSHello)$" }, float = true })
wr({ match = { class = "^(zenity)$" }, float = true })
wr({ match = { class = "^(Steam)$", title = "^(Steam - Self Updater)$" }, float = true })
wr({ match = { class = "^(python3)$", title = "^(.*HP Device Manager.*)$" }, float = true })

-- Set opacity rules
wr({ match = { class = "^(FFPWA.*)$" }, opacity = 0.85 })
wr({ match = { class = "^(kitty)$" }, opacity = 0.75, scroll_touchpad = 0.4 })
wr({ match = { class = "^(FFPWA.*)$", initial_title = "^(Jellyfin)$" }, opacity = 1 })
wr({ match = { class = "^(pcmanfm)$" }, opacity = 0.7 })
wr({ match = { class = "^(discord)$" }, opacity = 0.85 })
wr({ match = { class = "^(org.telegram.desktop)$" }, opacity = 0.85 })
wr({ match = { class = "^(code)$" }, opacity = 0.9 })

-- General window rules
wr({ match = { class = "^(brave-browser)$" }, scroll_touchpad = 0.1 })
wr({ match = { initial_class = "^(spotify)$" }, opacity = 0.7, no_initial_focus = true, suppress_event = "activatefocus", workspace = "special:spotify" })
wr({ match = { class = "^(kitty)$", title = "^(bluetui)$" }, float = true, size = { 540, 343 }, move = "100%-w-20 4%", animation = "slide down" })
wr({ match = { class = "^(blueman-manager)$" }, float = true, size = { 540, 343 }, move = "100%-w-20 4%", animation = "slide down" })
wr({ match = { class = "^(nm-connection-editor)$" }, float = true, size = { 540, 343 }, move = "100%-w-20 4%", animation = "slide down" })
wr({ match = { class = "^(dota2|steam_app.*|gamescope)$" }, workspace = "special:game" })
wr({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
wr({ match = { class = "^(steam)$" }, size = "100% 100%", workspace = "special:steam" })
wr({ match = { title = "^[Pp]icture[ -][Ii]n[ -][Pp]icture$" }, float = true, size = { 960, 540 } })
wr({ match = { class = "^(org.mozilla.firefox)$" }, no_blur = true })
wr({ match = { title = "^(Bitwarden)$" }, float = true, size = { 1200, 600 } })
wr({ match = { class = "^(org.telegram.desktop)$" }, workspace = "name:chat", no_initial_focus = true })
wr({ match = { class = "^(FFPWA.*)$", title = "^(Messenger)$" }, workspace = "name:chat", no_initial_focus = true })
wr({ match = { class = "^(discord)$" }, workspace = "name:chat", no_initial_focus = true })
wr({ match = { class = "^(FFPWA.*)$", title = "^(.*Home Assistant.*)$" }, workspace = "name:homeassistant", no_initial_focus = true })
wr({ match = { class = "^(nl.jknaapen.fladder)$" }, maximize = true })

-- Decorations related to floating windows on workspaces 1 to 10
wr({ match = { float = true, workspace = "w[fv1-10]" }, border_size = 2, border_color = colors.giantsorange, rounding = 8 })

-- Decorations related to tiling windows on workspaces 1 to 10
wr({ match = { float = false, workspace = "f[1-10]" }, border_size = 3, rounding = 4 })

wr({ match = { class = "^(rofi)$" }, rounding = 16, opaque = true })

-- Windows Rules End --

-- Layers Rules --
lr({ match = { namespace = "logout_dialog" }, animation = "slide top" })
-- lr({ match = { namespace = "waybar" }, animation = "popin 50%" })
lr({ match = { namespace = "waybar" }, animation = "slide down" })
lr({ match = { namespace = "rofi" }, xray = true, blur = true, ignore_alpha = 0.1, no_anim = true })
lr({ match = { namespace = "wallpaper" }, animation = "fade 50%" })
-- Layers Rules End --
