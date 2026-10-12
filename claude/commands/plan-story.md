---
description: End-to-end story workflow, plan with atomic TDD commits, implement, draft PR, interactive review loop, Obsidian capture
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Task
  - AskUserQuestion
  - TodoWrite
  - mcp__claude_ai_Linear__get_issue
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_search_public
  - mcp__sentient-agi-reasoning__code-reasoning
---

# Plan Story

End-to-end workflow: read a Linear story, plan atomic TDD commits, implement, open a draft PR, run an interactive review loop via Octo.nvim, then capture everything in Obsidian.

## Input

$ARGUMENTS - A Linear ticket ID (e.g., `AI-672`) followed by your initial thoughts/prompt.

Example: `/plan-story AI-672 I think we should use GenServer for the supervisor tree and keep the state minimal`

## Global writing rules

These apply to ALL generated text throughout this command:

- NEVER use em dashes (the Unicode character). Use hyphens, commas, semicolons, or rewrite.
- No "This PR" preambles, no hedging, no AI slop
- Principal-engineer voice, terse, direct
- Tests are tablestakes: NEVER mention adding tests in commit messages, PR descriptions, or plans
- If there are no tests for a commit, explain why

---

## Phase 0: Workspace Detection

1. Check current branch: `git rev-parse --abbrev-ref HEAD`
2. Check tmux session: `tmux display-message -p '#S' 2>/dev/null`
3. If on `main` or `master`, or not in a tmux session, use `AskUserQuestion`:
   - "Run /linear-workspace first" (user needs to set up workspace)
   - "Continue anyway" (already in the right place, just on the wrong branch or outside tmux)
4. Capture the tmux session name and current branch for later phases.

## Phase 1: Context Gathering

1. Parse `$ARGUMENTS`. The first token matching `[A-Z]{2,}-\d+` is the story ID. Everything after it is the initial prompt.
2. If no story ID found, use `AskUserQuestion` to get one (or skip).
3. Fetch the story via `mcp__claude_ai_Linear__get_issue` with the identifier. Capture title, description, status, labels, project. If Linear MCP is unauthorized, warn and continue with whatever the user provided.
4. **Store the raw initial prompt text.** This exact text gets saved to Obsidian in Phase 7.
5. Spawn an Explore subagent via `Task` to map the change surface area:
   - Search for files/modules relevant to the story
   - Identify existing patterns and conventions
   - Note technical constraints
   - Return a summary of relevant files, patterns to follow, and potential gotchas

## Phase 2: Planning

Using the Linear story, user prompt, and codebase exploration results, produce a plan.

### Plan format

Write to `plans/<story-number>-plan.md`:

```markdown
# [STORY-NUMBER]: [Story Title]

## Context
[Problem being solved, derived from Linear story + user prompt]

## Approach
[High-level strategy, 3-5 sentences]

## Commits

### 1. [STORY-NUMBER]: Short description
- Bullet describing what changes
- Another bullet
- If no tests possible, explain why

### 2. [STORY-NUMBER]: Next short description
- What changes

## Risks / Open Questions
- [Anything unresolved]
```

### Commit message rules

Every commit message in the plan must follow this format exactly:

```
[STORY-NUMBER]: Short Description

- Use bullet format
- Keep descriptions concise
- NEVER use em dashes, use a colon or comma instead
- NEVER mention adding tests
- If there are no tests, explain why
```

### Plan approval

Present the plan to the user via `AskUserQuestion`:
- "Approve plan"
- "Modify plan" (user provides changes)
- "Abort"

Iterate until approved.

### Model switch gate

After plan approval, pause with `AskUserQuestion`:
- "Continue (current model)"
- "Switching model first"

Display: "Plan approved. If you want to switch to a faster model for implementation, do it now (`/model sonnet`), then select Continue."

## Phase 3: Implementation

For each commit in the approved plan, in order:

1. **Write test(s) first** (TDD). Follow existing test patterns in the codebase.
2. **Run tests.** Confirm the new test fails (red).
3. **Write implementation.**
4. **Run tests.** Confirm all pass (green).
5. **Run lint/format.** Auto-detect project type:
   - Elixir: `mix format` + `mix credo --strict`
   - Python: `ruff check --fix` + `basedpyright`
   - JavaScript/TypeScript: project-specific linter
