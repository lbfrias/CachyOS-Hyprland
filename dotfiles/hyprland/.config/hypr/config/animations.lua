hl.curve( "overshoot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "overshoot", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "overshoot", style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "overshoot", style = "popin" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "overshoot", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "overshoot", style = "slide" })
