local colors = require("config/colors")

hl.config({
    general = {
        gaps_in = 10,
        gaps_out = {
            top = 5,
            bottom = 20,
            left = 25,
            right = 25
        },
        border_size = 5,
        col = {
            active_border =  colors.giantsorange,
            inactive_border = colors.champagne
        },
        layout = "dwindle",
        snap = {
            enabled = true
        }
    },

    animations = {
        enabled = true
    },

    decoration = {
        active_opacity = 1,
        rounding = 25,
        blur = {
            size = 6,
            passes = 3,
            xray = true,
            new_optimizations = true,
            ignore_opacity = true
        },
        shadow = {
            enabled = true,
            range = 20,
            render_power = 2,
            color = "#000000af"
        }
    },

    input = {
        follow_mouse = 2,
        float_switch_override_focus = 0,
        sensitivity = 0.7,
        accel_profile = "flat",
        numlock_by_default = true,
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.2,
            clickfinger_behavior = true,
            drag_3fg = 1,
            tap_and_drag = true,
        }
    },

    gestures = {
        workspace_swipe_distance = 600,
        workspace_swipe_cancel_ratio = 0.3,
        workspace_swipe_direction_lock = false,
        workspace_swipe_forever = true,
        workspace_swipe_min_speed_to_force = 10,
    },

    binds = {
        allow_workspace_cycles = 1,
        workspace_back_and_forth = 1,
        workspace_center_on = 1,
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = true
    },

    misc = {
        font_family = "CommitMono Nerd Font Propo",
        splash_font_family = "CommitMono Nerd Font Propo",
        disable_hyprland_logo = true,
        middle_click_paste = false,
        col = {
            splash = colors.giantsorange,
        },
        background_color = colors.chestnut,
        enable_swallow = true,
        swallow_regex = "^(kitty|pcmanfm)$",
        focus_on_activate = true,
        vrr = 2
    },

    render = {
        direct_scanout = true
    },

    dwindle = {
        special_scale_factor = 0.8,
        preserve_split = true
    },

    master = {
        new_status = "master",
        special_scale_factor = 0.8
    }
})
