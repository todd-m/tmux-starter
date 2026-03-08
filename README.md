# tmux-starter

A portable, zero-dependency tmux configuration with zsh integration. Works out of the box on macOS and Linux.

## Prerequisites

- **tmux** >= 2.6 (for `copy-mode-vi` bindings and terminal overrides)
- **zsh** (for the shell helpers; the tmux config itself works with any shell)

## Installation

```bash
git clone <this-repo> ~/tmux-starter   # or download the files
cd ~/tmux-starter
bash install.sh
```

The installer will:
1. Back up your existing `~/.tmux.conf` and `~/.zshrc`
2. Write the new tmux config
3. Append zsh helpers (idempotent — safe to re-run)

It does **not** install tmux itself.

## What's Included

### ~/.tmux.conf

| Section | What it does |
|---|---|
| **Prefix key** | Remaps prefix to `Ctrl+a` (screen-style, easier to reach) |
| **General settings** | Mouse on, 50k scrollback, windows renumber on close |
| **Numbering** | Windows and panes start at 1 (matches keyboard layout) |
| **Escape time** | Set to 10ms — eliminates Esc lag in vim/neovim |
| **True color** | 24-bit RGB support for modern terminals |
| **Copy mode** | Vi-style: `v` to select, `y` to yank, `Ctrl+v` for block select |
| **Pane splitting** | `|` for vertical, `-` for horizontal (intuitive) |
| **Pane navigation** | `Alt+Arrow` (no prefix) or `prefix + h/j/k/l` |
| **Pane resizing** | `prefix + Shift+Arrow` in 5-cell increments |
| **Window navigation** | `Shift+Left/Right` (no prefix) |
| **Config reload** | `prefix + r` reloads config with confirmation |
| **Status bar** | Session name, window list, hostname, time |

### ~/.zshrc additions

| Command | Description |
|---|---|
| `ta <name>` | Attach to session `<name>`, or create it if it doesn't exist |
| `tmux-here` | New session named after the current directory |
| `tls` | List all tmux sessions |
| `tk <name>` | Kill a session by name |
| `tn <name>` | Create a new named session |
| *(auto-attach)* | New terminals auto-attach to a "main" session |

## Key Bindings Reference

All bindings use **Ctrl+a** as the prefix unless noted otherwise.

### Prefix-based bindings

| Keys | Action |
|---|---|
| `Ctrl+a` then `\|` | Split pane vertically (side by side) |
| `Ctrl+a` then `-` | Split pane horizontally (stacked) |
| `Ctrl+a` then `h/j/k/l` | Navigate panes (vi-style) |
| `Ctrl+a` then `Shift+Arrow` | Resize pane by 5 cells |
| `Ctrl+a` then `c` | New window (in current directory) |
| `Ctrl+a` then `[` | Enter copy mode |
| `Ctrl+a` then `r` | Reload tmux config |
| `Ctrl+a` then `d` | Detach from session |
| `Ctrl+a` then `Ctrl+a` | Send literal Ctrl+a to the terminal |

### No-prefix bindings

| Keys | Action |
|---|---|
| `Alt+Arrow` | Switch panes |
| `Shift+Left/Right` | Switch windows |

### Copy mode (vi-style)

| Keys | Action |
|---|---|
| `v` | Begin selection |
| `y` | Copy selection and exit copy mode |
| `Ctrl+v` | Toggle rectangle (block) selection |
| `Escape` | Cancel and exit copy mode |

## Customization

### Changing the prefix key

Edit the prefix section in `~/.tmux.conf`:

```tmux
unbind C-b
set -g prefix C-Space        # Example: use Ctrl+Space instead
bind C-Space send-prefix
```

### Adding new key bindings

```tmux
# Example: prefix + T to open a popup terminal
bind T display-popup -E -w 80% -h 80%
```

### Changing status bar colors

The status bar uses `colour` codes (0–255). Modify the `STATUS BAR` section:

```tmux
set -g status-style "bg=colour24,fg=colour255"   # Blue background
```

### Disabling auto-attach

Remove or comment out the auto-attach block at the bottom of the tmux-starter section in `~/.zshrc` (the `if command -v tmux ...` block).

## Uninstalling

1. **Restore tmux config:**
   ```bash
   # Find your backup
   ls ~/.tmux-starter-backups/
   # Restore it
   cp ~/.tmux-starter-backups/<timestamp>/tmux.conf ~/.tmux.conf
   # Or just delete it to use tmux defaults
   rm ~/.tmux.conf
   ```

2. **Remove zsh helpers:**
   ```bash
   # Restore from backup
   cp ~/.tmux-starter-backups/<timestamp>/.zshrc ~/.zshrc
   # Or manually remove everything between these markers in ~/.zshrc:
   #   # ---- TMUX-STARTER BEGIN ----
   #   # ---- TMUX-STARTER END ----
   ```

3. **Clean up backups:**
   ```bash
   rm -rf ~/.tmux-starter-backups/
   ```

## Compatibility

- **macOS**: Tested with iTerm2, Terminal.app, Alacritty, Kitty
- **Linux**: Tested with GNOME Terminal, Alacritty, Kitty, xterm
- **tmux**: Requires 2.6+ (for `copy-mode-vi` key table). Tested through 3.4.
- **No external dependencies**: No tpm, no plugins, no package managers needed
