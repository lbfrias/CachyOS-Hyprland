# Waybar Configuration

Status bar for Hyprland with a multi-monitor setup featuring rounded pill-style bars and a warm orange color scheme.

## Purpose

This Waybar configuration provides a minimal, centered status bar that:
- Displays workspace indicators, system tray, audio controls, Bluetooth status, clock, and power menu
- Supports multi-monitor setups with distinct bars for primary (`DP-1`) and secondary monitors (`DP-2`, `DP-3`)
- Auto-hides secondary bars when fullscreen content is active on the main monitor

---

## Design Decisions

### Multi-Bar Architecture
Two bar configurations exist:
| Bar | Output | Behavior |
|-----|--------|----------|
| `main` | DP-1 | Always visible |
| `secondary` | DP-2, DP-3 | Hidden by default, toggled via SIGUSR1/SIGUSR2 signals |

The secondary bar starts hidden (`start_hidden: true`) and can be shown/hidden programmatically—used by the fullscreen watcher script.

### Module Layout
All modules are center-aligned (`modules-center`) for a clean, floating pill aesthetic. The module order:
1. **Workspaces** — Regular numbered workspaces
2. **Workspaces#special** — Named special workspaces (Spotify, Steam icons)
3. **Tray** — System tray icons
4. **Pulseaudio** — Output volume with mute toggle
5. **Pulseaudio#source** — Microphone status (highlighted red when unmuted)
6. **Bluetooth** — Connection status, opens Blueman on click
7. **Clock** — Day, date, and time with seconds
8. **Power menu** — GTK menu with lock/suspend/hibernate/shutdown/reboot

### Persistent Workspaces
Workspaces are bound to specific monitors:
- **DP-1**: Workspaces 1, 2, 3
- **DP-2**: `chat` workspace
- **DP-3**: `homeassistant` workspace

### Special Workspaces
A second workspace widget (`#special`) shows only special/scratchpad workspaces (Spotify, Steam), filtering out regular numbered workspaces via regex.

### Styling Philosophy
- **Pill-shaped bars** with heavy border-radius (`50em`)
- **Semi-transparent dark background** (`rgba(20, 9, 0, 0.6)`)
- **Warm orange accent palette**: `#FF8A60`, `#FF5C00`, `#F75C1E`
- **Cream text**: `#FFE9CB`
- **Nerd Font icons** throughout

---

## Files

| File | Purpose |
|------|---------|
| `config` | JSON5 bar configuration—modules, positioning, click actions |
| `style.css` | GTK3 CSS styling—colors, spacing, animations |
| `power_menu.xml` | GTK menu definition for the power button dropdown |
| `scripts/waybar-fullscreen-watch.sh` | Shows secondary bars when main monitor has fullscreen content |

### config

JSON5 format (allows trailing commas and comments). Defines two bar objects in an array:
- Each bar specifies `output`, `name` (used in CSS selectors), and module configuration
- Modules support click actions via `on-click`, `on-click-right`
- Custom modules (like `custom/power`) can use GTK menus

### style.css

Key selectors:
- `.main` / `.secondary` — Per-bar font sizing
- `window#waybar` — Base bar styling
- `window#waybar > box` — The pill container
- `#workspaces button` — Workspace buttons (circular normally, pill when active)
- Module-specific: `#pulseaudio`, `#bluetooth`, `#clock`, etc.

### power_menu.xml

GTK3 menu UI definition. Menu item IDs must match the keys in `menu-actions` in config.

---

## How to Modify

### Add a New Module

1. **Add to `modules-center` array** in config:
   ```json
   "modules-center": [
       "hyprland/workspaces",
       "network",  // ← new module
       "clock",
   ]
   ```

2. **Configure the module** (add a new object in the same bar config):
   ```json
   "network": {
       "format-wifi": "{icon}",
       "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
       "on-click": "nm-connection-editor"
   }
   ```

3. **Style it** in `style.css`:
   ```css
   #network {
       /* inherits from the module list, add overrides here */
   }
   ```

