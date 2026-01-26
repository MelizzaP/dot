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

# Feature Brainstorming Partner

An iterative brainstorming session that refines a vague feature idea into a comprehensive architectural document through questioning, devil's advocacy, and edge case exploration.

## Input

$ARGUMENTS - Either a Linear ticket ID (e.g., AI-1234) or a feature description string

## Instructions

### Phase 1: Initial Context Gathering

**If the input looks like a ticket ID** (pattern: letters-numbers like "AI-1234", "COMMS-567"):
- Use the Linear MCP tool to fetch the ticket details
- Extract: title, description, acceptance criteria, any linked tickets
- Use this as the starting point for brainstorming

**If the input is a feature description**:
- Use the description as-is for the starting point

### Phase 2: Iterative Refinement (The Core Loop)

This is NOT a one-and-done questionnaire. You are a thinking partner who keeps probing until the feature is crystal clear. Use AskUserQuestion repeatedly to dig deeper.

**Start with the problem space:**
- What specific problem are we solving?
- Who exactly experiences this problem? (Be specific - not "users" but which users, in what context)
- Why does this matter now? What's the cost of not solving it?
- How are users currently working around this problem?

**Challenge and push back:**
- Play devil's advocate - question whether this feature is even needed
- Ask "what if we did nothing?" and make them justify the investment
- Suggest simpler alternatives and see if they'd work
- Push back on scope creep - ask "is that really part of this feature?"
- Question assumptions - "you said X, but have you validated that?"

**Explore the happy path:**
- Walk through the ideal user journey step by step
- What does success look like?
- How will users discover this feature?
- What's the simplest possible version that delivers value?

**Dig into edge cases (surface at least 5):**
- What happens when things go wrong?
- What if the user has no data? Too much data?
- What about concurrent users/operations?
- What about permissions/authorization edge cases?
- What if external dependencies are unavailable?
- What about backward compatibility?
- What about internationalization/localization?
- What about mobile vs desktop?

**Probe integration points:**
- What existing systems does this touch?
- What APIs need to change?
- What data needs to flow where?
- What are the system boundaries?

**Explore failure modes:**
- What can go wrong?
- How do we recover from failures?
- What's the blast radius of a bug here?
- What monitoring/alerting do we need?

**Security considerations:**
- What data is involved? PII? Sensitive?
- Who should have access? Who shouldn't?
- What's the threat model?
- What could an attacker do with this feature?

**Define scope boundaries:**
- What is explicitly NOT part of this feature?
- What's being deferred to future work?
- What adjacent features are we NOT building?

### Phase 3: Synthesis Check

Before generating the document, do a final check:
- Have you asked at least 3 rounds of questions?
- Have you identified at least 5 edge cases?
- Have you pushed back on at least 2 assumptions?
- Have you explored at least one simpler alternative?
- Are the scope boundaries clear?

If not, go back to Phase 2 and keep probing.

### Phase 4: Document Generation

**Use extended thinking** to synthesize everything discussed into a comprehensive document.

**Create the output directory** if it doesn't exist:
```bash
mkdir -p brainstorming
```

**Generate a slug** from the feature name (lowercase, hyphens, no special chars).

**Write the document** to `brainstorming/<feature-slug>.md` with this structure:

```markdown
# Feature: [Feature Name]

> Generated from brainstorming session on [date]
> Source: [ticket ID if applicable]

## Problem Statement

[Clear articulation of the problem being solved]

### Who experiences this?
[Specific user personas and contexts]

### Why now?
[Business/user motivation for solving this]

### Current workarounds
[How users cope today]

## Goals

- [Specific, measurable goal 1]
- [Specific, measurable goal 2]

## Non-Goals (Explicit Scope Boundaries)

- [Thing we are NOT doing 1]
- [Thing we are NOT doing 2]
- [Adjacent feature we're explicitly deferring]

## Proposed Solution

### Conceptual Overview
[High-level description of the solution - the "what", not the "how"]

### User Journey
[Step-by-step happy path from the user's perspective]

## Architecture

### Data Model
[Entities, relationships, key attributes - conceptual, not schema definitions]

### System Boundaries
[What systems are involved, where does this feature live]

### API Surface
[What endpoints/interfaces are needed - conceptual, not specifications]

### Integration Points
[How this connects to existing systems]

## Edge Cases & Decisions

| Edge Case | Decision | Rationale |
|-----------|----------|-----------|
| [Case 1] | [What we'll do] | [Why] |
| [Case 2] | [What we'll do] | [Why] |
| ... | ... | ... |

## Security Considerations

- [Data sensitivity assessment]
- [Access control requirements]
- [Threat model considerations]
- [Compliance implications if any]

## Failure Modes & Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |
| [Risk 2] | Low/Med/High | Low/Med/High | [Strategy] |

## Open Questions

- [ ] [Unresolved question 1]
- [ ] [Unresolved question 2]

## Alternatives Considered

### [Alternative 1 Name]
**Description:** [What this approach would look like]
**Rejected because:** [Why we're not doing this]

### [Alternative 2 Name]
**Description:** [What this approach would look like]
**Rejected because:** [Why we're not doing this]

---

*This document captures the "what" and "why" of the feature. It is intended as input for implementation planning, not as a build guide itself.*
```

## Important Constraints

- **This is NOT an implementation plan** - no phases, sprints, steps, or how-to-build-it details
- **Focus on "what" and "why"** - leave the "how" for the implementation spec
- **Be a skeptic** - your job is to poke holes, not be a yes-man
- **Keep iterating** - don't rush to document generation
- **Capture the conversation** - the document should reflect the refinement that happened

## Example Session Flow

1. User runs `/brainstorm AI-1234`
2. You fetch the ticket, summarize it, ask first round of clarifying questions
3. User answers, you ask follow-up questions probing deeper
4. You push back: "Do we really need X? What if we just did Y instead?"
5. User defends or adjusts scope
6. You surface edge cases: "What happens when Z?"
7. User provides decisions on edge cases
8. You probe security: "Who should NOT have access to this?"
9. More back and forth...
10. You confirm readiness and generate the document
11. Document saved to `brainstorming/feature-name.md`

## Error Handling

- If Linear MCP unavailable or ticket not found, ask user to provide the feature description directly
- If user wants to skip questions, gently push back - the value is in the refinement process
- If brainstorming/ directory can't be created, save to current directory with clear filename
