local wsr = hl.workspace_rule

wsr({ workspace = "1", monitor = "DP-1" })
wsr({ workspace = "2", monitor = "DP-1" })
wsr({ workspace = "3", monitor = "DP-1" })
wsr({ workspace = "name:homeassistant", default = true, monitor = "DP-3"})
wsr({ workspace = "name:chat", default = true, monitor = "DP-2", layout = "lua:vertical_chat" })
wsr({ workspace = "name:game", monitor = "DP-1" })
wsr({ workspace = "special:spotify", monitor = "DP-1" })
wsr({ workspace = "special:steam", monitor = "DP-1" })

-- Gaps and waybar handler

local MAIN_MONITOR = "DP-1"
local gaps_with_bar    = {
    gaps_in = 10,
    gaps_out = {
        top = 5,
        bottom = 20,
        left = 25,
        right = 25
    }
}
local gaps_without_bar = {
    gaps_in = 10,
    gaps_out = {
        top = 20,
        bottom = 20,
        right = 25,
        left = 25
    }
}

local manual_secondary_waybar = false

local function get_workspaces_on_monitor(monitor_name)
    local workspaces = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        if ws.monitor.name == monitor_name then
            table.insert(workspaces, ws.name)
        end
    end
    return workspaces
end

local function set_gaps_for_monitor(monitor_name, gaps)
    for _, ws_name in ipairs(get_workspaces_on_monitor(monitor_name)) do
        local selector = ws_name:match("^special:") and ws_name or "name:" .. ws_name
        hl.workspace_rule({
            workspace = selector,
            gaps_in   = gaps.gaps_in,
            gaps_out  = gaps.gaps_out,
        })
    end
end

local function is_main_waybar_hidden()
    local active_ws = hl.get_active_workspace()
    if active_ws.monitor.name ~= MAIN_MONITOR then
        return false
    end
    for _, w in ipairs(hl.get_windows()) do
        if w.fullscreen > 0 and w.workspace.id == active_ws.id then
            return true
        end
    end
    return false
end

local function show_secondary_waybars()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= MAIN_MONITOR then
            set_gaps_for_monitor(m.name, gaps_with_bar)
        end
    end
    hl.exec_cmd("pkill -SIGUSR1 waybar")
end

local function hide_secondary_waybars()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= MAIN_MONITOR then
            set_gaps_for_monitor(m.name, gaps_without_bar)
        end
    end
    hl.exec_cmd("pkill -SIGUSR2 waybar")
end

local function update_secondary_waybars()
    if manual_secondary_waybar or is_main_waybar_hidden() then
        show_secondary_waybars()
    else
        hide_secondary_waybars()
    end
end

local function init_gaps()
    set_gaps_for_monitor(MAIN_MONITOR, gaps_with_bar)
    update_secondary_waybars()
end

hl.on("hyprland.start", init_gaps)
hl.on("config.reloaded", init_gaps)

hl.on("window.fullscreen", function(window)
    if window.monitor.name == MAIN_MONITOR then
        update_secondary_waybars()
    end
end)

hl.on("workspace.active", function(workspace)
    if workspace.monitor.name == MAIN_MONITOR then
        update_secondary_waybars()
    end
end)

hl.on("window.active", function(window, reason)
    if not hl.get_active_workspace().is_empty and hl.get_active_monitor().name == MAIN_MONITOR then
        set_gaps_for_monitor(MAIN_MONITOR, gaps_with_bar)
    end
end)

SecondaryWaybar = {
    toggle = function()
        manual_secondary_waybar = not manual_secondary_waybar
        update_secondary_waybars()
    end
}
