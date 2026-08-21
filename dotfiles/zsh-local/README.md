# zsh-local

Machine-specific zsh configuration (not portable).

## Decisions

- **Auto-start Hyprland** from TTY1 — `.zprofile` launches compositor on login
- **Bitwarden SSH agent** — uses Bitwarden's socket for SSH keys
- **Theme toggle aliases** (`dark`/`light`) — switches GTK theme + mako notifications together
- **waybar-reload alias** — quick restart for waybar config changes

## Gotchas

- **Not portable** — contains machine-specific paths and hardware assumptions
- `.zprofile` expects `start-hyprland` script in PATH
- Theme aliases assume GNOME settings schema and mako are available
