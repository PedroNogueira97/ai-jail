# AGENT.local.md

## Purpose

This file defines project-specific instructions that override global workspace defaults.
Fill in the sections below according to this project's needs.

---

## Project Overview

<!-- Brief description of what this project is and what it does -->

---

## Tech Stack

<!-- List the approved technologies, frameworks, and tools for this project -->

---

## Architecture Notes

<!-- Key architectural decisions or constraints specific to this project -->

---

## Coding Conventions

<!-- Naming conventions, folder structure rules, patterns to follow or avoid -->

---

## Protected Areas

<!-- Files, modules, or features that must NOT be modified without explicit instruction -->

**Do not touch:**
- <!-- example: src/auth/ — authentication is complete and stable -->
- <!-- example: database/migrations/ — never modify existing migrations -->

---

## Testing Notes

<!-- Project-specific testing setup, frameworks used, how to run tests -->

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

---

## Session Startup Checklist

At the start of every session:

1. Read this file
2. Read `SESSION_LOG.md` (last 2 entries)
3. Read `TASKS.md`
4. Confirm current status to the user before any action

---

## Additional Notes

<!-- Anything else the agent should know that does not fit the sections above -->