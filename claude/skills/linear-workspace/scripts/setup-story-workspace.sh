#!/bin/bash
# Setup Linear Story Workspace
# Creates a tmux session with notes, worktree, and Claude panes
#
# Usage: setup-story-workspace.sh <story-number> <slug> <service-name>
# Example: setup-story-workspace.sh AI-1234 foo-bar hatch-elixir

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

error() { echo -e "${RED}Error: $1${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}Warning: $1${NC}" >&2; }
success() { echo -e "${GREEN}$1${NC}"; }
info() { echo -e "${BLUE}$1${NC}"; }

# Parse arguments
STORY_NUMBER="${1:-}"
SLUG="${2:-}"
SERVICE_NAME="${3:-}"

# Validate arguments
[[ -z "$STORY_NUMBER" ]] && error "Story number required. Usage: $0 <story-number> <slug> <service-name>"
[[ -z "$SLUG" ]] && error "Slug required. Usage: $0 <story-number> <slug> <service-name>"
[[ -z "$SERVICE_NAME" ]] && error "Service name required. Usage: $0 <story-number> <slug> <service-name>"

# Check tmux availability
command -v tmux >/dev/null 2>&1 || error "tmux is not installed"

# Define paths
NOTES_DIR="$HOME/Documents/melissanotes"
NOTES_PROJECT_DIR="$NOTES_DIR/Hatch/Projects"
NOTES_FILE="$NOTES_PROJECT_DIR/$STORY_NUMBER.md"
SERVICE_DIR="$HOME/code/$SERVICE_NAME"
WORKTREE_DIR="$HOME/code/$STORY_NUMBER"
SESSION_NAME="$STORY_NUMBER-$SLUG"

# Humanize slug for notes header
humanize_slug() {
    local slug="$1"
    # Replace hyphens with spaces and capitalize each word
    echo "$slug" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1'
}

HUMANIZED_SLUG=$(humanize_slug "$SLUG")

info "=== Linear Workspace Setup ==="
info "Story: $STORY_NUMBER"
info "Slug: $SLUG"
info "Service: $SERVICE_NAME"
info "Session: $SESSION_NAME"
echo

# Validation: Check if notes directory structure exists
info "Validating paths..."
if [[ ! -d "$NOTES_DIR" ]]; then
    error "Notes directory does not exist: $NOTES_DIR"
fi

if [[ ! -d "$NOTES_PROJECT_DIR" ]]; then
    error "Notes project directory does not exist: $NOTES_PROJECT_DIR\nExpected: $NOTES_PROJECT_DIR"
fi

# Validation: Check if service directory exists
if [[ ! -d "$SERVICE_DIR" ]]; then
    error "Service directory does not exist: $SERVICE_DIR"
fi

# Validation: Check if service directory is a git repository
if ! git -C "$SERVICE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    error "Service directory is not a git repository: $SERVICE_DIR"
fi

# Validation: Check if tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    error "Tmux session '$SESSION_NAME' already exists. Attach with: tmux attach -t $SESSION_NAME"
fi

# Validation: Check if worktree already exists
if [[ -d "$WORKTREE_DIR" ]]; then
    warn "Worktree directory already exists: $WORKTREE_DIR"
    warn "This may indicate the worktree was already created."
    # Check if it's actually a git worktree
    if git -C "$SERVICE_DIR" worktree list | grep -q "$WORKTREE_DIR"; then
        info "Worktree is registered in git, will proceed with existing worktree"
    else
        error "Directory exists but is not a git worktree: $WORKTREE_DIR"
    fi
fi

success "All validations passed"
echo

# Create tmux session
info "Creating tmux session: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" -n "Notes"

# Window 1: Notes
info "Setting up Notes window..."
tmux send-keys -t "$SESSION_NAME:Notes" "cd '$NOTES_DIR'" Enter
tmux send-keys -t "$SESSION_NAME:Notes" "nvim '$NOTES_FILE'" Enter

# Create notes file with header if it doesn't exist
if [[ ! -f "$NOTES_FILE" ]]; then
    echo "# $HUMANIZED_SLUG" > "$NOTES_FILE"
    info "Created notes file: $NOTES_FILE"
fi

# Window 2: Service (with worktree creation)
info "Setting up $SERVICE_NAME window..."
tmux new-window -t "$SESSION_NAME" -n "$SERVICE_NAME"
tmux send-keys -t "$SESSION_NAME:$SERVICE_NAME" "cd '$SERVICE_DIR'" Enter

# Create worktree using the fish function
info "Creating worktree for $STORY_NUMBER..."
# We need to invoke the worktree.fish function, but we're in bash
# The worktree.fish function will handle the actual creation
if [[ ! -d "$WORKTREE_DIR" ]]; then
    # Call worktree creation directly with git commands (same logic as worktree.fish)
    info "Executing: git worktree add '$WORKTREE_DIR' -b '$STORY_NUMBER-$SLUG'"
    if git -C "$SERVICE_DIR" worktree add "$WORKTREE_DIR" -b "$STORY_NUMBER-$SLUG" 2>&1; then
        success "Worktree created successfully"

        # Copy configuration files (same as worktree.fish)
        info "Copying configuration files..."
        if ls "$SERVICE_DIR"/.env.assistant* >/dev/null 2>&1; then
            cp "$SERVICE_DIR"/.env.assistant* "$WORKTREE_DIR/"
            info "  ✓ Copied .env.assistant* files"
        else
            warn "  No .env.assistant* files found"
        fi

        if [[ -f "$SERVICE_DIR/.iex.local.exs" ]]; then
            cp "$SERVICE_DIR/.iex.local.exs" "$WORKTREE_DIR/"
            info "  ✓ Copied .iex.local.exs"
        else
            warn "  No .iex.local.exs file found"
        fi
    else
        error "Failed to create worktree"
    fi
fi

# Navigate to worktree in the service window
tmux send-keys -t "$SESSION_NAME:$SERVICE_NAME" "cd '$WORKTREE_DIR'" Enter
tmux send-keys -t "$SESSION_NAME:$SERVICE_NAME" "clear" Enter

# Window 3: Agent
info "Setting up Agent window..."
tmux new-window -t "$SESSION_NAME" -n "Agent 󰧑"
tmux send-keys -t "$SESSION_NAME:Agent 󰧑" "cd '$WORKTREE_DIR'" Enter
tmux send-keys -t "$SESSION_NAME:Agent 󰧑" "claude" Enter

# Note: We do NOT send /brainstorm command - user runs it manually
# This is intentional to avoid timing issues and give user control

# Select the first window (Notes) and attach
tmux select-window -t "$SESSION_NAME:Notes"

echo
success "=== Workspace Setup Complete ==="
info "Session: $SESSION_NAME"
info "Notes: $NOTES_FILE"
info "Worktree: $WORKTREE_DIR"
info "Branch: $STORY_NUMBER-$SLUG"
echo
info "Windows created:"
info "  1. Notes - nvim with $STORY_NUMBER.md"
info "  2. $SERVICE_NAME - worktree at $WORKTREE_DIR"
info "  3. Agent 󰧑 - Claude Code CLI (run /brainstorm $STORY_NUMBER manually)"
echo
info "Attaching to session..."

# Attach to session
if [[ -n "$TMUX" ]]; then
    # Already in tmux, switch to new session
    tmux switch-client -t "$SESSION_NAME"
else
    # Not in tmux, attach to session
    tmux attach-session -t "$SESSION_NAME"
fi
