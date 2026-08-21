# solaar/

Configuration for Logitech MX Master 3 mouse via Solaar.

## Decisions

- **DPI set to 1000** — moderate sensitivity for ultrawide use
- **Smart-shift threshold at 25** — scroll wheel switches between ratchet/free-spin automatically
- **Thumb scroll inverted** — natural scrolling direction on the horizontal wheel
- **Hi-res smooth scrolling** — smooth resolution enabled, but hi-res mode itself disabled
- **Gesture button (195) diverted** — allows custom handling via rules

## Rules

- **Mouse Left gesture** → switch to previous workspace (`hyprctl dispatch workspace r-1`)
- **Mouse Right gesture** → switch to next workspace (`hyprctl dispatch workspace r+1`)

## Gotchas

- Gestures require the MX Master's thumb button to be diverted (set in config.yaml)
- Rules execute hyprctl commands directly — only works when Hyprland is running
