# rofi

Application launcher and switcher configuration.

## Decisions

- **Multiple modes** — drun, calc, emoji, window, run with custom labels/icons
- **Papirus-Dark icons** — Consistent icon theme across desktop
- **CommitMono font** — Monospace font matching system theme
- **Match fields** — Searches name, exec, and keywords for better discoverability
- **8 visible lines** — Compact list without scrollbar
- **Semi-transparent** — rgba backgrounds (0.75-0.90 alpha) for depth
- **Warm color scheme** — #262626 bg, #F75C1E accent, #FFE9CB text

## Gotchas

- Theme file uses relative path `~/.config/rofi/theme.rasi` — must be in correct location
- Commented config block at top is from previous iteration, kept for reference
