# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A curl-installable devcontainer configuration that adds Claude Code to any project. The key feature is shared Docker named volumes (`claude-code-home`, `claude-code-shell-history`) that persist credentials and shell history across all container rebuilds and across different projects on the same machine.

This is NOT a template repo — it's a source repo for an install script. Users consume it via:
```bash
curl -fsSL https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.sh | bash
```
Or on Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.ps1 | iex
```

## Architecture

The devcontainer uses a Docker Compose structure that separates template-owned infrastructure from user-owned customizations:

**Template-owned files** (always overwritten by `install.sh`):
- **`.devcontainer/docker-compose.yml`** — Infrastructure config. Defines the service using the pre-built base image from `ghcr.io/aspinall/devcontainer-base-image` (built in a [separate repo](https://github.com/aspinall/devcontainer-base-image)), workspace mount, and named Docker volumes for credential/history persistence.
- **`.devcontainer/setup.sh`** — Post-create script. Fixes volume permissions, configures bash/zsh to use the persistent history volume (idempotent via `# claude-devcontainer-history` marker), and prints auth status on container start.
- **`.devcontainer/install.sh`** — Downloads a GitHub tarball of this repo and copies `.devcontainer/` files into the target project. Uses two-tier logic: template-owned files are always updated, user-owned files are only created on first install. Self-updating.
- **`.devcontainer/install.ps1`** — PowerShell equivalent of `install.sh` for Windows users. Uses GitHub zip archive instead of tarball, `Get-FileHash` for file comparison, and `try/finally` for cleanup. Self-updating.

**User-owned files** (only created if missing, never overwritten):
- **`.devcontainer/devcontainer.json`** — User customizations. References `docker-compose.yml` and the `claude-code` service. Users can safely add extensions, settings, port forwarding, etc. without risk of install.sh overwriting their changes.

## Key Design Decisions

- **Fixed volume names** (not `${devcontainerId}`) — intentionally shared across ALL containers so one `claude login` works everywhere.
- **Pre-built base image** — Claude Code and GitHub CLI are baked into a GHCR image (`aspinall/devcontainer-base-image`) rebuilt weekly by CI. This avoids slow feature installs on every container rebuild. The image is maintained in a separate repo.
- **Docker Compose split** — infrastructure (image, volumes) lives in template-owned `docker-compose.yml`, while user customizations (extensions, settings) live in user-owned `devcontainer.json`. This lets `install.sh` update infrastructure without destroying user config.
- **Two-tier file ownership** — `install.sh` always overwrites template files (`docker-compose.yml`, `setup.sh`, `install.sh`) but only creates `devcontainer.json` on first install, preserving user customizations on updates.
- **Tarball download, not git remote** — `install.sh` uses GitHub archive URL to avoid polluting consumer repos with extra remotes.
- **Multi-container extensibility** — users can add companion services (databases, caches) via `docker-compose.override.yml` and update `dockerComposeFile` in their `devcontainer.json` to include it.

## Shell Scripts

All `.sh` files must use LF line endings (enforced by `.gitattributes`) and must have executable permission in git (`100755`). When adding or modifying shell scripts, verify with `git ls-files -s <file>`.

PowerShell scripts (`.ps1`) are tracked as text in `.gitattributes` but do not require executable permission or forced line endings — `text=auto` handles platform-native endings on checkout.
