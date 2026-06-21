local wsr = hl.workspace_rule

wsr({ workspace = "1", monitor = "DP-1" })
wsr({ workspace = "2", monitor = "DP-1" })
wsr({ workspace = "3", monitor = "DP-1" })
wsr({ workspace = "1000", default = true, monitor = "DP-3", default_name = "left" })
wsr({ workspace = "2000", default = true, monitor = "DP-2", default_name = "right", layout = "lua:vertical_chat" })
wsr({ workspace = "name:game", monitor = "DP-1" })
wsr({ workspace = "name:spotify", monitor = "DP-1" })
wsr({ workspace = "name:steam", monitor = "DP-1" })
