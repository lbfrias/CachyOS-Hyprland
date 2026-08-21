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

-- nil = automatic, true = force show, false = force hide
local manual_override = nil
local secondary_waybars_visible = false

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
    for _, w in ipairs(hl.get_windows()) do
        if w.fullscreen > 0 and w.monitor.name == MAIN_MONITOR and w.workspace.visible then
            return true
        end
    end
    return false
end

local function show_secondary_waybars()
    if secondary_waybars_visible then return end
    secondary_waybars_visible = true
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= MAIN_MONITOR then
            set_gaps_for_monitor(m.name, gaps_with_bar)
        end
    end
    hl.exec_cmd("pkill -SIGUSR1 waybar")
end

local function hide_secondary_waybars()
    if not secondary_waybars_visible then return end
    secondary_waybars_visible = false
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= MAIN_MONITOR then
            set_gaps_for_monitor(m.name, gaps_without_bar)
        end
    end
    hl.exec_cmd("pkill -SIGUSR2 waybar")
end

local function update_secondary_waybars()
    local should_show
    if manual_override ~= nil then
        should_show = manual_override
    else
        should_show = is_main_waybar_hidden()
    end

    if should_show then
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
        manual_override = nil
        update_secondary_waybars()
    end
end)

hl.on("workspace.active", function(workspace)
    if workspace.monitor.name == MAIN_MONITOR then
        manual_override = nil
        update_secondary_waybars()
    end
end)

hl.on("special.active", function(workspace, state)
    if workspace.monitor.name == MAIN_MONITOR then
        manual_override = nil
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
        if manual_override == nil then
            manual_override = not secondary_waybars_visible
        else
            manual_override = not manual_override
        end
        update_secondary_waybars()
    end
}
