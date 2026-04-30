# AGENT_WORKFLOW.md

## Purpose

This document defines the mandatory execution workflow for the CLI Agent when working on any project in `/workspace`.

This workflow must be followed unless a project-specific file explicitly overrides it.

---

## Default Execution Model

The default workflow is:

1. Understand
2. Plan
3. Write tests first
4. Implement
5. Validate
6. Summarize
7. Update SESSION_LOG.md

Do not skip steps without a clear reason.

---

## Step 1: Understand

Before writing code:

- identify the target project
- read relevant project documentation
- inspect existing code, tests, and patterns
- identify constraints, dependencies, and risks
- read `SESSION_LOG.md` (last 2 entries) for context from previous sessions

Do not begin implementation before understanding the current structure.

---

## Step 2: Plan

Before modifying any file:

- summarize the task
- describe the intended approach
- **list every file that will be modified**
- **list every file that must not be touched**
- note assumptions or ambiguities
- **wait for human confirmation before proceeding**

If the task is unclear, stop and ask for clarification.

This step is a hard gate. Do not proceed without explicit confirmation.

---

## Step 3: Write Tests First

Test-first development is mandatory by default.

For every feature, fix, or behavior change:

- write a failing test first when feasible
- define expected behavior through tests before implementation
- use the project's existing testing style and conventions
- add regression tests for bugs

If a test cannot be written first, explain why before proceeding.

Examples of valid reasons:

- no test framework exists yet
- the task is purely exploratory
- the code is infrastructure-only and requires a different validation method

Even in these cases, validation must still be defined before implementation.

---

## Step 4: Implement

After tests define the expected behavior:

- implement the minimum change required to make tests pass
- preserve project conventions
- keep changes narrow and focused
- avoid unrelated cleanup unless necessary
- only touch files listed and confirmed in Step 2

---

## Step 5: Validate

Before considering the task complete:

- run relevant tests
- verify new tests pass
- verify existing impacted tests still pass
- perform linting/type checks when appropriate
- confirm no obvious regressions

If validation cannot be completed, state what remains unverified.

---

## Step 6: Summarize

At the end of the task, provide:

- what was changed
- why it was changed
- what tests were added or updated
- how the work was validated
- any follow-up concerns or recommendations

---

## Step 7: Update SESSION_LOG.md

After every session, when the human signals completion (e.g. "stop here", "that's enough", "done for now"):

Append a new entry to the project's `SESSION_LOG.md` using this exact template:

```markdown
---

## [YYYY-MM-DD] — [AGENT NAME]

**Session scope:** what was requested

**What was done:**
- item 1
- item 2

**Decisions made:**
- why X was done this way (critical context for the next agent)

**Files modified:**
- path/to/file.ts
- path/to/other.ts

**Session status:** what is pending / what is the next step
```

If the session ends abruptly without a signal, still write the log entry.

---

## TASKS.md Protocol

When starting any feature or task:

1. Read `SPEC.md` if it is a specific feature, or `PRD.md` if starting from scratch
2. Fill `TASKS.md` with atomic tasks (1 task = 1 file or 1 function)
3. Wait for human approval before executing
4. Update task status as work progresses:
   - `[ ]` pending
   - `[~]` in progress
   - `[x]` completed
   - `[!]` blocked — reason: ...

### Example of a well-formed TASKS.md entry

```markdown
## Feature: dark mode — 2025-01-15

- [x] Create src/styles/theme.ts with color tokens
- [x] Create ThemeToggle.tsx component
- [~] Integrate ThemeContext into _app.tsx
- [ ] Persist preference in localStorage
- [!] SSR test — blocked: hydration conflict, needs investigation
```

---

## Behavioral Rules

Always:

- prefer small diffs
- preserve established project patterns
- be explicit about assumptions
- update docs when behavior changes
- confirm file list before touching anything

Never:

- start coding before defining expected behavior
- silently skip tests
- make broad refactors without justification
- claim validation that was not actually performed
- modify files outside the confirmed scope