---
name: linear-workspace
description: |
  Setup a complete development workspace for Linear stories. Creates tmux session with notes,
  worktree, and Claude agent. Use when: starting work on a Linear ticket, setting up development
  environment for a story, creating parallel workspace for a feature. Keywords: linear, story,
  workspace, setup workspace, dev environment, linear ticket, story setup, new feature workspace,
  linear story, start story, setup dev, hatch story.
allowed-tools: Bash, Read
user-invocable: true
---

# Linear Workspace Setup

Automatically create a complete development workspace for working on Linear stories, including notes, git worktree, and Claude agent.

## Usage

```
/linear-workspace <story-number> <slug> <service-name>
```

**Arguments:**
- **story-number**: Linear story identifier (e.g., `AI-1234`, `COMMS-567`)
- **slug**: Short descriptive slug for the branch (e.g., `foo-bar`, `add-feature`)
- **service-name**: Service directory name in `~/code/` (e.g., `hatch-elixir`, `hatch-integrations`)

**Example:**
```
/linear-workspace AI-1234 implement-auth hatch-elixir
```

## What Gets Created

The skill sets up a tmux session named `{story-number}-{slug}` with three windows:

### Window 1: Notes
- Changes to `~/Documents/melissanotes`
- Opens nvim with `Hatch/Projects/{story-number}.md`
- Creates file with humanized slug as header if it doesn't exist
  - Example: `foo-bar` becomes `# Foo Bar`

### Window 2: {SERVICE_NAME}
- Changes to `~/code/{service-name}`
- Creates git worktree at `~/code/{story-number}/`
- Creates branch `{story-number}-{slug}`
- Copies configuration files (`.env.assistant*`, `.iex.local.exs`)
- Changes to the new worktree directory

### Window 3: Agent 󰧑
- Changes to the worktree directory
- Launches Claude Code CLI
- User should manually run `/brainstorm {story-number}` after session starts

## Prerequisites

The following paths must exist, or the script will abort:

1. **Notes directory**: `~/Documents/melissanotes`
2. **Notes project directory**: `~/Documents/melissanotes/Hatch/Projects/`
3. **Service directory**: `~/code/{service-name}`
4. **Service must be a git repository**

## Validations

The script performs these checks before proceeding:

- ✓ tmux is installed
- ✓ All required directories exist
- ✓ Service directory is a git repository
- ✓ Tmux session name is not already in use
- ✓ Worktree directory doesn't already exist (or is a valid existing worktree)

If any validation fails, the script aborts with a clear error message.

## Implementation

The skill runs a bash script that orchestrates the setup:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/linear-workspace/scripts/setup-story-workspace.sh \
    "$STORY_NUMBER" \
    "$SLUG" \
    "$SERVICE_NAME"
```

### Error Handling

| Error | Reason |
|-------|--------|
| Notes directory does not exist | `~/Documents/melissanotes` not found |
| Notes project directory does not exist | `~/Documents/melissanotes/Hatch/Projects/` not found |
| Service directory does not exist | `~/code/{service-name}` not found |
| Service directory is not a git repository | Directory exists but is not a git repo |
| Tmux session already exists | Session name collision - attach to existing or use different slug |
| Worktree directory already exists | `~/code/{story-number}` already exists |
| Failed to create worktree | Git worktree creation failed |

## Branch Naming

The branch is created as: `{story-number}-{slug}`

Examples:
- `AI-1234-implement-auth`
- `COMMS-567-fix-webhook`
- `HATCH-890-refactor-types`

## Configuration Files

The script automatically copies these files from the main service directory to the worktree (if they exist):

- `.env.assistant*` (all files matching this pattern)
- `.iex.local.exs` (Elixir IEx configuration)

If files don't exist, a warning is shown but setup continues.

## Session Management

After setup completes, the script:

- Attaches to the new tmux session if not already in tmux
- Switches to the new session if already in tmux
- Selects the Notes window by default

### Switching Between Windows

Use standard tmux keybindings:
- `Prefix + 0` - Notes window
- `Prefix + 1` - Service window
- `Prefix + 2` - Agent window

(Where Prefix is typically `Ctrl-b`)

### Detaching from Session

- `Prefix + d` - Detach from session (session continues running)

### Reattaching to Session

```bash
tmux attach -t {story-number}-{slug}
```

Example:
```bash
tmux attach -t AI-1234-implement-auth
```

## Workflow Example

**User runs:**
```
/linear-workspace AI-1234 add-payments hatch-elixir
```

**Script creates:**
1. Tmux session: `AI-1234-add-payments`
2. Notes file: `~/Documents/melissanotes/Hatch/Projects/AI-1234.md` with header `# Add Payments`
3. Git worktree: `~/code/AI-1234/` with branch `AI-1234-add-payments`
4. Three windows: Notes (nvim), hatch-elixir (worktree), Agent (Claude CLI)

**User workflow:**
1. Window 1: Take notes in nvim
2. Window 2: Write code in worktree
3. Window 3: Run `/brainstorm AI-1234` in Claude, then iterate with Claude on implementation

## Cleanup

When done with the story:

1. Merge/close the PR
2. Kill the tmux session: `tmux kill-session -t {story-number}-{slug}`
3. Remove the worktree: `git worktree remove ~/code/{story-number}`
4. Delete the branch: `git branch -d {story-number}-{slug}`

## Tips

1. **Use descriptive slugs** - They become branch names and help identify work
2. **Run /brainstorm manually** - This gives you control over when the brainstorming starts
3. **Keep notes in sync** - The notes file is perfect for documenting decisions and progress
4. **Worktrees are isolated** - You can work on multiple stories simultaneously
5. **Session persists** - Detach and reattach without losing your setup

## Related Skills

- `/git-worktree` - For manual worktree management
- `/tmux-multiplexer` - For advanced tmux orchestration
- `/brainstorm` - For feature brainstorming (run manually in Agent window)
- `/checkpoint` - To save progress at milestones
