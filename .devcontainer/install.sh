#!/bin/bash
# Install or update devcontainer-template into the current project
# Usage:
#   First time:  curl -fsSL https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.sh | bash
#   Update:      bash .devcontainer/install.sh

set -e

REPO="aspinall/devcontainer-template"
BRANCH="main"
TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
TMPDIR=$(mktemp -d)

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# --- Download ---
echo "Downloading latest template from ${REPO}..."
if command -v curl &>/dev/null; then
    curl -fsSL "$TARBALL_URL" | tar xz -C "$TMPDIR"
elif command -v wget &>/dev/null; then
    wget -qO- "$TARBALL_URL" | tar xz -C "$TMPDIR"
else
    echo "Error: curl or wget is required." >&2
    exit 1
fi

SRCDIR="$TMPDIR/devcontainer-template-${BRANCH}"

if [ ! -d "$SRCDIR" ]; then
    echo "Error: unexpected archive structure." >&2
    exit 1
fi

# --- Install files ---
FILES=(
    ".devcontainer/devcontainer.json"
    ".devcontainer/setup.sh"
    ".devcontainer/install.sh"
)

mkdir -p .devcontainer

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        status="Installing"
    elif diff -q "$file" "$SRCDIR/$file" &>/dev/null; then
        status="Unchanged"
    else
        status="Updating"
    fi
    printf "  %-12s %s\n" "$status" "$file"
    if [ "$status" != "Unchanged" ]; then
        cp "$SRCDIR/$file" "$file"
    fi
done

# Ensure scripts are executable
chmod +x .devcontainer/setup.sh .devcontainer/install.sh

echo ""
echo "Done. Open this folder in VS Code and use 'Reopen in Container'."
