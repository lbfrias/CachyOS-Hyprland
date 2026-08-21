# Hyprland Configuration

Hyprland window manager setup for a multi-monitor workstation with CachyOS. Uses Lua-based configuration (Hyprland's native Lua support) for powerful programmatic customization.

## Decisions

### Why Lua Configuration?

The entire config uses Hyprland's Lua API (`hyprland.lua` + modular `config/*.lua` files) instead of the traditional `.conf` format. This enables:

- **Programmatic layouts** — custom tiling logic (see `layouts.lua` for the `vertical_chat` layout)
- **Event-driven automation** — waybar visibility tied to fullscreen state
- **Shared constants** — colors and defaults defined once, used everywhere
- **Complex keybind logic** — volume commands with 150% cap and wob integration

### Multi-Monitor Philosophy

- **DP-1** (3440×1440 ultrawide @ 240Hz) — primary workspace, always has waybar
- **DP-2** (1920×1200 portrait, rotated right) — dedicated chat workspace with custom layout
- **DP-3** (1920×1200 portrait, rotated left) — Home Assistant dashboard
- **steamdeck** — Steam Deck display for HDR gaming

Secondary monitor waybars auto-show when main monitor goes fullscreen (game mode), toggle manually with `SUPER+SHIFT+F`.

### Visual Aesthetic

Orange/warm color scheme (`colors.lua`):
- **Giant's Orange** (`#F75C1E`) — active borders, accents
- **Champagne** (`#FFE9CB`) — inactive borders
- **Chestnut** (`#894126`) — backgrounds
- Large gaps (10px in, 20-25px out) and rounded corners (25px) for a spacious feel.

### Application Routing

Windows auto-route to dedicated workspaces:
- Chat apps (Discord, Telegram, Messenger) → `name:chat` workspace on DP-2
- Home Assistant → `name:homeassistant` workspace on DP-3
- Games (Steam, Dota2, gamescope) → `name:game` workspace
- Spotify, Steam → special (scratchpad) workspaces

## Files Explained

```
.config/hypr/
├── hyprland.lua          # Entry point, loads all config modules
├── hyprlock.conf         # Lock screen config (hyprlock)
├── xdph.conf             # XDG Desktop Portal Hyprland settings
├── .luarc.json           # Lua LSP config for IDE support
├── config/
│   ├── animations.lua    # Window/workspace animations (overshoot bezier)
│   ├── autostart.lua     # Apps launched on session start
│   ├── colors.lua        # Color palette constants
│   ├── defaults.lua      # Default apps (terminal, browser, etc.)
│   ├── devices.lua       # Input device settings (Magic Trackpad)
│   ├── environment.lua   # Environment variables (cursor size, Electron hints)
│   ├── gestures.lua      # Touchpad gestures (4-finger workspace switch)
│   ├── keybinds.lua      # All keybindings
│   ├── layouts.lua       # Custom vertical_chat layout for chat workspace
│   ├── monitors.lua      # Monitor configuration (resolution, position, HDR)
│   ├── variables.lua     # Core Hyprland settings (gaps, blur, input)
│   ├── window_rules.lua  # Per-app rules (opacity, workspace, floating)
│   ├── workspace_rules.lua # Workspace-monitor bindings + dynamic gap logic
│   └── xdph.lua          # (Empty, settings in xdph.conf)
└── scripts/
    └── brightness_set.sh # DDC/CI monitor brightness control via ddcutil
```

## Key Keybindings

| Binding | Action |
|---------|--------|
| `SUPER+Return` | Terminal (kitty) |
| `SUPER+Space` | App launcher (rofi) |
| `SUPER+B` | Browser (Brave) |
| `SUPER+Q` | Close window |
| `SUPER+F` | Toggle fullscreen |
| `SUPER+V` | Toggle floating |
| `SUPER+L` | Lock screen (hyprlock) |
| `SUPER+1-0` | Switch to workspace 1-10 |
| `SUPER+CTRL+1-0` | Move window to workspace (follow) |
| `SUPER+SHIFT+1-0` | Move window to workspace (silent) |
| `SUPER+Arrow` | Move focus |
| `SUPER+SHIFT+Arrow` | Move window |
| `SUPER+S` | Toggle Spotify scratchpad |
| `SUPER+T` | Toggle Steam scratchpad |
| `SUPER+G` | Go to game workspace |
| `SUPER+A/D` | Switch to left/right monitor workspace |
| `SUPER+SHIFT+F` | Toggle secondary waybars |
| `SUPER+O` | Restart waybar |
| `SUPER+SHIFT+S` | Screenshot region (hyprshot) |
| `SUPER+CTRL+SHIFT+S` | Screenshot window |
| `XF86Audio*` | Volume control (with wob overlay) |
| `XF86MonBrightness*` | Monitor brightness (DDC/CI) |

## How to Modify

### Change Default Apps

Edit `config/defaults.lua`:
```lua
M.terminal = "kitty"      -- Change to alacritty, wezterm, etc.
M.browser = "brave"       -- Change to firefox, chromium, etc.
M.filemanager = "pcmanfm" -- Change to thunar, nautilus, etc.
```

### Add/Modify Monitors

Edit `config/monitors.lua`:
```lua
hl.monitor({ 
    output = "DP-1",           -- xrandr output name
    mode = "3440x1440@240",    -- resolution@refresh
    position = "1200x240",     -- x,y position
    scale = 1,                 -- scaling factor
    bitdepth = 10              -- optional: 10-bit color
})
```

Find monitor names with: `hyprctl monitors`

### Adjust Gaps and Borders

Edit `config/variables.lua`:
```lua
general = {
    gaps_in = 10,    -- Gap between windows
    border_size = 5, -- Border thickness
    ...
}
decoration = {
    rounding = 25,   -- Corner radius
    ...
}
```

### Change Colors

Edit `config/colors.lua`:
```lua
local colors = {
    giantsorange = "#F75C1Eff",  -- Active border
    champagne = "#FFE9CBff",     -- Inactive border
    ...
}
```

### Add Window Rules

Edit `config/window_rules.lua`:
```lua
-- Float a specific app
wr({ match = { class = "^(myapp)$" }, float = true })

-- Set opacity
wr({ match = { class = "^(myapp)$" }, opacity = 0.9 })

-- Route to workspace
wr({ match = { class = "^(myapp)$" }, workspace = "name:myworkspace" })
```

Find window class with: `hyprctl clients | grep class`

### Add Keybindings

Edit `config/keybinds.lua`:
```lua
local dsp = hl.dsp
local cmd = dsp.exec_cmd

-- Launch app
hl.bind("SUPER + X", cmd("myapp"), { description = "Opens my app" })

-- Window action
hl.bind("SUPER + Y", dsp.window.close(), { description = "Close window" })
```

### Modify Autostart

Edit `config/autostart.lua` — apps launch via `hl.on("hyprland.start", ...)`.

## Dependencies

### Required

| Package | Purpose |
|---------|---------|
| `hyprland` | Window manager (must support Lua config) |
| `hyprlock` | Lock screen |
| `hyprshot` | Screenshots |
| `kitty` | Terminal |
| `rofi` | App launcher, window switcher, emoji picker |
| `waybar` | Status bar |
| `wob` | Volume/brightness overlay bar |
| `pactl` (PulseAudio/PipeWire) | Volume control |
| `playerctl` | Media playback control |
| `swaybg` | Wallpaper |
| `hyprpolkitagent` | Polkit authentication |

### Optional (for full functionality)

| Package | Purpose |
|---------|---------|
| `brave` | Default browser |
| `pcmanfm` | File manager |
| `bitwarden-desktop` | Password manager |
| `discord`, `telegram-desktop` | Chat apps |
| `firefoxpwa` | Progressive web apps (Home Assistant, Messenger) |
| `spotify-launcher` | Spotify |
| `steam` | Gaming |
| `ddcutil` | External monitor brightness control |
| `solaar` | Logitech device manager |
| `udiskie` | Automount USB drives |
| `makop` / `mako` | Notifications |

### Fonts

- **CommitMono Nerd Font** — used throughout (hyprlock, misc settings)

## Gotchas

### Monitor Names Are Hardware-Specific

`DP-1`, `DP-2`, `DP-3` depend on your GPU/cables. Run `hyprctl monitors` and update `monitors.lua` and `workspace_rules.lua` to match your setup.

### Hyprlock Monitor Reference

`hyprlock.conf` hardcodes `monitor = DP-1`. Change this if your primary monitor differs.

### Brightness Script Requires Sudo

`scripts/brightness_set.sh` uses `sudo ddcutil`. Either:
1. Add passwordless sudo for ddcutil: `echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/ddcutil" | sudo tee /etc/sudoers.d/ddcutil`
2. Or add your user to the `i2c` group and use ddcutil without sudo

### Wob Socket Path

Volume/brightness overlays write to `$XDG_RUNTIME_DIR/wob.sock`. Ensure wob is running via systemd (`systemctl --user start wob.socket wob`).

### FirefoxPWA App IDs

Home Assistant and Messenger launch via `firefoxpwa site launch <ID>`. The IDs are extracted at runtime from `firefoxpwa profile list`. Install PWAs first via Firefox with the FirefoxPWA extension.

### Chat Layout Expects Specific Apps

The custom `vertical_chat` layout in `layouts.lua` specifically looks for Discord (top 65%) and Messenger/Telegram (bottom row). Other apps will be treated as "other" and split evenly in the bottom row.

### Secondary Waybars Signal Behavior

The waybar toggle uses POSIX signals:
- `SIGUSR1` → show secondary waybars
- `SIGUSR2` → hide secondary waybars

Your waybar config must handle these signals appropriately.

### Steam Self-Updater Float Rule

Steam's self-updater window is floated separately because it matches a different title than the main Steam window.

### Lua API Version

This config uses Hyprland's Lua API. Requires a recent Hyprland version with full Lua support. If you get errors about `hl` being undefined, your Hyprland version may be too old.

### Animations May Cause Performance Issues

The overshoot bezier animations look nice but can be demanding. Disable or simplify in `animations.lua` if you experience stuttering.
