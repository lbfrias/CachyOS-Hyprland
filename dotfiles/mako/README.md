# mako

Wayland notification daemon configuration.

## Decisions

- **Top-center anchor** — Notifications appear at top center of screen
- **10 max visible** — Prevents notification spam from cluttering screen
- **5s default timeout** — Short enough to not linger, long enough to read
- **Output pinned to DP-1** — Notifications always appear on primary monitor
- **Warm color scheme** — Matches system theme (#332B29 bg, #F75C1E accent)
- **Light mode support** — Alternate colors for light mode (`mode=light`)
- **DND mode** — `invisible=1` hides all notifications when in do-not-disturb

## Gotchas

- `output=DP-1` is hardcoded — update if monitor name changes
