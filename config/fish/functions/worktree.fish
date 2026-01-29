function worktree --description 'Create a git worktree with Linear story workflow'
  if test (count $argv) -lt 2
    set_color red
    echo "Usage: worktree <LINEAR_STORY_NUMBER> <BRANCH_SLUG>"
    echo "Example: worktree ABC-123 feature-name"
    set_color normal
    return 1
  end

  set story_number $argv[1]
  set branch_slug $argv[2]
  set branch_name "$story_number-$branch_slug"
  set worktree_path "../$story_number"

  if not git rev-parse --git-dir >/dev/null 2>&1
    set_color red
    echo "Error: Not in a git repository"
    set_color normal
    return 1
  end

  if test -d $worktree_path
    set_color red
    echo "Error: Directory $worktree_path already exists"
    set_color normal
    return 1
  end

  set_color green
  echo "🌳 Creating worktree at $worktree_path with branch $branch_name"
  set_color normal

  if not git worktree add $worktree_path -b $branch_name
    set_color red
    echo "Error: Failed to create worktree"
    set_color normal
    return 1
  end

  set_color blue
  echo "📁 Copying configuration files..."
  set_color normal

  if ls .env.assistant* >/dev/null 2>&1
    cp .env.assistant* $worktree_path/
    echo "  ✓ Copied .env.assistant* files"
  else
    set_color yellow
    echo "  ⚠ No .env.assistant* files found"
    set_color normal
  end

  if test -f .iex.local.exs
    cp .iex.local.exs $worktree_path/
    echo "  ✓ Copied .iex.local.exs"
  else
    set_color yellow
    echo "  ⚠ No .iex.local.exs file found"
    set_color normal
  end

  set_color green
  echo "🚀 Worktree created successfully!"
  echo "📂 Changing to $worktree_path"
  set_color normal

  cd $worktree_path

  set_color magenta
  echo "Current branch: "(git branch --show-current)
  echo "Working directory: "(pwd)
  set_color normal
end
