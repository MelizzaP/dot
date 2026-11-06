---
name: elixir-pr-reviewer
description: Review Elixir pull requests for code quality, readability, Elixir/OTP best practices, style guide compliance, test coverage, and modern Ecto/Phoenix patterns. Use this skill when the user requests code review, PR analysis, or mentions reviewing code in Elixir projects like hatch-elixir or hatch-integrations. Focus on maintaining existing codebase patterns rather than introducing new ones.
---

# Elixir PR Reviewer

## Overview

Review Elixir pull requests comprehensively, focusing on code quality, Elixir/OTP best practices from "Elixir in Action", style guide compliance, behavior-based test coverage, and modern idiomatic Ecto/Phoenix standards. Ensure new code maintains existing patterns in the codebase rather than introducing inconsistencies.

## When to Use This Skill

Invoke this skill when:
- User asks to review code in Elixir projects (hatch-elixir, hatch-integrations, etc.)
- User mentions analyzing or reviewing pull requests
- User requests code quality assessment for Elixir code
- User asks to check code against style guides or best practices

## Review Workflow

Follow this systematic workflow when reviewing Elixir PRs:

### 1. Understand the Change Context

**First, gather context about the change:**

- If reviewing a GitHub PR, use `gh` commands to fetch PR information:
  ```bash
  gh pr view <pr-number>
  gh pr diff <pr-number>
  ```

- If reviewing local changes, use git commands:
  ```bash
  git diff main...HEAD
  git log main..HEAD --oneline
  ```

- Read the PR description or ask the user about:
  - What is the purpose of this change?
  - What files are being modified?
  - Are there any special considerations?

**Understand existing codebase patterns:**

- Before reviewing, scan existing code in the same module or context to understand established patterns
- Use `Grep` or `Glob` to find similar implementations in the codebase
- Look for existing test patterns, naming conventions, and architectural decisions
- Note any domain-specific patterns (e.g., how the codebase handles errors, structures contexts, or organizes tests)

**Load project-specific architecture rules:**

- Check for a project CLAUDE.md or architecture documentation
- For hatch-elixir: Read `references/hatch_architecture.md` for domain/UseCase conventions

### 2. Analyze Code Changes

**Review each changed file systematically:**

1. **Module organization** - Check against the style guide's module attribute ordering
2. **Function structure** - Verify proper function head usage, pattern matching, guards
3. **Naming conventions** - Ensure snake_case, CamelCase, and boolean function suffixes are correct
4. **Process design** - For GenServers, verify all callbacks are implemented, especially `handle_info/2`
5. **Error handling** - Check for proper "let it crash" philosophy, appropriate use of try/rescue
6. **Data structures** - Verify appropriate use of Maps, Lists, Structs, Keyword lists

**Load reference materials as needed:**

- For style questions: Read `references/elixir_style_guide.md`
- For OTP patterns: Read `references/elixir_otp_best_practices.md`
- For Ecto/Phoenix code: Read `references/ecto_phoenix_patterns.md`
- For testing questions: Read `references/testing_practices.md`

### 3. Check Style Guide Compliance

**Verify adherence to the Elixir style guide:**

- **Formatting**: Line length (98 chars), whitespace, indentation
- **Module structure**: Correct ordering of @moduledoc, use, import, alias, etc.
- **Naming**: snake_case for functions/variables, CamelCase for modules, ? suffix for booleans
- **Collections**: Proper keyword list and map syntax
- **Comments**: Proper placement and formatting
- **Type specs**: Correct @spec placement and formatting

**Use the style guide reference:**
```elixir
# Load the complete style guide
Read references/elixir_style_guide.md
```

### 4. Evaluate OTP and Elixir Best Practices

**Check for common OTP patterns and anti-patterns:**

- **GenServer design**: Interface separation, callback completeness, state management
- **Supervision trees**: Appropriate strategy, layered design, restart intensity
- **Concurrency**: Proper use of call vs cast, Task management, Agent usage
- **Error handling**: Let it crash philosophy, proper error propagation
- **Module design**: Single responsibility, clear public API, appropriate function length

**Use the OTP best practices reference:**
```elixir
# Load OTP patterns and principles
Read references/elixir_otp_best_practices.md
```

**Common anti-patterns to flag:**
- Over-using processes when not needed
- Catching all errors without good reason
- Blocking GenServer calls
- Process dictionary abuse
- Large message passing between processes
- Premature abstraction
- Missing backpressure handling

### 4b. Check Assertive Programming Patterns

**Load assertive programming reference:**
```elixir
Read references/assertive_elixir.md
```

