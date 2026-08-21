# hyprland-preview-share-picker

Screen/window share picker for Hyprland with custom GTK styling.

## Decisions

- **Custom theme** — Matches the warm dark color scheme (#262626 bg, #F75C1E accent)
- **CommitMono font** — Consistent monospace font across the system
- **Transition effects** — 0.2s ease transitions on hover/focus for polished feel
- **Tab styling** — Selected tabs have orange underline, inactive tabs are muted
- **Card selection** — Border highlights on selected items instead of background change

## Gotchas

- File is named `style.css` but contains a comment referencing `theme.css` — works correctly
- Stylesheet must be listed in `config.yaml` to load
