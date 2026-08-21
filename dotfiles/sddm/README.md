# sddm/

SDDM login manager configured to run as Wayland compositor using Hyprland.

## Decisions

- **Wayland-only** — X11 disabled entirely; SDDM runs Hyprland as the greeter compositor
- **sddm-astronaut-theme** — chosen as the visual theme
- **Numlock on by default** — consistent with user session keyboard settings
- **Session persistence** — remembers last user and session to speed up login
- **HiDPI enabled** — supports high-resolution displays
- **Custom Hyprland config** — minimal compositor config in `compositor/hyprland.conf` disables splash/logo, sets monitor layout, and applies SDDM-specific window rules

## Gotchas

- The compositor config path in `wayland.conf` points to `/etc/sddm.conf.d/compositor/` — make sure files are deployed there, not just kept in dotfiles
- `windowrulev2` for sddm-greeter requires xdg-shell; see Arch wiki for details
