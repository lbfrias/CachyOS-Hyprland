# spotify/

Configuration for spotify-launcher to run Spotify natively on Wayland.

## Decisions

- **Ozone platform forced to Wayland** — prevents Spotify from falling back to XWayland
- **UseOzonePlatform feature enabled** — required for Chromium-based apps on Wayland

## Gotchas

- This config is for `spotify-launcher` (AUR), not the Flatpak or Snap versions
- If Spotify crashes on launch, Wayland session detection may have failed — check `$XDG_SESSION_TYPE`
