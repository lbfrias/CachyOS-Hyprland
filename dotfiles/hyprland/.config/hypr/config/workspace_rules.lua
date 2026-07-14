local wsr = hl.workspace_rule

wsr({ workspace = "1", monitor = "DP-1" })
wsr({ workspace = "2", monitor = "DP-1" })
wsr({ workspace = "3", monitor = "DP-1" })
wsr({ workspace = "name:homeassistant", default = true, monitor = "DP-3"})
wsr({ workspace = "name:chat", default = true, monitor = "DP-2", layout = "lua:vertical_chat" })
wsr({ workspace = "special:game", monitor = "DP-1" })
wsr({ workspace = "special:spotify", monitor = "DP-1" })
wsr({ workspace = "special:steam", monitor = "DP-1" })