6. **Commit:**
   ```bash
   git add -A
   git commit -m "[STORY-NUMBER]: Short description

   - bullet 1
   - bullet 2"
   ```

For complex commits, delegate to `Task(subagent_type="developer")` with the full commit spec and codebase context.

**If tests fail after implementation:** attempt to fix (max 2 tries). If still failing, stop and use `AskUserQuestion` to discuss.

**If an unforeseen issue arises:** stop and use `AskUserQuestion`. Do not deviate from the plan without user approval.

## Phase 4: Draft PR

Follows the `/pr-description` command pattern. Execute these steps in order:

### Pre-flight

Run in parallel and bail on failure:
- `git rev-parse --abbrev-ref HEAD` (abort if `main`/`master`)
- `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null` (if no upstream, `git push -u origin HEAD`)
- `gh pr view --json number,url 2>/dev/null` (if PR exists, tell user to use `gh pr edit`)
- Determine base branch: `main`, fall back to `master`

### Push

```bash
git push -u origin HEAD
```

### Gather diff context

In parallel:
- `git diff <base>...HEAD -- ':!test'` and `git diff <base>...HEAD --stat -- ':!test'` (for Changes, excludes test files)
- `git diff <base>...HEAD` full diff (for Testing)
- `git log <base>..HEAD --pretty=format:'%h %s%n%b'` (commits with bodies)

### Draft Context (no subagent)

Write Context yourself: 2-3 tight sentences explaining the *why*. Use Linear story + user prompt + commit history. No code references, no file lists. Propose to user via `AskUserQuestion`:
- "Looks good"
- "I'll write my own" (user provides replacement)

### Ask about Monitoring

`AskUserQuestion`:
- "Yes, include monitoring"
- "No monitoring needed"

### Two parallel subagents

Send one message with two `Task` calls. Include global writing rules in each prompt.

**developer -> Changes:**

> Write the "Changes" section of a PR description. High-level overview of what changed for a reviewer. Reference key functions/modules by name when helpful. Use backticks for code identifiers.
>
> Rules:
> - NEVER mention tests, test files, test coverage, or test counts
> - NEVER use em dashes. Use hyphens, commas, or rewrite.
> - No "This PR" preambles. No hedging or marketing language.
> - Terse, principal-engineer voice.
>
> Diff (test files excluded): <diff>
> Stat (test files excluded): <stat>
> Commits: <commits>
>
> Return only the section body. No header, no fences.

**qa-engineer -> Testing:**

> Write the "Testing" section. Manual verification only.
>
> Rules:
> - NEVER mention unit tests, automated tests, test counts, or test coverage
> - NEVER use em dashes. Use hyphens, commas, or rewrite.
> - No prose paragraphs. Short bullets only.
> - Each bullet: action a human takes + expected outcome (curl, iex, browser steps with expected HTTP status or output)
>
> Structure:
> 1. **Manual** - bullet list of verification steps with concrete commands and expected outcomes
> 2. **Risks** - max 3 bullets, each ONE line
> <IF_MONITORING> 3. **Monitoring** - specific Loki/Prometheus queries or dashboard names </IF_MONITORING>
>
> Monitoring instructions: <"Include a Monitoring subsection" OR "Do NOT include a Monitoring subsection">
>
> Diff: <full diff>
> Linear story: <title + description>
>
> Return only the section body. No header, no fences.

### Assemble

```markdown
## Context
<user-approved context>

## Changes
<developer output>

## Testing
<qa-engineer output>
```

### Reviewer polish pass

Spawn one `Task`:

> Principal engineer reviewing this PR description before submission:
> 1. Remove redundancy across sections.
> 2. Strip AI slop: hedging, throat-clearing, marketing language, "This PR" preambles.
> 3. Search and destroy every em dash. Replace with hyphen, comma, semicolon, or restructure.
> 4. Verify Changes does NOT mention tests, test files, or test coverage.
> 5. Verify Testing does NOT mention unit tests, automated tests, or test counts.
> 6. Verify each Risks bullet is a single concise line.
> 7. Verify each section answers its remit: Context = why; Changes = high-level overview; Testing = manual steps.
>
> Edit only what's there. Keep all `##` headers. Return polished markdown only, no fences.
>
> ---
> <assembled draft>

### Show draft to user

Present the full PR body via `AskUserQuestion`:
- "Looks good, create the PR"
- "I want to make edits" (user provides revised body)