**Check for defensive coding that masks bugs:**
- Nil checks on preloaded Ecto associations (if you preloaded it, assert on it)
- Unnecessary rescue clauses (especially rescue-and-return-nil)
- Unreachable code paths and dead pattern match arms
- Validation duplicated across multiple layers
- `if not` / `unless` where a positive assertion is clearer

### 4c. Check Database Operation Patterns

**Load database operations reference:**
```elixir
Read references/database_operations.md
```

**Check for inefficient or incorrect database usage:**
- `Enum.each/map` wrapping individual `Repo.insert/update/delete` calls (should batch)
- Manual foreign key joins where `Ecto.assoc/2` would work
- Missing `deleted_at` filters in query paths (when schema uses soft deletes)
- Import collisions between `Ecto.Query` and other modules

### 5. Review Ecto and Phoenix Patterns

**For code involving Ecto or Phoenix, verify:**

**Ecto patterns:**
- Schema design (UUIDs, Ecto.Enum, virtual fields, redaction)
- Changeset structure (separate changesets for different operations)
- Query organization (composable queries, N+1 prevention, preloading)
- Transaction usage (Ecto.Multi for complex operations)
- Proper context boundaries

**Phoenix patterns:**
- Thin controllers (business logic in contexts)
- Proper context design (domain-driven, single responsibility)
- LiveView best practices (streams, temporary assigns, event handling)
- Authentication and authorization patterns

**Use the Ecto/Phoenix reference:**
```elixir
# Load Ecto and Phoenix patterns
Read references/ecto_phoenix_patterns.md
```

### 5b. Review Security and API Contracts

**Load security review reference:**
```elixir
Read references/security_review.md
```

**Check for security issues:**
- Missing `additionalProperties: false` on request schemas
- JWT claim changes that break downstream consumers
- Secrets, tokens, or PII in log/telemetry output
- Auth checks happening too late in the pipeline (should be early)
- Feature flags controlling multiple independent failure domains with a single switch
- Soft delete operations that create irreversible state
- `String.to_atom/1` with external input

**Check API contract stability:**
- Do changes break existing consumers?
- Are OpenApiSpex plugs configured with `struct?: false, derive?: false`?
- Are import collisions handled with `:except`?

### 5c. Question Necessity

**Flag unnecessary code:**
- Wrappers that add no value ("why do we need this wrapper?")
- Premature abstractions for one-time operations
- Excessive comments where function names and types are self-documenting
- AI-generated boilerplate comments (obvious doc strings on obvious functions)
- Single-pipe chains (either use multiple pipes or call directly)
- Verbose patterns where capture syntax would suffice
- Dead code paths, unreachable pattern match arms

### 6. Assess Test Coverage

**Evaluate test quality and completeness:**

- **Coverage**: Are all new functions tested?
- **Behavior-based**: Tests focus on what code does, not how
- **Test organization**: Proper use of describe blocks, clear test names
- **Factory usage**: Appropriate use of ExMachina for test data
- **Async safety**: Tests marked async when safe
- **Edge cases**: Unhappy paths and boundary conditions covered
- **Integration**: Complex workflows have integration tests

**Check for testing anti-patterns:**
- Testing private functions directly
- Shared state between tests
- Brittle tests that break on refactoring
- Missing edge case tests
- Over-mocking
- Large setup blocks
- Unclear test descriptions

**Use the testing reference:**
```elixir
# Load testing best practices
Read references/testing_practices.md
```

### 7. Check Pattern Consistency

**This is critical: New code must maintain existing patterns.**

**Compare new code against existing patterns:**

1. **Find similar implementations** in the codebase:
   ```elixir
   # Search for similar modules, functions, or patterns
   Grep "pattern" path/to/relevant/code
   Glob "**/*similar_module*.ex"
   ```

2. **Check consistency:**
   - Does the new code follow the same error handling approach?
   - Are function names consistent with existing conventions?
   - Does the module structure match other modules in the same context?
   - Are similar operations implemented the same way?
   - Does testing follow established patterns?

3. **Flag inconsistencies:**
   - New pattern introduced without clear justification
   - Different error handling than rest of codebase
   - Naming that doesn't match existing conventions
   - Test organization that differs from established style

**Example patterns to check:**
- How does the codebase typically structure contexts?
- What's the established pattern for handling external API calls?
- How are errors typically returned (tuples, raises, etc.)?
- What's the test setup pattern in this area of the codebase?
- How are configurations typically accessed?

### 8. Provide Structured Feedback

**Organize findings into clear categories:**

#### ⚠️ Issues Found

**Critical Issues (Must Fix):**
- Security vulnerabilities
- Bugs or logical errors
- Violations of core OTP principles
- Missing required tests
- Breaking changes to public APIs
- Anti-patterns that will cause production issues

