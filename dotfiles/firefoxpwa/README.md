# firefoxpwa

Firefox PWA profile configuration for app-like web experiences.

## Decisions

- **Hide toolbar** — `userChrome.css` hides `#navigator-toolbox` for a clean PWA appearance
- **Enable userChrome** — `toolkit.legacyUserProfileCustomizations.stylesheets` required for CSS customization
- **Out-of-scope behavior** — Opens external links in default browser, not the PWA window
- **Allowed domains** — Whitelisted `messenger.com` and `www.facebook.com` for cross-domain navigation

## Gotchas

- Profile folder uses placeholder ID `00000000000000000000000000` — replace with actual profile ID from `~/.local/share/nicotine/profiles/`
- Must enable `toolkit.legacyUserProfileCustomizations.stylesheets` for userChrome.css to work
