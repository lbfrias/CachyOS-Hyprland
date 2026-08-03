local wsr = hl.workspace_rule

wsr({ workspace = "1", monitor = "DP-1" })
wsr({ workspace = "2", monitor = "DP-1" })
wsr({ workspace = "3", monitor = "DP-1" })
wsr({ workspace = "name:homeassistant", default = true, monitor = "DP-3"})
wsr({ workspace = "name:chat", default = true, monitor = "DP-2", layout = "lua:vertical_chat" })
wsr({ workspace = "special:game", monitor = "DP-1" })
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

local enable_secondary_waybar = false

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

local function has_active_fullscreen_on_main()
    for _, w in ipairs(hl.get_windows()) do
        if w.fullscreen > 0 and w.workspace.active and w.monitor.name == MAIN_MONITOR then
            return true
        end
    end
    return false
end

local function update_secondary_monitors()
    if has_active_fullscreen_on_main() or enable_secondary_waybar then
        for _, m in ipairs(hl.get_monitors()) do
            if m.name ~= MAIN_MONITOR then
                set_gaps_for_monitor(m.name, gaps_with_bar)
            end
        end
        hl.exec_cmd("pkill -SIGUSR1 waybar")
    else
        for _, m in ipairs(hl.get_monitors()) do
            if m.name ~= MAIN_MONITOR then
                set_gaps_for_monitor(m.name, gaps_without_bar)
            end
        end
        hl.exec_cmd("pkill -SIGUSR2 waybar")
    end
end

local default_gaps = function()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name == MAIN_MONITOR then
            set_gaps_for_monitor(m.name, gaps_with_bar)
        else
            update_secondary_monitors()
        end
    end
end

hl.on("hyprland.start", function()
    default_gaps()
end)

hl.on("config.reloaded", function()
    default_gaps()
end)

hl.on("window.fullscreen", function(window)
    if window.monitor.name == MAIN_MONITOR then
        if window.fullscreen == 0 and enable_secondary_waybar then
            SecondaryWaybar.toggle()
        else
            update_secondary_monitors()
        end
    end
end)

hl.on("window.active", function(window, reason)
    if not hl.get_active_workspace().is_empty and hl.get_active_monitor().name == MAIN_MONITOR then
        set_gaps_for_monitor(MAIN_MONITOR, gaps_with_bar)
    end
end)

SecondaryWaybar = {
    toggle = function()
        enable_secondary_waybar = not enable_secondary_waybar
        update_secondary_monitors()
    end
}
