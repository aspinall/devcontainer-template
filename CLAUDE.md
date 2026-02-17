# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A curl-installable devcontainer configuration that adds Claude Code to any project. The key feature is shared Docker named volumes (`claude-code-home`, `claude-code-shell-history`) that persist credentials and shell history across all container rebuilds and across different projects on the same machine.

This is NOT a template repo — it's a source repo for an install script. Users consume it via:
```bash
curl -fsSL https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.sh | bash
```

## Architecture

- **`.devcontainer/devcontainer.json`** — Core config. Uses `mcr.microsoft.com/devcontainers/base:ubuntu` with the Claude Code and GitHub CLI dev container features. Mounts two fixed-name Docker volumes and runs permission fix + setup script.
- **`.devcontainer/setup.sh`** — Post-create script. Configures bash/zsh to use the persistent history volume (idempotent via `# claude-devcontainer-history` marker). Prints auth status on container start.
- **`.devcontainer/install.sh`** — Downloads a GitHub tarball of this repo and copies the three `.devcontainer/` files into the target project. Shows diff-based status per file. Self-updating.

## Key Design Decisions

- **Fixed volume names** (not `${devcontainerId}`) — intentionally shared across ALL containers so one `claude login` works everywhere.
- **No Dockerfile** — base image + features is simpler and easier for consumers to extend.
- **Tarball download, not git remote** — `install.sh` uses GitHub archive URL to avoid polluting consumer repos with extra remotes.
- **`onCreateCommand` for permissions** — volume ownership must be fixed before `postCreateCommand` runs `setup.sh`.

## Shell Scripts

All `.sh` files must use LF line endings (enforced by `.gitattributes`) and must have executable permission in git (`100755`). When adding or modifying shell scripts, verify with `git ls-files -s <file>`.
