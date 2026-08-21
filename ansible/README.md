# Ansible Setup

Automates CachyOS Hyprland system configuration — from package installation to desktop environment setup using GNU Stow for dotfiles.

## Playbooks

### `playbook.yaml` — Main System Setup

Full system provisioning:

1. Enables passwordless sudo for the current user
2. Updates pacman and paru, upgrades system packages
3. Installs packages from official repos and AUR
4. Configures boot (silent boot, Plymouth)
5. Sets up Hyprland and desktop components (notifications, bars, launcher)
6. Installs and configures shell (zsh), terminal, neovim, git
7. Sets up applications (gaming, docker, spotify, PWAs, solaar)

**Run:**
```bash
ansible-playbook playbook.yaml --ask-become-pass
```

## Variables in playbook.yaml

| Variable | Purpose |
|----------|---------|
| `essential_packages` | Core packages from official repos (rofi, bitwarden, stow, etc.) |
| `user_packages` | Personal apps from official repos (discord, telegram, etc.) |
| `aur_packages` | AUR packages installed via paru (vscode, vial, etc.) |

## Task Organization

All tasks live in `tasks/`. Reusable helpers:

| Task | Purpose |
|------|---------|
| `install_official.yaml` | Install a single official repo package via pacman |
| `install_aur.yaml` | Install a single AUR package via paru |
| `stow_dotfiles.yaml` | Symlink a dotfiles package using GNU Stow |

Component setup tasks:

| Task | What it configures |
|------|-------------------|
| `silent_boot.yaml` | Quiet boot entries in systemd-boot |
| `plymouth.yaml` | Plymouth boot splash |
| `hyprland.yaml` | Hyprland window manager |
| `notification_daemon.yaml` | Notification daemon (mako) |
| `overlay_bar.yaml` | Overlay bar (wob/avizo) |
| `status_bar.yaml` | Status bar (waybar) |
| `launcher.yaml` | App launcher (rofi) |
| `zsh.yaml` | Zsh shell setup |
| `git.yaml` | Git configuration |
| `neovim.yaml` | Neovim editor |
| `terminal.yaml` | Terminal emulator (kitty) |
| `gaming.yaml` | Gaming apps (Steam, Lutris, etc.) |
| `docker.yaml` | Docker setup |
| `spotify.yaml` | Spotify client |
| `progressive_web_apps.yaml` | FirefoxPWA and web apps |
| `solaar.yaml` | Logitech device manager |
| `printer.yaml` | Printer/CUPS setup |

## Adding a New Task

1. **Create the task file:**

   ```bash
   touch tasks/my_feature.yaml
   ```

2. **Write the task:**

   ```yaml
   # tasks/my_feature.yaml
   - name: Install my-package
     community.general.pacman:
       name: my-package
       state: latest
     become: true

   - name: Enable my-service
     systemd:
       name: my-service
       enabled: true
       state: started
     become: true
   ```

3. **Include in playbook.yaml:**

   ```yaml
   - name: Setup my feature
     include_tasks: tasks/my_feature.yaml
   ```

**Tips:**
- Use `become: true` for root operations
- Use `{{ target_user }}` variable for user-specific paths
- For package lists, loop with `include_tasks`:
  ```yaml
  - name: Install my packages
    include_tasks: tasks/install_official.yaml
    loop: "{{ my_packages }}"
    loop_control:
      loop_var: package
  ```
