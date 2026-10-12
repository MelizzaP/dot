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

Orchestrate a draft PR for the current branch. Context is proposed interactively, Changes and Testing are written by parallel subagents, a final reviewer polishes, then `gh pr create --draft` opens the PR.

## Global writing rules (apply to ALL generated text)

- NEVER use em dashes (the Unicode character). Use hyphens, commas, semicolons, or rewrite the sentence. This is non-negotiable.
- No "This PR" preambles
- No hedging, throat-clearing, or marketing language
- Principal-engineer voice, terse, direct
- Use backticks for code identifiers (modules, functions, config keys)
- No AI slop

## 1. Pre-flight

Run these Bash checks in parallel and bail with a clear message on failure:

- Current branch: `git rev-parse --abbrev-ref HEAD`. If `main` or `master`, abort.
- Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null`. If absent, confirm with the user via `AskUserQuestion`, then `git push -u origin HEAD`.
- Existing PR: `gh pr view --json number,url 2>/dev/null`. If one exists, stop and tell the user to use `gh pr edit` instead.
- Base branch: default `main`; fall back to `master` if `main` is absent.

## 2. Detect the Linear ticket

Search for a ticket ID matching `[A-Z]{2,}-\d+`:

1. Branch name.
2. Commit subjects: `git log <base>..HEAD --pretty=%s`.

If nothing matches, use `AskUserQuestion`:

- "I'll paste it" (user supplies via Other)
- "Skip, no Linear ticket"

If a ticket is found or supplied, call `mcp__claude_ai_Linear__get_issue`. Capture title, description, status, project. If the Linear MCP isn't authorized, skip and note "Linear context unavailable".

## 3. Search Slack for context

In parallel via `mcp__claude_ai_Slack__slack_search_public_and_private` (fall back to `mcp__claude_ai_Slack__slack_search_public` if not authorized; skip entirely if neither works):

- The Linear ticket ID, if detected.
- The branch name with any `user/` prefix stripped.
- The Linear issue title, if available (quoted).

Keep messages that look substantive (decisions, requirements, bug reports, scoping). Discard generic mentions.

## 4. Gather diff context

In parallel:

- `git diff <base>...HEAD -- ':!test'` and `git diff <base>...HEAD --stat -- ':!test'` for the Changes subagent (excludes test directory).
- `git diff <base>...HEAD` full diff for the Testing subagent (needs to see everything to write manual verification steps).
- `git log <base>..HEAD --pretty=format:'%h %s%n%b'` for commits with bodies.

## 5. Propose Context to user

Using the Linear story, Slack context, and commit history, draft a Context section yourself (no subagent). Write 2-3 tight sentences that explain the *why*: what prompted these changes, what problem they solve, what the goal is. No code references, no file lists. Match this style:

> Cerebras enforces the qwen-3-27b chat template strictly: a payload containing only a system message is rejected with HTTP 400. When Cerebras was switched to qwen-3-27b in Sep 2026, every summary request routed through it began failing.

> OAuth 2.1 requires PKCE for all authorization flows. MCP hosts generate `code_verifier`/`code_challenge` pairs. Changes verify that key in order to mint a jwt.

Present the proposed Context to the user via `AskUserQuestion`:

- "Looks good" (accept as-is)
- "I'll write my own" (user provides replacement via Other)

## 6. Ask about Monitoring

Use `AskUserQuestion`:

- "Yes, include monitoring"
- "No monitoring needed"

Store the answer to pass to the Testing subagent.

## 7. Spawn two subagents in parallel

Send one message with two `Task` calls. Each prompt must be self-contained with all context inlined. Include the global writing rules in each prompt.

### developer -> Changes

> Write the "Changes" section of a PR description. High-level overview of what changed for a reviewer. You may reference key functions/modules by name when it aids comprehension. Use backticks for code identifiers.
>
> Rules:
> - NEVER mention tests, test files, test coverage, or test counts. Tests do not exist for this section.
> - NEVER use em dashes (the Unicode character). Use hyphens, commas, or rewrite.
> - No "This PR" preambles. No hedging or marketing language.
> - Terse, principal-engineer voice.
>
> Diff (test files excluded): <diff without test directory>
> Stat (test files excluded): <stat without test directory>
> Commits: <commits with bodies>
>
> Return only the section body. No header, no fences.

### qa-engineer -> Testing

> Write the "Testing" section of a PR description. This section tells a human engineer how to manually verify the change works.
>
> Rules:
> - NEVER mention unit tests, automated tests, test counts, or test coverage. This section is exclusively about manual verification.
> - NEVER use em dashes (the Unicode character). Use hyphens, commas, or rewrite.
> - No prose paragraphs. Short bullets only.
> - Each bullet is an action a human takes + the expected outcome. Examples:
>   - `POST /api/mcp/auth/token` with a valid code, confirm JWT decodes with correct `sub`, `organization_id`, `role`
>   - In iex: `Accounts.resolve_mcp_token_claims(user, org_id)` returns expected claims map
>   - Set `disabled: true` on an org's Mongo doc, exchange an MCP code, expect 403
>
> Structure:
> 1. **Manual** - bullet list of verification steps with concrete commands (curl, iex, browser) and expected outcomes
> 2. **Risks** - max 3 bullets, each ONE line. Concise. Only real risks, not hypotheticals.
> <IF_MONITORING> 3. **Monitoring** - specific Loki/Prometheus queries or dashboard names. Not vague "watch the dashboard." </IF_MONITORING>
>
> Monitoring instructions: <"Include a Monitoring subsection" OR "Do NOT include a Monitoring subsection">
>
> Diff: <full diff>
> Linear story: <title + description>
>
> Return only the section body. No header, no fences.

## 8. Assemble the draft

Stitch into this exact structure (h2 headers, blank line between sections):

    ## Context
    <user-approved context from step 5>

    ## Changes
    <developer output>

    ## Testing
    <qa-engineer output>

## 9. Final reviewer pass

Spawn one `Task` with `subagent_type: general-purpose`:

> You are a principal engineer reviewing the following PR description before submission. Do these checks:
> 1. Remove redundancy across sections (same fact stated in Context and Changes, etc.).
> 2. Strip AI slop: hedging, throat-clearing, marketing language, generic praise, "This PR" preambles.
> 3. **Search and destroy every em dash (the Unicode character).** Replace each with a hyphen, comma, semicolon, or restructure the sentence. There must be ZERO em dashes in the final output.
> 4. Verify the Changes section does NOT mention tests, test files, or test coverage. Remove any references.
> 5. Verify the Testing section does NOT mention unit tests, automated tests, or test counts. Remove any references.
> 6. Verify each Risks bullet is a single concise line.
> 7. Verify each section answers its remit: Context = why; Changes = high-level code overview; Testing = manual verification steps.
>
> Edit only what's there; do not invent new content. Keep all `##` headers. Return the polished markdown only, no code fences around the output.
>
> ---
> <assembled draft>

## 10. Present draft to user

Show the full assembled and reviewed PR body to the user. Ask via `AskUserQuestion`:

- "Looks good, create the PR"
- "I want to make edits" (user provides revised body via Other)

## 11. Prompt for PR title

Use `AskUserQuestion` with one question. Suggest a title derived from the Linear story title (preferred) or the most descriptive commit subject. Match conventional-commit style if commits already use it.

## 12. Create the draft PR

Run:

    gh pr create --draft --base <base> --title "<user-provided title>" --body-file <path>

Write the polished body to a temp file first (`mktemp` + `Write`) to avoid heredoc/shell-escaping issues. Return the PR URL to the user.

## Failure modes

- Any subagent returns empty or errors: stop before `gh pr create`, report which section failed, ask the user how to proceed.
- `gh pr create` fails: print the error verbatim and the assembled body so the user can submit manually.
