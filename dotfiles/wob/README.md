# wob

Wayland Overlay Bar configuration for volume/brightness indicators.

## Decisions

- **Vertical orientation** anchored right — stays out of the way while remaining visible
- **Warm color scheme** (orange bar, dark background) — matches Hyprland theme
- **1000ms timeout** — long enough to see, short enough to not linger
- **Output-specific override for DP-1** — larger bar for main monitor

## Gotchas

- `DP-1` output match is hardware-specific; update if monitor name changes