**Style & Convention Issues:**
- Style guide violations
- Naming inconsistencies
- Formatting issues
- Missing documentation
- Type spec issues

**Pattern Consistency Issues:**
- New patterns that differ from existing code
- Inconsistent error handling
- Different testing approaches
- Architectural deviations

**Suggestions (Optional Improvements):**
- Performance optimizations
- Readability improvements
- Additional test cases
- Refactoring opportunities
- Documentation enhancements

#### 📝 Code Examples

For each issue, provide:
1. **Location**: File path and line number (e.g., `lib/my_app/accounts.ex:45`)
2. **Current code**: Show the problematic code
3. **Explanation**: Why it's an issue and what guideline/principle it violates
4. **Suggested fix**: Show the corrected code with explanation
5. **Reference**: Link to relevant section in style guide or best practices

**Example format:**
```
⚠️ **GenServer missing handle_info callback**

Location: `lib/my_app/cache.ex:23`

Current code:
```elixir
def handle_cast({:put, key, value}, state) do
  {:noreply, Map.put(state, key, value)}
end
```

Issue: GenServer doesn't implement `handle_info/2`, which means unexpected messages will crash the process.

Reference: OTP Best Practices - "Always implement handle_info/2 to prevent crashes from unexpected messages"

Suggested fix:
```elixir
def handle_cast({:put, key, value}, state) do
  {:noreply, Map.put(state, key, value)}
end

def handle_info(_msg, state) do
  {:noreply, state}
end
```

#### ❓ Open Questions

Surface things the reviewer cannot determine from the code alone. These are questions the author needs to answer:
- "What consumes these events downstream?"
- "Are there existing instances where X already handles this?"
- "Should this configuration come from runtime config or compile-time?"
- "Does this need to deploy before/after another PR?"
- "What happens to existing data when this flag is toggled?"

This section is critical. A review that only renders verdicts and never admits uncertainty is hiding its blind spots.

#### 🎯 Summary

Provide a high-level summary:
- Major themes in the feedback
- Priority of changes needed
- Any blocking issues before merge

## Key Principles

**Maintain Existing Patterns:**
- The most important principle is consistency with the existing codebase
- Don't introduce new patterns without discussing with the team
- When in doubt, match what already exists

**Be Direct:**
- Lead with problems, not praise
- Explain the "why" behind each issue
- Provide concrete examples and alternatives
- Don't pad the review with compliments to soften criticism

**Question Necessity:**
- Ask "why does this exist?" for any code that adds complexity
- Flag wrappers, helpers, and abstractions that don't earn their weight
- AI-generated boilerplate comments are noise, not documentation

**Prioritize Issues:**
- Separate must-fix from nice-to-have
- Security and contract stability issues are always critical
- Assertive coding violations (silent bugs) outrank style issues

**Reference Standards:**
- Always cite specific guidelines when pointing out issues
- Use the reference materials to back up suggestions
- Point to examples in the codebase when available

## Resources

This skill includes comprehensive reference materials:

### references/hatch_architecture.md
Project-specific architectural conventions for hatch-elixir: UseCase pattern (`call/1` entry points), domain boundaries, schema layer rules, facade access, forbidden patterns (Helpers/Utils). **Load this first for any hatch-elixir review.**

### references/security_review.md
Security checklist: API schema hardening (`additionalProperties: false`), JWT/token patterns, log redaction, feature flag separation, soft delete safety, auth pipeline ordering.

### references/assertive_elixir.md
Concrete patterns for assertive Elixir: no defensive nil on preloaded assocs, no rescue-and-return-nil, unreachable code detection, validation layer discipline.

### references/database_operations.md
Database operation patterns: batch operations (`update_all`, `insert_all`), `Ecto.assoc/2` usage, soft delete filtering, import collision avoidance.

### references/elixir_style_guide.md
The community Elixir style guide covering formatting, naming, module structure, and code organization.

### references/elixir_otp_best_practices.md
Key patterns and principles from "Elixir in Action" covering GenServer design, supervision trees, concurrency patterns, error handling, and common anti-patterns.

### references/ecto_phoenix_patterns.md
Modern patterns for Ecto and Phoenix including schema design, changesets, queries, transactions, context design, LiveView patterns, and testing.

### references/testing_practices.md
Comprehensive testing guidance covering behavior-based testing, ExUnit fundamentals, context testing, controller testing, LiveView testing, mocking, and test data management.

**How to use references:**
- Load references on-demand when specific questions arise
- Don't load all references at once; be selective based on the code being reviewed
- For hatch-elixir reviews, always load `hatch_architecture.md` and `security_review.md`
- Reference specific sections when providing feedback
