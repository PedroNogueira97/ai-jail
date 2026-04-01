# AGENT_WORKFLOW.md

## Purpose

This document defines the mandatory execution workflow for Gemini CLI when working on any project in `/workspace`.

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

Do not skip steps without a clear reason.

---

## Step 1: Understand

Before writing code:

- identify the target project
- read relevant project documentation
- inspect existing code, tests, and patterns
- identify constraints, dependencies, and risks

Do not begin implementation before understanding the current structure.

---

## Step 2: Plan

Before modifying files:

- summarize the task
- describe the intended approach
- identify affected files
- note assumptions or ambiguities

If the task is unclear, stop and ask for clarification.

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

## Behavioral Rules

Always:

- prefer small diffs
- preserve established project patterns
- be explicit about assumptions
- update docs when behavior changes

Never:

- start coding before defining expected behavior
- silently skip tests
- make broad refactors without justification
- claim validation that was not actually performed