### PR title

`AskUserQuestion` suggesting a title from the Linear story title or most descriptive commit subject.

### Create

```bash
# Write body to temp file to avoid shell escaping issues
BODY_FILE=$(mktemp)
# (write polished body to $BODY_FILE)
gh pr create --draft --base <base> --title "<title>" --body-file "$BODY_FILE"
rm "$BODY_FILE"
```

Capture the PR number and URL from output.

## Phase 5: Review Loop

### Setup

1. Detect tmux session: `tmux display-message -p '#S'`
2. Create review window:
   ```bash
   tmux new-window -t "$SESSION" -n "PR Review"
   tmux send-keys -t "$SESSION:PR Review" "nvim -c 'Octo pr edit $PR_NUMBER'" Enter
   ```
3. Tell the user:

   > PR Review window created. Switch to it (Prefix+N or Prefix+number).
   >
   > Review workflow:
   > 1. Start review: `<localleader>vs`
   > 2. Leave line comments: `<localleader>ca`
   > 3. Submit review as "Comment" (not Approve/Reject) so comments land on GitHub
   > 4. Come back here and select "Review submitted"

### Loop

Repeat until approval:

1. `AskUserQuestion`:
   - "Review submitted: read my comments"
   - "I have feedback to type here"
   - "Approved: mark ready for review"

2. **If "Review submitted":**
   - Fetch comments:
     ```bash
     gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {path: .path, line: .line, body: .body, id: .id}'
     gh pr view $PR_NUMBER --json reviews,comments
     ```
   - If no new comments found, tell user and re-prompt.
   - Group comments by theme: bugs, questions, style, change requests.
   - For questions: gather all, answer in a single response, ask for confirmation before proceeding.
   - For change requests: make the changes.
   - **Before pushing**: run tests + lint. If failing, fix first.
   - `git push`
   - Notify user changes are pushed and ready for re-review.

3. **If "Feedback here":** read user input, address each point, make changes, test, push.

4. **If "Approved":** proceed to Phase 6.

## Phase 6: Finalization

```bash
gh pr ready $PR_NUMBER
gh pr edit $PR_NUMBER --add-label "env:assistant-2"
```

If `env:assistant-2` label doesn't exist, try `gh label create "env:assistant-2"`. If that fails too, warn and skip.

Report final PR URL to user.

## Phase 7: Obsidian Capture

Two insertions into today's daily note.

### Step 1: Top of Mind (story + PR link)

1. Get today's date: `date +%Y-%m-%d`
2. Read the daily note: `~/Documents/melissanotes/dailies/YYYY-MM-DD.md`
   - If it doesn't exist, run `obsidian daily:read` to trigger creation from template, then read the file.
3. Find the `## Top of Mind` section.
4. Search for an existing TODO referencing the story number (line containing `[[STORY-NUMBER]]` or just `STORY-NUMBER`).
5. **If found:** use `Edit` to insert an indented sub-item on the next line:
   ```
       - PR: <PR_URL>
   ```
6. **If not found:** use `Edit` to insert a new TODO before the next `##` header after Top of Mind:
   ```
   - [ ] [[STORY-NUMBER]] - <Story Title>
       - PR: <PR_URL>
   ```

### Step 2: Prompts section (full initial prompt)

1. Check if `## Prompts` section exists in the daily note.
2. **If not:** use `obsidian daily:append` to add:
   ```

   ## Prompts

   ### [[STORY-NUMBER]] - <Story Title>
   <full initial prompt text>
   ```
3. **If exists:** use `Edit` to append the new entry at the end of the Prompts section:
   ```

   ### [[STORY-NUMBER]] - <Story Title>
   <full initial prompt text>
   ```

## Error Handling

| Scenario | Action |
|----------|--------|
| Linear MCP unauthorized | Warn, continue with user-provided context |
| On `main`/`master` with no workspace | Offer `/linear-workspace` setup |
| `gh pr create` fails | Print error + assembled body for manual submission |
| Tests fail during implementation (2 tries) | Stop, ask user |
| No review comments after "review submitted" | Tell user, re-prompt |
| `env:assistant-2` label missing | Try `gh label create`, else warn and skip |
| Daily note missing | Create via `obsidian daily:read`, then proceed |
| Subagent returns empty | Stop before PR create, report which section failed |
