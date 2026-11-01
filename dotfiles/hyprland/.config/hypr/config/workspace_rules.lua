local wsr = hl.workspace_rule

local reference_width = 3440
local reference_height = 1440
local monitor_dimensions = {
    ["DP-1"] = { width = 3440, height = 1440 },
    ["DP-2"] = { width = 1200, height = 1920 },
    ["DP-3"] = { width = 1200, height = 1920 },
    ["steamdeck"] = { width = 1280, height = 800 },
}
local spotify_gap_profile = {
    gaps_in = 10,
    gaps_out = { top = 150, bottom = 150, left = 400, right = 400 },
}
local steam_gap_profile = {
    gaps_in = 10,
    gaps_out = { top = 150, bottom = 150, left = 400, right = 400 },
}
local special_gap_profiles = {
    ["special:spotify"] = spotify_gap_profile,
    ["special:steam"] = steam_gap_profile,
}

local function round(value)
    return math.floor(value + 0.5)
end

local function get_scaled_special_gaps(workspace_name, monitor_name)
    local profile = special_gap_profiles[workspace_name]
    local dimensions = monitor_dimensions[monitor_name]
    if not profile or not dimensions then return nil end

    local gaps_in_scale =
        math.min(dimensions.width, dimensions.height) /
        math.min(reference_width, reference_height)
    local base_gaps_out = profile.gaps_out
    if type(base_gaps_out) == "number" then
        base_gaps_out = {
            top = base_gaps_out,
            bottom = base_gaps_out,
            left = base_gaps_out,
            right = base_gaps_out,
        }
    end

    return {
        gaps_in = round(profile.gaps_in * gaps_in_scale),
        gaps_out = {
            top = round(base_gaps_out.top * dimensions.height / reference_height),
            bottom = round(base_gaps_out.bottom * dimensions.height / reference_height),
            left = round(base_gaps_out.left * dimensions.width / reference_width),
            right = round(base_gaps_out.right * dimensions.width / reference_width),
        },
    }
end

local function apply_special_workspace_gaps()
    for _, workspace in ipairs(hl.get_workspaces()) do
        local gaps = get_scaled_special_gaps(workspace.name, workspace.monitor.name)
        if gaps then
            hl.workspace_rule({
                workspace = workspace.name,
                gaps_in = gaps.gaps_in,
                gaps_out = gaps.gaps_out,
            })
        end
    end
end

wsr({ workspace = "1", monitor = "DP-1" })
wsr({ workspace = "2", monitor = "DP-1" })
wsr({ workspace = "3", monitor = "DP-1" })
wsr({ workspace = "name:homeassistant", default = true, monitor = "DP-3"})
wsr({ workspace = "name:chat", default = true, monitor = "DP-2", layout = "lua:vertical_chat" })
wsr({ workspace = "name:game", monitor = "DP-1" })
wsr({
    workspace = "special:spotify",
    gaps_in = spotify_gap_profile.gaps_in,
    gaps_out = spotify_gap_profile.gaps_out,
})
wsr({
    workspace = "special:steam",
    gaps_in = steam_gap_profile.gaps_in,
    gaps_out = steam_gap_profile.gaps_out,
    layout = "lua:steam",
})

-- Gaps and waybar handler

local MAIN_MONITOR = "DP-1"
local MAIN_FRIENDS_SIZE = {
    width = 376,
    height = 1060,
}

local function sync_steam_friends_window()
    for _, window in ipairs(hl.get_windows()) do
        if string.lower(window.class or "") == "steam"
            and string.lower(window.initial_title or "") == "friends list"
            and window.monitor then
            local should_float = window.monitor.name ~= MAIN_MONITOR
            local is_floating = window.floating

            if should_float ~= is_floating then
                hl.dispatch(hl.dsp.window.float({
                    window = window,
                    action = should_float and "set" or "unset",
                }))
            end

            if should_float then
                hl.dispatch(hl.dsp.window.resize({
                    window = window,
                    x = MAIN_FRIENDS_SIZE.width,
                    y = MAIN_FRIENDS_SIZE.height,
                    relative = false,
                }))
                hl.dispatch(hl.dsp.window.center({ window = window }))
            end
        end
    end
end

local gaps_with_bar    = {
    gaps_in = 10,
    gaps_out = {
        top = 5,
        bottom = 20,
        left = 25,
        right = 25
    }
}
local main_gaps_with_bar = {
    gaps_in = 10,
    gaps_out = {
        top = 10,
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
        if not ws_name:match("^special:") then
            hl.workspace_rule({
                workspace = "name:" .. ws_name,
                gaps_in   = gaps.gaps_in,
                gaps_out  = gaps.gaps_out,
            })
        end
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
    set_gaps_for_monitor(MAIN_MONITOR, main_gaps_with_bar)
    apply_special_workspace_gaps()
    sync_steam_friends_window()
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

hl.on("workspace.special_active", function(workspace)
    apply_special_workspace_gaps()
    sync_steam_friends_window()
    if workspace and workspace.monitor and workspace.monitor.name == MAIN_MONITOR then
        manual_override = nil
        update_secondary_waybars()
    elseif not workspace then
        manual_override = nil
        update_secondary_waybars()
    end
end)

hl.on("window.open", sync_steam_friends_window)
hl.on("window.move_to_workspace", sync_steam_friends_window)

hl.on("window.active", function(window, reason)
    if window and hl.get_active_monitor().name == MAIN_MONITOR then
        local active_ws = hl.get_active_workspace()
        if active_ws and not active_ws.is_empty then
            set_gaps_for_monitor(MAIN_MONITOR, main_gaps_with_bar)
        end
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
