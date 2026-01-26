---
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - AskUserQuestion
  - Task
  - mcp__sentient-agi-reasoning__code-reasoning
---

# Implementation Spec Generator

Transforms a brainstorming document into a detailed implementation specification with atomic, actionable tasks.

## Input

$ARGUMENTS - Either:
- A path to a brainstorming document (e.g., `brainstorming/feature-name.md`)
- A feature slug (e.g., `feature-name`) - will look in `brainstorming/` directory

## Instructions

### Phase 1: Load and Parse Brainstorming Document

**Locate the document:**
- If full path provided, read it directly
- If slug provided, look for `brainstorming/<slug>.md`
- If file not found, list available brainstorming docs and ask user to select one

**Extract key information:**
- Problem statement and goals
- Proposed solution and user journey
- Architecture (data model, APIs, integrations)
- Edge cases and decisions
- Security considerations
- Open questions

### Phase 2: Codebase Analysis

**Before writing any spec, understand the existing codebase:**

1. **Identify relevant areas** based on the feature:
   - Search for similar patterns already implemented
   - Find the modules/directories this feature will touch
   - Identify existing abstractions to leverage

2. **Document technical constraints:**
   - What frameworks/libraries are in use?
   - What patterns does this codebase follow?
   - Are there existing conventions for similar features?

3. **Map dependencies:**
   - What existing code will this feature depend on?
   - What existing code might need modification?

### Phase 3: Clarify Open Questions

**If the brainstorming doc has unresolved questions:**
- Use AskUserQuestion to resolve any that are critical for implementation
- Mark questions that can be deferred to implementation time
- Document assumptions made for questions that can't be answered now

### Phase 4: Break Down into Atomic Tasks

**Rules for atomic tasks:**
- Each task should be completable in a single PR (ideally 1-4 hours of work)
- Each task should be independently testable
- Each task should have clear acceptance criteria
- Tasks should have minimal dependencies on other tasks
- Tasks should be orderable (what must come before what)

**Task categories to consider:**
1. **Data/Schema tasks** - migrations, models, types
2. **Core logic tasks** - business logic, services, domain code
3. **API tasks** - endpoints, request/response handling
4. **Integration tasks** - connecting to existing systems
5. **UI tasks** - components, pages, user interactions (if applicable)
6. **Testing tasks** - unit tests, integration tests, e2e tests
7. **Infrastructure tasks** - config, deployment, monitoring

### Phase 5: Write Detailed Specs

For each atomic task, write a complete specification:

```markdown
### Task [N]: [Descriptive Name]

**Summary:** One sentence describing what this task accomplishes.

**Dependencies:** [List task numbers that must be completed first, or "None"]

**Files to create/modify:**
- `path/to/file.ex` - [brief description of changes]
- `path/to/other_file.ex` - [brief description of changes]

**Detailed specification:**

[Detailed description of what to implement. Include:]
- Specific functions/modules to create
- Data structures and their fields
- API contracts (inputs, outputs, errors)
- Business logic rules
- Error handling requirements

**Edge cases to handle:**
- [Edge case 1 from brainstorming doc]
- [Edge case 2]

**Acceptance criteria:**
- [ ] [Specific, verifiable criterion 1]
- [ ] [Specific, verifiable criterion 2]
- [ ] [Test coverage criterion]

**Testing requirements:**
- Unit tests for: [specific functions/modules]
- Integration tests for: [specific flows]

**Notes/Warnings:**
- [Any gotchas, performance considerations, or things to watch out for]
```

### Phase 6: Generate Implementation Spec Document

**Create the output directory:**
```bash
mkdir -p specs
```

**Write the document** to `specs/<feature-slug>-spec.md`:

```markdown
# Implementation Spec: [Feature Name]

> Generated from: `brainstorming/<slug>.md`
> Generated on: [date]

## Overview

[1-2 paragraph summary of what we're building and why]

## Technical Context

### Relevant Codebase Areas
- `path/to/module/` - [what it does, why it's relevant]
- `path/to/other/` - [what it does, why it's relevant]

### Existing Patterns to Follow
- [Pattern 1]: [where it's used, why we should follow it]
- [Pattern 2]: [where it's used, why we should follow it]

### Key Dependencies
- [Existing module/service 1]: [how we'll use it]
- [Existing module/service 2]: [how we'll use it]

## Implementation Tasks

### Summary

| Task | Name | Dependencies | Estimated Complexity |
|------|------|--------------|---------------------|
| 1 | [Name] | None | Low/Medium/High |
| 2 | [Name] | 1 | Low/Medium/High |
| ... | ... | ... | ... |

### Critical Path
[Visual or textual representation of task dependencies - what can be parallelized, what must be sequential]

---

### Task 1: [Name]
[Full task spec as defined above]

---

### Task 2: [Name]
[Full task spec as defined above]

---

[... more tasks ...]

## Testing Strategy

### Unit Testing
- [What to unit test and why]

### Integration Testing
- [What integration tests are needed]

### Manual Testing Checklist
- [ ] [Manual test scenario 1]
- [ ] [Manual test scenario 2]

## Rollout Considerations

### Feature Flags
- [Any feature flags needed? What behavior behind each?]

### Migration Strategy
- [Any data migrations? How to handle existing data?]

### Rollback Plan
- [How to roll back if something goes wrong]

## Open Items

- [ ] [Any remaining questions or decisions]
- [ ] [Things to verify during implementation]

---

*This spec is implementation-ready. Each task is designed to be picked up independently (respecting dependencies) and completed in a single PR.*
```

## Quality Checklist

Before finalizing the spec, verify:

- [ ] Every task has clear acceptance criteria
- [ ] Every task specifies which files to modify
- [ ] Dependencies between tasks are explicit
- [ ] Edge cases from brainstorming are assigned to specific tasks
- [ ] Security considerations are addressed in relevant tasks
- [ ] Testing requirements are clear for each task
- [ ] The critical path is identified
- [ ] Tasks are small enough for single PRs
- [ ] Existing codebase patterns are referenced

## Important Constraints

- **Be specific** - vague specs lead to implementation confusion
- **Reference actual code** - don't write specs in a vacuum, point to real files and patterns
- **Keep tasks atomic** - resist the urge to bundle related work
- **Make dependencies explicit** - no hidden assumptions about task ordering
- **Include the "why"** - link back to brainstorming decisions where relevant
- **Don't over-specify** - leave room for implementation judgment on minor details

## Example Usage

```
/write-spec batch-conversation-analysis
```

This would:
1. Read `brainstorming/batch-conversation-analysis.md`
2. Analyze relevant parts of the codebase
3. Break the feature into 5-15 atomic tasks
4. Write detailed specs for each task
5. Output to `specs/batch-conversation-analysis-spec.md`
