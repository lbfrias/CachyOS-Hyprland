#!/usr/bin/env bash

# Start GNOME keyring for secrets and GPG (without touching SSH)
eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,gpg)

# Launch Hyprland
exec Hyprland > /dev/null 2>&1
