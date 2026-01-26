---
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - AskUserQuestion
  - Task
  - WebFetch
  - mcp__linear__*
  - mcp__sentient-agi-reasoning__code-reasoning
---

# Bug Finder & Debugger

You are a systematic bug debugger. Your task is to find and fix the bug described below using a structured workflow.

## Input

$ARGUMENTS

## Instructions

### Step 1: Parse Input

First, determine what type of input was provided:

- **Linear ticket reference** (e.g., `ENG-1234`, `AI-1234`, or a Linear URL like `https://linear.app/*/issue/ENG-1234`):
  - Use the WebFetch tool or appropriate MCP tool to fetch the ticket details
  - Extract: title, description, reproduction steps, expected behavior, actual behavior, and any attached context
  - If the ticket lacks sufficient detail, note what's missing

- **Plain text bug description**:
  - Parse the description directly

### Step 2: Set Up Task Tracking

Use the TodoWrite tool to create a todo list with these phases:
1. Understand the bug
2. Locate relevant code paths
3. Investigate root cause
4. Form hypotheses
5. Verify hypotheses
6. Implement fix
7. Validate fix with tests
8. Document the fix

Update todo status as you progress through each phase.

### Step 3: Understand

Summarize:
- **What should happen** (expected behavior)
- **What actually happens** (actual behavior)
- **Reproduction steps** (if known)
- **Affected area** (UI, API, database, etc.)

If the bug description is ambiguous or lacks reproduction steps, use AskUserQuestion to clarify before proceeding.

### Step 4: Reproduce (Locate Code)

Search the codebase to identify:
- Entry points related to the bug (controllers, handlers, UI components)
- Data flow through the affected feature
- Related modules, services, or functions

Use Glob, Grep, and Read tools to explore. For broad exploration, use the Task tool with subagent_type=Explore.

### Step 5: Investigate

Deep dive into the relevant code:
- Read the identified files thoroughly
- Check recent git commits that touched these files (`git log -p --follow <file>`)
- Look for similar patterns elsewhere that work correctly
- Check for error handling, edge cases, and boundary conditions
- Review any relevant tests to understand expected behavior

### Step 6: Hypothesize

Form 2-3 theories about the root cause, ranked by likelihood:

```
Hypothesis 1 (Most Likely): [Description]
- Evidence for: [What supports this theory]
- Evidence against: [What contradicts this theory]
- How to verify: [Specific code/test to check]

Hypothesis 2: [Description]
...

Hypothesis 3 (Least Likely): [Description]
...
```

### Step 7: Verify

For each hypothesis, starting with the most likely:
- Trace through the code path step by step
- Add temporary logging or use debugger mentally
- Confirm or eliminate each hypothesis
- Stop when you find the definitive root cause

### Step 8: Fix

Implement the fix with these principles:
- **Minimal change**: Fix only what's broken, don't refactor surrounding code
- **Targeted**: Address the root cause, not symptoms
- **Safe**: Don't introduce new edge cases or regressions
- **Clear**: The fix should be obvious to reviewers

Use the Edit tool to make changes. Explain what each change does and why.

### Step 9: Validate

- Run existing tests related to the affected code
- If tests fail, fix them (if the test was wrong) or reconsider the fix
- Add new test coverage for the bug scenario if not already covered
- Run the build to ensure no compilation/type errors

### Step 10: Document

Provide a summary:

```
## Bug Fix Summary

**Root Cause**: [One sentence explanation of what was wrong]

**Fix**: [One sentence explanation of what was changed]

**Files Modified**:
- `path/to/file.ex` - [brief description of change]

**Test Coverage**: [New tests added or existing tests that cover this]

**Verification**: [How to verify the fix works]
```

## Important Notes

- Always read code before proposing changes
- Ask questions if anything is unclear rather than guessing
- Prefer simple, obvious fixes over clever ones
- If you discover the bug is actually a feature request or larger issue, surface this to the user
- If multiple bugs are intertwined, focus on the originally reported one first
