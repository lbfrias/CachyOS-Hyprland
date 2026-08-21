# CONTEXT.md

> Personal CachyOS + Hyprland workstation bootstrap

## Architecture

Three layers:

### 1. `setup.sh` — Entry Point
- Installs ansible-core, ansible, stow via pacman
- Runs the main playbook with `ansible-playbook -v -K ansible/playbook.yaml`

### 2. `ansible/` — System Orchestration
- `playbook.yaml` — main playbook, defines package lists and task includes
- `tasks/*.yaml` — modular tasks (hyprland, zsh, neovim, docker, gaming, etc.)
- Handles: package installation, service setup, stow-managed symlinks

### 3. `dotfiles/` — Stow-Managed Configs
- Each subdirectory is a stow package
- Symlinked to `$HOME` via ansible tasks
- Contains: hyprland, waybar, rofi, mako, wob, spotify, solaar, etc.

## Boundaries

### Submodules — DO NOT EDIT HERE
These are separate repos with their own version history:
- `dotfiles/zsh` → github.com/lbfrias/zsh
- `dotfiles/neovim` → github.com/lbfrias/neovim
- `dotfiles/kitty` → github.com/lbfrias/kitty
- `dotfiles/gitconfig` → github.com/lbfrias/gitconfig

To modify these configs, clone and edit the submodule repo directly.

### Single-Machine Repo
- This is NOT a portable template
- Hardcoded paths and usernames are expected
- `zsh-local/` contains machine-specific zsh config (not a submodule)

## How to Add Things

### New Package
Add to the appropriate list in `ansible/playbook.yaml`:
- `essential_packages` — core system tools (pacman)
- `user_packages` — personal apps (pacman)
- `aur_packages` — AUR packages (paru)

### New Dotfile Set
1. Create `dotfiles/<name>/` with stow-compatible structure
2. Add stow task in ansible (see `tasks/stow_dotfiles.yaml` pattern)
3. Include the task in `playbook.yaml`

### New Ansible Task
1. Create `ansible/tasks/<name>.yaml`
2. Add include in `ansible/playbook.yaml`:
   ```yaml
   - name: Setup <name>
     include_tasks: tasks/<name>.yaml
   ```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| **Ansible over shell scripts** | Idempotency, readability, modular task organization |
| **Stow for dotfiles** | Symlinks keep configs versioned in one place |
| **Submodules for zsh/neovim/kitty/gitconfig** | Reusable across machines/projects, independent version history |
| **CachyOS** | Performance-tuned Arch derivative with better defaults |

## Package Lists Quick Reference

```yaml
essential_packages:  # Core system (rofi, bitwarden, virt-manager, cups, etc.)
user_packages:       # Personal apps (discord, telegram, solaar, udiskie)
aur_packages:        # AUR (vscode, vial, go-hass-agent, etc.)
```

## Task Modules

| Task | Purpose |
|------|---------|
| `hyprland.yaml` | Window manager config |
| `status_bar.yaml` | Waybar setup |
| `notification_daemon.yaml` | Mako notifications |
| `overlay_bar.yaml` | Wob volume/brightness overlay |
| `launcher.yaml` | Rofi application launcher |
| `terminal.yaml` | Kitty terminal |
| `zsh.yaml` | Shell setup |
| `neovim.yaml` | Editor setup |
| `git.yaml` | Git configuration |
| `docker.yaml` | Container runtime |
| `gaming.yaml` | Steam/gaming setup |
| `spotify.yaml` | Music player |
| `plymouth.yaml` | Boot splash |
| `silent_boot.yaml` | Quiet boot entries |
