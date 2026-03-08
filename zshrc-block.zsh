# ---- TMUX-STARTER BEGIN ----
# Tmux helper functions and aliases for zsh.
# Added by tmux-starter. Remove this block to uninstall.

# --- Aliases ---
alias tls='tmux list-sessions'              # List all tmux sessions
alias tk='tmux kill-session -t'             # Kill a session by name: tk mysession
alias tn='tmux new-session -s'              # New named session: tn work

# --- ta: attach or create a named session ---
# Usage: ta myproject
#   Attaches to "myproject" if it exists, otherwise creates it.
ta() {
    local name="${1:-main}"
    if tmux has-session -t "$name" 2>/dev/null; then
        tmux attach-session -t "$name"
    else
        tmux new-session -s "$name"
    fi
}

# --- tmux-here: new session named after current directory ---
# Usage: cd ~/Projects/myapp && tmux-here
tmux-here() {
    local session_name
    session_name="$(basename "$PWD" | tr '.:' '-')"
    ta "$session_name"
}

# --- Auto-attach to "main" session on new terminal ---
# Guards: only if tmux is installed, we're not already inside tmux,
# the shell is interactive, and stdin is a terminal.
if command -v tmux &>/dev/null \
    && [ -z "$TMUX" ] \
    && [[ $- == *i* ]] \
    && [ -t 0 ]; then
    ta main
fi
# ---- TMUX-STARTER END ----