### Change Colors

Edit these CSS variables (or create custom properties):
```css
/* Accent orange */
background-color: #FF8A60;  /* Normal */
background: #FF5C00;        /* Active/highlight */
background: #894126;        /* Hover */

/* Text */
color: #FFE9CB;             /* Light cream */
color: #F75C1E;             /* Warning/alert */

/* Backgrounds */
background-color: rgba(20, 9, 0, 0.6);  /* Bar background */
```

### Add Click Actions

Modules support various click handlers:
```json
"module-name": {
    "on-click": "command",
    "on-click-right": "command",
    "on-click-middle": "command",
    "on-scroll-up": "command",
    "on-scroll-down": "command"
}
```

### Custom Scripts

For dynamic content, use custom modules:
```json
"custom/my-script": {
    "exec": "~/.config/waybar/scripts/my-script.sh",
    "interval": 5,
    "format": "{}",
    "return-type": "json"  // if script outputs {"text": "...", "class": "..."}
}
```

---

## Dependencies

### Required
| Dependency | Purpose |
|------------|---------|
| `waybar` | The bar itself |
| `hyprland` | Workspace/window modules |

### Fonts
| Font | Usage |
|------|-------|
| `CommitMono Nerd Font Propo` | All text and icons |

Install via: `paru -S ttf-commit-mono-nerd` (or your font manager)

### Module Dependencies
| Module | Requires |
|--------|----------|
| `pulseaudio` | `pulseaudio` or `pipewire-pulse`, `pavucontrol` |
| `bluetooth` | `bluez`, `blueman` |
| `custom/power` | `systemd`, `hyprlock` |

### Script Dependencies
| Script | Requires |
|--------|----------|
| `waybar-fullscreen-watch.sh` | `socat`, `jq`, `hyprctl` |

---

## Gotchas

### JSON Syntax
The config uses JSON5, which allows trailing commas. If you edit with strict JSON tools, they may complain. Waybar handles it fine.

### Monitor Names
Hardcoded to `DP-1`, `DP-2`, `DP-3`. If your monitors have different names:
```bash
hyprctl monitors  # Check your monitor names
```
Then update `output` and `persistent-workspaces` in config.

### Secondary Bar Toggle
The `SIGUSR1`/`SIGUSR2` signals toggle ALL Waybar instances. The script tracks state manually. If you restart Waybar, the script's state may desync—restart the script too.

### Workspace Icons
Icons in `format-icons` must match workspace names exactly:
```json
"format-icons": {
    "spotify": "",   // Matches workspace named "spotify"
    "1": "󰎤"          // Matches workspace ID 1
}
```

### Special Workspace Regex
The `ignore-workspaces` regex filters what appears in the special workspace widget:
```json
"ignore-workspaces": ["^(chat|homeassistant|game|\\d)$"]
```
Double-escape `\\d` because it's JSON. This hides named workspaces and numbered workspaces.

### Power Menu Actions
Menu item IDs in `power_menu.xml` must match `menu-actions` keys in config exactly. Mismatches silently fail.

### CSS Class Names
Bar `name` in config becomes a CSS class (`.main`, `.secondary`). Use this for per-bar styling.

### Hot Reload
`reload_style_on_change: true` enables CSS hot reload. Config changes still require restarting Waybar:
```bash
killall waybar && waybar &
```

---

## Troubleshooting

**Bar not appearing:**
```bash
waybar -l debug  # Check for config/CSS errors
```

**Modules missing:**
- Ensure dependencies are installed
- Check `hyprctl monitors -j` for correct monitor names

**Icons showing as boxes:**
- Install the Nerd Font: `paru -S ttf-commit-mono-nerd`
- Verify font name in CSS matches installed font exactly

**Fullscreen script not working:**
- Verify `$XDG_RUNTIME_DIR` and `$HYPRLAND_INSTANCE_SIGNATURE` are set
- Test manually: `socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"`
