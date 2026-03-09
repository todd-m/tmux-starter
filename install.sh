#!/usr/bin/env bash
# =============================================================================
# tmux-starter installer
# =============================================================================
# Installs a portable tmux configuration and zsh helpers.
# Safe to re-run — backs up existing files and is idempotent.
#
# Usage:  bash install.sh
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONF="$HOME/.tmux.conf"
ZSHRC="$HOME/.zshrc"
BACKUP_DIR="$HOME/.tmux-starter-backups/$(date +%Y%m%d-%H%M%S)"
MARKER_BEGIN="# ---- TMUX-STARTER BEGIN ----"
MARKER_END="# ---- TMUX-STARTER END ----"

# Track what we did for the summary
actions=()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$1"; }

backup_file() {
    local src="$1"
    if [ -f "$src" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$src" "$BACKUP_DIR/"
        ok "Backed up $src → $BACKUP_DIR/$(basename "$src")"
        actions+=("Backed up $src")
    fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
info "Running pre-flight checks..."

if ! command -v tmux &>/dev/null; then
    warn "tmux is not installed. This script only configures tmux — install it first."
    warn "  macOS:  brew install tmux"
    warn "  Debian: sudo apt install tmux"
    warn "  Fedora: sudo dnf install tmux"
    echo ""
    warn "Continuing with configuration anyway..."
fi

# ---------------------------------------------------------------------------
# Step 1: Install ~/.tmux.conf
# ---------------------------------------------------------------------------
info "Installing tmux configuration..."

backup_file "$TMUX_CONF"

cp "$SCRIPT_DIR/tmux.conf" "$TMUX_CONF"
ok "Wrote $TMUX_CONF"
actions+=("Installed $TMUX_CONF")

# ---------------------------------------------------------------------------
# Step 2: Install TPM (Tmux Plugin Manager)
# ---------------------------------------------------------------------------
info "Installing Tmux Plugin Manager..."

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    ok "TPM already installed at $TPM_DIR"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "Cloned TPM to $TPM_DIR"
    actions+=("Installed TPM")
fi

# Install plugins (non-interactive)
if command -v tmux &>/dev/null && [ -x "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins" || warn "Plugin install requires a running tmux server — press prefix + I after starting tmux"
    ok "Installed tmux plugins"
    actions+=("Installed tmux plugins (resurrect, continuum)")
else
    warn "Start tmux and press prefix + I to install plugins"
fi

# ---------------------------------------------------------------------------
# Step 3: Append zsh helpers to ~/.zshrc (idempotent)
# ---------------------------------------------------------------------------
info "Installing zsh helpers..."

# Create .zshrc if it doesn't exist
touch "$ZSHRC"

if grep -qF "$MARKER_BEGIN" "$ZSHRC"; then
    # Block exists — replace it in place for idempotent updates
    warn "Existing tmux-starter block found in $ZSHRC — replacing it."
    backup_file "$ZSHRC"

    # Remove the old block, then re-append the new one
    # (sed between markers is fragile with multiline; this is simpler)
    {
        # Print everything before the BEGIN marker
        sed -n "/$MARKER_BEGIN/q;p" "$ZSHRC"
        # Print everything after the END marker
        sed -n "/$MARKER_END/,\$p" "$ZSHRC" | tail -n +2
        # Append the new block
        echo ""
        cat "$SCRIPT_DIR/zshrc-block.zsh"
    } > "$ZSHRC.tmp"
    mv "$ZSHRC.tmp" "$ZSHRC"
    ok "Updated tmux-starter block in $ZSHRC"
    actions+=("Updated zsh block in $ZSHRC")
else
    backup_file "$ZSHRC"

    # Append with a blank line separator
    {
        echo ""
        cat "$SCRIPT_DIR/zshrc-block.zsh"
    } >> "$ZSHRC"
    ok "Appended tmux-starter block to $ZSHRC"
    actions+=("Appended zsh block to $ZSHRC")
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
info "Installation complete!"
echo ""
printf '  Actions taken:\n'
for action in "${actions[@]}"; do
    printf '    • %s\n' "$action"
done
echo ""
printf '  To activate now:\n'
printf '    source ~/.zshrc\n'
printf '    # or open a new terminal — it will auto-attach to tmux "main"\n'
echo ""
printf '  Key bindings cheat sheet:\n'
printf '    Prefix:           Ctrl+a\n'
printf '    Split vertical:   Ctrl+a |\n'
printf '    Split horizontal: Ctrl+a -\n'
printf '    Switch panes:     Alt+Arrow (no prefix)\n'
printf '    Switch windows:   Shift+Left/Right (no prefix)\n'
printf '    Reload config:    Ctrl+a r\n'
printf '    Copy mode:        Ctrl+a [\n'
printf '    Save session:     Ctrl+a Ctrl+s  (resurrect)\n'
printf '    Restore session:  Ctrl+a Ctrl+r  (resurrect)\n'
printf '    Install plugins:  Ctrl+a I        (TPM)\n'
echo ""
printf '  Backups saved to: %s\n' "$BACKUP_DIR"
echo ""
