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
# Review Elixir PR

Follow the `Instructions` below to perform a comprehensive code review of an Elixir pull request, focusing on code quality, readability, maintainability, Elixir/OTP best practices, Phoenix/Ecto patterns, and style guide compliance.

## Variables

branch_name: $1 (required - the git branch to review)
pr_number: $2 (optional - the GitHub PR number for additional context)

## Instructions

1. **Setup & Context**
   - If `branch_name` is provided, run `git fetch origin` and `git checkout <branch_name>` to switch to the branch
   - If `pr_number` is provided, fetch PR details using `gh pr view <pr_number>`
   - Run `git diff origin/main...HEAD` to see all changes in the branch
   - Run `git log origin/main..HEAD --oneline` to see commit history
   - **CRITICAL**: Read the actual changed files to get exact line numbers and code context

2. **Deep Code Analysis - REQUIRED**
   - **You MUST read the actual source files** that were changed using the Read tool
   - For EVERY issue found, you MUST provide:
     - Exact file path (e.g., `lib/my_app/services/email.ex`)
     - Exact line number(s) where the issue occurs
     - The actual problematic code snippet from the file
     - Detailed explanation of what's wrong and why
     - A concrete code example showing the fix
   - Do NOT provide generic feedback without specific file locations and code examples

3. **Invoke Elixir PR Reviewer Skill**
   - Use the `elixir-pr-reviewer` skill to perform a comprehensive code review
   - The skill will analyze:
     - Code quality and readability
     - Maintainability and testability
     - Elixir/OTP best practices and idioms
     - Phoenix framework patterns (if applicable)
     - Ecto query and schema patterns (if applicable)
     - Style guide compliance (Elixir formatter)
     - Pattern matching and functional programming best practices
     - Supervision tree design
     - Test coverage and quality

4. **Review Focus Areas**
   - **Architecture**: UseCase pattern compliance (`call/1` entry points), domain boundaries, facade access, no Helpers/Utils modules
   - **Assertive Code**: No defensive nil on preloaded assocs, no unnecessary rescue, no unreachable code, validation at correct layer
   - **Security**: `additionalProperties: false` on request schemas, JWT claim stability, log redaction, auth pipeline ordering
   - **Database Ops**: Batch operations over loops (`update_all`/`insert_all`), `Ecto.assoc/2`, soft delete filtering, import collisions
   - **Necessity**: Flag wrappers that add no value, premature abstractions, AI-generated boilerplate comments, dead code
   - **Pattern Consistency**: Uses existing codebase patterns, no new patterns without justification
   - **Readability**: Clear function names, pattern matching, pipeline operators (no single-pipe chains)
   - **OTP Principles**: GenServer completeness, supervision strategy, error propagation

5. **Testing & Validation**
   - Run tests: `mix test`
   - Check code formatting: `mix format --check-formatted`
   - Run static analysis: `mix credo` (if configured)
   - Run dialyzer: `mix dialyzer` (if configured)
   - Check test coverage if configured: `mix test --cover`

## Output Structure

Return a well-formatted markdown report with the following structure:

```markdown
# PR Review: {branch_name}

**PR Number:** {pr_number or "N/A"}
**Status:** {✅ PASS or ❌ FAIL (based on blocking issues)}

## Summary

{2-3 sentences: what the PR does and the most important problems found}

## Test Results

- **Tests:** {PASS or FAIL or SKIPPED}
- **Format Check:** {PASS or FAIL or SKIPPED}
- **Credo:** {PASS or FAIL or SKIPPED}
- **Dialyzer:** {PASS or FAIL or SKIPPED}

## Issues Found

### 🔴 BLOCKER: {Issue Title}
**File:** `{file_path}:{line_number}`
**Category:** {category}

**Current Code:**
```elixir
{actual problematic code from the file}
```

**Problem:**
{Detailed explanation of what's wrong and why it's a problem}

**Impact:**
{Explain the consequences of not fixing this - performance, reliability, maintainability}

**Suggested Fix:**
```elixir
{concrete code example showing how to fix it}
```

**How to Fix:**
1. {step 1}
2. {step 2}
3. {step 3}

---

### 🟠 MAJOR: {Issue Title}
{same structure as above}

---

### 🟡 MINOR: {Issue Title}
{same structure as above}

---

### ⚪ NITPICK: {Issue Title}
{same structure as above}

---

## Open Questions

Questions the reviewer cannot answer from code alone. The author must address these:

- {question about downstream consumers, deployment order, data impact, etc.}
- {question about necessity of a pattern or wrapper}
- ...

## Summary

**Total Issues:** {count} | Blockers: {count} | Major: {count} | Minor: {count}
```

