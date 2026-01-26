---
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
  - AskUserQuestion
  - mcp__sentient-agi-reasoning__code-reasoning
---

# Review Implementation Against Spec

Reviews code changes against an implementation specification created by `/write-spec`, verifying spec compliance, pattern consistency, readability, maintainability, and staff-level quality.

## Input

$ARGUMENTS - Either:
- A spec path (e.g., `specs/feature-name-spec.md`)
- A feature slug (e.g., `feature-name`) - will look for `specs/<slug>-spec.md`
- Empty - will attempt to find the most recent spec or list available specs

## Instructions

### Phase 1: Locate the Spec

**Find the spec document:**
- If full path provided, read it directly
- If slug provided, look for `specs/<slug>-spec.md`
- If no argument provided:
  - List files in `specs/` directory matching `*-spec.md`
  - If one spec exists, use it
  - If multiple specs exist, ask user to select one
- If no spec found:
  - Inform user: "No spec found. Please either provide the spec path or run `/write-spec` first to generate one."
  - Exit

**Parse the spec:**
- Extract all acceptance criteria from each task
- Note the files that should have been created/modified
- Understand the expected behavior and edge cases
- Note any testing requirements

### Phase 2: Identify Implementation Changes

**Determine which files changed:**

Run these git commands to understand the scope of changes:

```bash
# Check for staged changes
git diff --cached --name-only

# Check for unstaged changes
git diff --name-only

# Check untracked files
git ls-files --others --exclude-standard

# If on a branch, get all changes vs main
git diff origin/main...HEAD --name-only
```

**Gather the implementation:**
- Read each modified/created file
- Use `git diff` to see the actual changes
- For files mentioned in spec but not changed, note them as potential gaps

**If no changes detected:**
- Use AskUserQuestion to ask user which files to review
- Or ask if they want to review a specific branch

### Phase 3: Spec Compliance Review

**For each task in the spec:**

Walk through every acceptance criterion and verify:

1. **Read the relevant code** - Examine the actual implementation
2. **Check criterion satisfaction:**
   - Does the code fulfill the requirement?
   - Is the behavior correct as specified?
   - Are edge cases from the spec handled?
3. **Mark as PASS, FAIL, or PARTIAL:**
   - PASS: Criterion fully satisfied
   - FAIL: Criterion not implemented or incorrectly implemented
   - PARTIAL: Partially implemented, needs work

**Document gaps:**
- List any acceptance criteria not met
- Note any spec requirements that appear missing
- Flag any behavior that contradicts the spec

### Phase 4: Pattern Consistency Review

**Search for existing patterns:**

For each major implementation area:

1. **Find similar code in the codebase:**
   - Search for similar modules/functions/classes
   - Look for established conventions (naming, structure, error handling)
   - Check how similar features were implemented

2. **Compare implementation to existing patterns:**
   - Does it follow the same structure as similar code?
   - Are naming conventions consistent?
   - Does error handling match existing patterns?
   - Are the same libraries/utilities used for similar tasks?

3. **Flag new patterns:**
   - If the implementation introduces a new pattern, is it justified?
   - Could an existing pattern have been used instead?
   - Is the new pattern well-documented?

### Phase 5: Quality Review

**Readability assessment:**
- Are function/variable names clear and descriptive?
- Is the code structure logical and easy to follow?
- Would another engineer understand the intent without excessive comments?
- Is the abstraction level appropriate (not too high, not too low)?
- Are complex operations broken into understandable steps?

**Maintainability assessment:**
- Are there clear boundaries between components?
- Is coupling minimized?
- Are there hidden side effects?
- Would modifying this code be straightforward?
- Is the code DRY without being over-abstracted?

**Staff-level quality check:**
- Are edge cases handled appropriately?
- Is there defensive coding where needed (but not over-engineered)?
- Are error messages helpful for debugging?
- Is performance considered where it matters?
- Are security implications addressed?
- Does the code show thoughtful design decisions?

### Phase 6: Run Verification (if applicable)

**Run tests:**
```bash
# Detect project type and run appropriate tests
mix test              # Elixir
pytest               # Python
npm test             # JavaScript/TypeScript
```

**Run static analysis:**
```bash
# If available
mix credo            # Elixir
mix format --check-formatted  # Elixir
mix dialyzer         # Elixir
```

