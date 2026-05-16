function worktree --description 'Create a git worktree with Linear story workflow'
  if test (count $argv) -lt 2
    gum style --foreground 196 "󰀦 Usage: worktree <LINEAR_STORY_NUMBER> <BRANCH_SLUG>"
    gum style --foreground 245 "   Example: worktree ABC-123 feature-name"
    return 1
  end

  set story_number $argv[1]
  set branch_slug $argv[2]
  set branch_name "$story_number-$branch_slug"
  set worktree_path "../$story_number"

  if not git rev-parse --git-dir >/dev/null 2>&1
    gum style --foreground 196 "󰀦 Not in a git repository"
    return 1
  end

  if test -d $worktree_path
    gum style --foreground 196 "󰀦 Directory $worktree_path already exists"
    return 1
  end

  gum style --border rounded --padding "0 1" --border-foreground 46 \
    "󰊢 Creating worktree" \
    "󰉋 Path:   $worktree_path" \
    "󰘬 Branch: $branch_name"

  if not gum spin --title "git worktree add..." --show-output -- \
      git worktree add $worktree_path -b $branch_name
    gum style --foreground 196 "󰀦 Failed to create worktree"
    return 1
  end

  gum style --foreground 39 "󰉋 Copying configuration files..."

  if ls .env.assistant* >/dev/null 2>&1
    cp .env.assistant* $worktree_path/
    gum style --foreground 46 "  󰸞 Copied .env.assistant* files"
  else
    gum style --foreground 226 "  󰀦 No .env.assistant* files found"
  end

  if test -f .iex.local.exs
    cp .iex.local.exs $worktree_path/
    gum style --foreground 46 "  󰸞 Copied .iex.local.exs"
  else
    gum style --foreground 226 "  󰀦 No .iex.local.exs file found"
  end

  cd $worktree_path

  gum style --border rounded --padding "0 1" --border-foreground 201 \
    "󱓞 Worktree ready" \
    "󰘬 Branch: "(git branch --show-current) \
    "󰉋 Dir:    "(pwd)
end