## Severity Definitions

- **blocker**: Critical issues that prevent merging (broken functionality, test failures, supervision tree issues)
- **major**: Important issues that should be fixed before merging (maintainability problems, missing tests, inefficient Ecto queries)
- **minor**: Issues that should be addressed but don't block merging (minor code smell, missing typespecs)
- **nitpick**: Style or preference issues (formatting, naming conventions, documentation)

## Elixir-Specific Considerations

- **Architecture**: UseCase `call/1` pattern, domain boundaries, facade access, no Helpers/Utils
- **Assertive Code**: No defensive nil on preloaded assocs, no rescue-and-return-nil, crash loud over silent bug
- **Security**: `additionalProperties: false`, JWT claim stability, log redaction, auth ordering
- **Database**: Batch ops (`update_all`/`insert_all`), `Ecto.assoc/2`, soft delete filters
- **Pattern Matching**: Proper use throughout, especially in function heads
- **Error Handling**: `{:ok, result}` / `{:error, reason}` tuples, validation at correct layer
- **Pipeline Operator**: Appropriate use of `|>`, no single-pipe chains
- **Ecto**: N+1 prevention, preloads, efficient changesets, import collision avoidance
- **Necessity**: Flag wrappers, premature abstractions, AI-generated comments, dead code

## Critical Requirements

- **MANDATORY**: Every issue MUST include exact file path and line number
- **MANDATORY**: Every issue MUST include the actual problematic code snippet
- **MANDATORY**: Every issue MUST include a concrete fix with code example
- **MANDATORY**: Read the actual files to get real code, not just diffs
- Do NOT provide vague or generic feedback
- Do NOT skip line numbers or code examples
- Focus on actionable, copy-paste ready suggestions
- Consider the broader codebase context and existing patterns
- Prioritize issues based on actual impact to users and maintainers
- Be thorough, specific, and constructive in feedback
- Consider Elixir community conventions and best practices

## Example Issue Format

Good example (Ecto):

```markdown
### 🟠 MAJOR: N+1 Query Problem in get_users_with_posts
**File:** `lib/my_app/accounts/user.ex:67`
**Category:** ecto

**Current Code:**
```elixir
def get_users_with_posts do
  users = Repo.all(User)
  Enum.map(users, fn user ->
    Map.put(user, :posts, Repo.all(from p in Post, where: p.user_id == ^user.id))
  end)
end
```

**Problem:**
N+1 query problem - fetching posts separately for each user results in N+1 database queries (1 query for users + 1 query per user for their posts). With 100 users, this creates 101 separate database queries.

**Impact:**
Severe performance degradation with large datasets. Response time increases linearly with the number of users. Under high load, this can lead to database connection pool exhaustion and application timeouts.

**Suggested Fix:**
```elixir
def get_users_with_posts do
  User
  |> Repo.all()
  |> Repo.preload(:posts)
end
```

**How to Fix:**
1. Remove the `Enum.map` and manual query loop
2. Use `Repo.preload(:posts)` to fetch all posts in a single JOIN query
3. Ensure the `:posts` association is properly defined in the User schema
4. This reduces 101 queries to just 1 or 2 efficient queries

---
```

Another good example (Phoenix):

```markdown
### 🟠 MAJOR: Business Logic in Controller
**File:** `lib/my_app_web/controllers/user_controller.ex:23`
**Category:** phoenix

**Current Code:**
```elixir
def create(conn, %{"user" => user_params}) do
  user = Repo.insert!(%User{email: user_params["email"], name: user_params["name"]})
  render(conn, :show, user: user)
end
```

**Problem:**
Business logic in controller - direct Repo access and manual struct creation violates the Phoenix context pattern. There's no validation or error handling, and the controller is doing too much.

**Impact:**
Violates separation of concerns, makes testing difficult, bypasses validation completely, and has no error handling for invalid data or database errors. The application will crash on invalid input.

**Suggested Fix:**
```elixir
def create(conn, %{"user" => user_params}) do
  case Accounts.create_user(user_params) do
    {:ok, user} ->
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render(:error, changeset: changeset)
  end
end
```

**How to Fix:**
1. Move Repo logic to the Accounts context module
2. Create `Accounts.create_user/1` function with changeset validation
3. Handle both success `{:ok, user}` and error `{:error, changeset}` cases with pattern matching
4. Use proper HTTP status codes (201 for created, 422 for validation errors)
5. Keep the controller thin - it should only handle HTTP concerns, not business logic

---
```
