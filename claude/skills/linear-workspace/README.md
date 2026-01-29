# Linear Workspace Setup Skill

Automated development workspace setup for Linear stories using tmux, git worktrees, and Claude Code.

## Quick Start

```bash
/linear-workspace AI-1234 implement-auth hatch-elixir
```

This creates a tmux session with:
- **Window 1 (Notes)**: Neovim with notes file
- **Window 2 (Service)**: Git worktree with new branch
- **Window 3 (Agent)**: Claude Code CLI ready for `/brainstorm`

## Requirements

- tmux installed
- Notes directory: `~/Documents/melissanotes/Hatch/Projects/`
- Service in: `~/code/{service-name}`
- Service must be a git repository

## Files

- `SKILL.md` - Skill definition and documentation
- `scripts/setup-story-workspace.sh` - Main setup script

## Architecture

The skill orchestrates:
1. Path validation (all paths must exist)
2. Tmux session creation (aborts if session exists)
3. Git worktree creation (using git commands directly)
4. Configuration file copying (`.env.assistant*`, `.iex.local.exs`)
5. Window setup with proper navigation

## Error Handling

The script validates all paths before making changes. If any validation fails, it aborts immediately with a clear error message. This ensures we don't create partial state.

## Why Not Auto-Run /brainstorm?

We intentionally don't send the `/brainstorm` command automatically to the Claude pane because:
- Timing is unpredictable (Claude CLI takes variable time to start)
- User may want to do other setup first
- Gives user explicit control over when brainstorming begins
- Avoids fragile `sleep` delays

## Related Skills

- `git-worktree` - Manual worktree management
- `tmux-multiplexer` - Tmux orchestration patterns
- `brainstorm` - Feature brainstorming (run manually in agent window)
