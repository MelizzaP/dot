---
description: Create a draft PR with a structured description (Context / Changes / Testing) via parallel subagents
allowed-tools:
  - Bash
  - Read
  - Task
  - AskUserQuestion
  - mcp__claude_ai_Linear__get_issue
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_search_public
---

# Draft PR Description

Orchestrate a draft PR for the current branch. Three section-owning subagents run in parallel, a final reviewer polishes the assembled body, then `gh pr create --draft` opens the PR.

## 1. Pre-flight

Run these Bash checks in parallel and bail with a clear message on failure:

- Current branch: `git rev-parse --abbrev-ref HEAD`. If `main` or `master`, abort — no branch to PR.
- Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null`. If absent, confirm with the user via `AskUserQuestion`, then `git push -u origin HEAD`.
- Existing PR: `gh pr view --json number,url 2>/dev/null`. If one exists, stop and tell the user to use `gh pr edit` instead.
- Base branch: default `main`; fall back to `master` if `main` is absent.

## 2. Detect the Linear ticket

Search for a ticket ID matching `[A-Z]{2,}-\d+`:

1. Branch name.
2. Commit subjects: `git log <base>..HEAD --pretty=%s`.

If nothing matches, use `AskUserQuestion`:

- "I'll paste it" (user supplies via Other)
- "Skip — no Linear ticket"

If a ticket is found or supplied, call `mcp__claude_ai_Linear__get_issue`. Capture title, description, status, project. If the Linear MCP isn't authorized, skip and note "Linear context unavailable" — do not abort.

## 3. Search Slack for context

In parallel via `mcp__claude_ai_Slack__slack_search_public_and_private` (fall back to `mcp__claude_ai_Slack__slack_search_public` if not authorized; skip entirely if neither works):

- The Linear ticket ID, if detected.
- The branch name with any `user/` prefix stripped.
- The Linear issue title, if available (quoted).

Keep messages that look substantive — decisions, requirements, bug reports, scoping discussion. Discard generic mentions.

## 4. Gather diff context

In parallel:

- `git diff <base>...HEAD` — full diff.
- `git log <base>..HEAD --pretty=format:'%h %s%n%b'` — commits with bodies.
- `git diff <base>...HEAD --stat` — file change summary.

## 5. Spawn three subagents in parallel

Send one message with three `Task` calls. Each prompt must be self-contained — inline the Linear story, Slack context, and diff/log info. Bake in this tone for all three: principal-engineer voice, terse, no AI slop, no "This PR" preambles, no hedging.

### system-architect → Context

> Write the "Context" section of a PR description. Explain the *why*: what prompted these changes, what problem they solve, what the goal is. No code references, no file lists. 3-6 tight sentences.
>
> Linear story: <title, description, status>
> Slack chatter: <relevant messages or "none found">
> Commits: <subjects + bodies>
>
> Return only the section body — no header, no fences.

### developer → Changes

> Write the "Changes" section. High-level overview of what changed — a preamble for the reviewer, not a file-by-file walkthrough. You may reference key functions/modules by name when it aids comprehension; don't quote file paths or paste code.
>
> Diff: <full diff>
> Stat: <file change summary>
> Commits: <commits with bodies>
>
> Return only the section body — no header, no fences.

### qa-engineer → Testing

> Write the "Testing" section, covering in order:
> 1. Manual testing strategy that confirms the change works and doesn't regress adjacent behavior.
> 2. Grafana queries or dashboards that could monitor the feature — only if the change touches a plausibly observable system; otherwise state "No applicable dashboards."
> 3. Risks this change introduces.
>
> Short bullets, not prose.
>
> Diff: <full diff>
> Linear story: <title + description>
>
> Return only the section body — no header, no fences.

## 6. Assemble the draft

Stitch into this exact structure (h2 headers, blank line between sections):

    ## Context
    <system-architect output>

    ## Changes
    <developer output>

    ## Testing
    <qa-engineer output>

## 7. Final reviewer pass

Spawn one `Task` with `subagent_type: general-purpose`:

> You are a principal engineer reviewing the following PR description before submission. Do three things:
> 1. Remove redundancy across sections (same fact stated in Context and Changes, etc.).
> 2. Strip AI-slop tells: hedging, throat-clearing, marketing language, generic praise, "This PR" preambles.
> 3. Verify each section answers its remit — Context = why; Changes = high-level code overview; Testing = manual strategy + monitoring + risks.
>
> Edit only what's there; do not invent new content. Keep all three `##` headers. Return the polished markdown only — no code fences around the output.
>
> ---
> <assembled draft>

## 8. Prompt for PR title

Use `AskUserQuestion` with one question. Suggest a title derived from the Linear story title (preferred) or the most descriptive commit subject. Match conventional-commit style if commits already use it.

## 9. Create the draft PR

Run:

    gh pr create --draft --base <base> --title "<user-provided title>" --body-file <path>

Write the polished body to a temp file first (`mktemp` + `Write`) to avoid heredoc/shell-escaping issues. Return the PR URL to the user.

## Failure modes

- Any subagent returns empty or errors: stop before `gh pr create`, report which section failed, ask the user how to proceed.
- `gh pr create` fails: print the error verbatim and the assembled body so the user can submit manually.
