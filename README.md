# Devcontainer with Claude Code

Add a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) devcontainer to any project with a single command. Uses Docker named volumes so your credentials and shell history persist across container rebuilds — log in once, and it works everywhere.

## Install

Run this from your project directory (new or existing):

```bash
curl -fsSL https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.sh | bash
```

Then open in VS Code and select **"Reopen in Container"**. On first use, run `claude login` to authenticate.

## Update

Re-run the install script to pull the latest version:

```bash
bash .devcontainer/install.sh
```

It shows per-file status (`Installing`, `Updating`, or `Unchanged`) so you can see what changed.

## What Gets Persisted

| Volume Name | Container Path | Contents |
|---|---|---|
| `claude-code-home` | `~/.claude` | Credentials, settings, CLAUDE.md, session history, custom commands |
| `claude-code-shell-history` | `~/.shell_history` | Bash and zsh command history |

These are **shared named volumes** — the same volumes are mounted into every container on your machine. Log in to Claude Code once, and all your devcontainers pick it up automatically.

## Customization

### Adding Dev Container Features

Claude Code and GitHub CLI are pre-installed in the base image. Add additional features to `.devcontainer/devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/python:1": {}
}
```

### Using a Custom Dockerfile

Replace the `image` property with a `build` property:

```jsonc
{
  "build": {
    "dockerfile": "Dockerfile"
  },
  // ... keep everything else
}
```

### Project-Level Claude Settings

- **`CLAUDE.md`** in your project root — project instructions for Claude Code
- **`.claude/settings.json`** — committed team settings (commit this)
- **`.claude/settings.local.json`** — local overrides (gitignored)
- **`.claude.json`** — MCP server config (gitignored, may contain API keys)

## Troubleshooting

### Permission Errors on Container Start

The `onCreateCommand` fixes volume ownership automatically. If you still see issues:

```bash
sudo chown -R vscode:vscode ~/.claude ~/.shell_history
```

### Reset Claude Code Credentials

```bash
rm ~/.claude/.credentials.json
claude login
```

### Remove Persistent Volumes Entirely

To start fresh, remove the Docker volumes (affects all containers):

```bash
docker volume rm claude-code-home claude-code-shell-history
```

### Container Won't Build

Ensure Docker Desktop is running and you have the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed in VS Code.

## What's Included

- **Claude Code** — Anthropic's CLI tool, pre-installed in the base image
- **GitHub CLI** (`gh`) — for PR workflows and GitHub API access
- **Claude Code VS Code extension** — IDE integration
- **Persistent volumes** — credentials and shell history survive rebuilds
- **Shell history** — bash and zsh history shared across containers
