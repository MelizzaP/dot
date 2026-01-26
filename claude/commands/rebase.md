---
agent: developer
tools: Write, Edit, Bash, Read, List, Grep, Glob, sentient-agi-reasoning_code_reasoning, TodoWrite, TodoRead, Task
description: Rebase current branch with main branch
---

# Rebase

You need to perform a git rebase on origin/main and systematically resolve any merge conflicts that arise. Here's the specific workflow to follow:

1. First, fetch the latest changes from origin
2. Start the rebase: `git rebase origin/main`
3. For each merge conflict that occurs:
      - Identify the conflicted files
      - Resolve the conflicts by examining the code and choosing the appropriate resolution
      - Stage the resolved files with `git add`
      - Run tests to ensure the resolution doesn't break functionality: `uv run pytest` or equivalent test command
      - Run formatting/linting commands to ensure code quality standards are met
      - Only proceed to the next conflict after tests pass
4. After all conflicts are resolved and tests pass, complete the rebase with `git rebase --continue`

Be methodical - resolve one conflict at a time, validate with tests, then move to the next. If any tests fail during conflict resolution, fix the issues
before proceeding.

IMPORTANT:
- Always run tests after resolving each conflict before continuing
- Run formatting/linting checks to ensure code quality
- Only use `git rebase --continue` at the very end when all conflicts are resolved and tests pass
- If you encounter any issues, stop and report what happened
