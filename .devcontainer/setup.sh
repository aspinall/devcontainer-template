#!/bin/bash
# Post-create setup for Claude Code devcontainer
# Configures persistent shell history and checks auth status

set -e

# Fix volume permissions (moved from onCreateCommand)
sudo chown -R vscode:vscode /home/vscode/.claude /home/vscode/.shell_history

HISTORY_DIR="/home/vscode/.shell_history"
MARKER="# claude-devcontainer-history"

# --- Bash history ---
BASHRC="/home/vscode/.bashrc"
if ! grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'EOF'

# claude-devcontainer-history
HISTFILE=/home/vscode/.shell_history/.bash_history
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
EOF
    echo "Configured bash history persistence."
fi

# --- Zsh history ---
ZSHRC="/home/vscode/.zshrc"
if [ -f "$ZSHRC" ] && ! grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" << 'EOF'

# claude-devcontainer-history
HISTFILE=/home/vscode/.shell_history/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt APPEND_HISTORY
EOF
    echo "Configured zsh history persistence."
fi

# --- Claude Code auth check ---
echo ""
if [ -f "/home/vscode/.claude/.credentials.json" ]; then
    echo "Claude Code: credentials found (persistent volume)."
else
    echo "Claude Code: no credentials found."
    echo "  Run 'claude login' to authenticate."
    echo "  Your login will persist across container rebuilds."
fi