Note test results and any failures.

### Phase 7: Generate Review Report

Output a structured markdown report:

```markdown
# Implementation Review: [Feature/Spec Name]

**Spec:** `[path to spec file]`
**Review Date:** [date]
**Files Reviewed:** [count]

## Summary

[2-3 sentences summarizing the implementation and overall assessment]

---

## Spec Compliance

### Task [N]: [Task Name]

| Criterion | Status | Notes |
|-----------|--------|-------|
| [Acceptance criterion 1] | PASS/FAIL/PARTIAL | [explanation if not PASS] |
| [Acceptance criterion 2] | PASS/FAIL/PARTIAL | [explanation if not PASS] |
| ... | ... | ... |

**Task Status:** [COMPLETE / INCOMPLETE / NEEDS WORK]

[Repeat for each task in the spec]

### Compliance Summary

- **Total Criteria:** [count]
- **Passed:** [count] ([percentage]%)
- **Failed:** [count]
- **Partial:** [count]

---

## Pattern Consistency

### Patterns Followed
- [Pattern 1]: Correctly used in [files] - matches [existing example]
- [Pattern 2]: Correctly used in [files] - matches [existing example]

### Pattern Deviations
[If any deviations from established patterns, list them here with justification assessment]

- **File:** `[path]:[line]`
  **Issue:** [Description of deviation]
  **Existing Pattern:** [Reference to how it's done elsewhere]
  **Recommendation:** [Use existing pattern / Keep new pattern because X]

---

## Issues Found

### [SEVERITY]: [Issue Title]
**File:** `[file_path]:[line_number]`
**Category:** [spec-compliance / pattern-consistency / readability / maintainability / quality]

**Code:**
```[language]
[relevant code snippet]
```

**Problem:**
[Detailed explanation of what's wrong]

**Suggestion:**
```[language]
[suggested fix or improvement]
```

---

[Repeat for each issue]

---

## Strengths

- [Positive aspect 1]
- [Positive aspect 2]
- [Positive aspect 3]

---

## Test Results

- **Tests Run:** [PASS/FAIL/SKIPPED]
- **Static Analysis:** [PASS/FAIL/SKIPPED]
- **Failures:** [List any failures]

---

## Recommendations

1. [Prioritized recommendation 1]
2. [Prioritized recommendation 2]
3. [Prioritized recommendation 3]

---

## Overall Assessment

**Decision:** [APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]

**Rationale:**
[Explanation of the decision - why approved, what must change, or what needs discussion]

**Blocking Issues:** [count]
**Non-blocking Issues:** [count]
```

## Severity Definitions

Use these severity levels for issues:

- **BLOCKER**: Must fix before merge - breaks functionality, fails spec criteria, security issue
- **MAJOR**: Should fix before merge - significant maintainability/quality concern, incomplete implementation
- **MINOR**: Fix recommended - readability improvement, minor pattern deviation
- **NITPICK**: Optional - style preference, very minor improvement

## Assessment Criteria

**APPROVE** when:
- All acceptance criteria pass or have minor gaps with clear path to fix
- No blocker or major issues
- Code follows existing patterns (or justified deviations)
- Tests pass

**REQUEST CHANGES** when:
- One or more acceptance criteria fail
- Blocker or major issues exist
- Significant pattern deviations without justification
- Tests fail or are missing

**NEEDS DISCUSSION** when:
- Spec is ambiguous and implementation chose an interpretation
- Trade-offs require product/team input
- Architectural decisions need validation

## Important Constraints

- **Be thorough** - Check every acceptance criterion, don't skip any
- **Be specific** - Include file paths and line numbers for all issues
- **Be pragmatic** - Focus on real issues, not stylistic nitpicks
- **Be constructive** - Provide actionable suggestions, not just criticism
- **Reference the spec** - Tie feedback back to spec requirements where relevant
- **Search for patterns** - Actually look for similar code before flagging pattern issues
- **Trust the spec** - If spec says X, implementation should do X

## Example Usage

```
/review-implementation
```
Reviews changes against the most recent or only spec in `specs/`.

```
/review-implementation batch-analysis
```
Reviews changes against `specs/batch-analysis-spec.md`.

```
/review-implementation specs/auth-feature-spec.md
```
Reviews changes against the specified spec file.
