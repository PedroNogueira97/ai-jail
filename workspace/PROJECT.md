# PROJECT.md

## Purpose

This document defines how projects inside `/workspace` should be interpreted and navigated.

Each project folder is a self-contained unit with its own requirements, constraints, and documentation.

---

## Standard Project Structure

Each project should include documentation that helps define:

- business intent
- product requirements
- architecture
- technical constraints
- workflows
- open tasks

Common files may include:

- `PRD.md`
- `ARCHITECTURE.md`
- `TASKS.md`
- `DECISIONS.md`
- `GEMINI.local.md`

Not every project needs every file, but each project should have enough documentation to define expected behavior.

---

## How to Read a Project

Before making changes, review in this order when available:

1. `GEMINI.local.md`
2. `PRD.md`
3. `ARCHITECTURE.md`
4. `TASKS.md`
5. relevant source code and tests

Use the documentation as the source of truth unless the user explicitly overrides it.

---

## Project-Specific Overrides

Projects may define additional rules such as:

- approved tech stack
- coding patterns
- naming conventions
- testing requirements
- architecture constraints
- delivery expectations

These project-level instructions override root-level defaults.

---

## Documentation Discipline

When making meaningful changes:

- update project documentation if behavior or architecture changes
- keep docs aligned with implementation
- avoid stale documentation

---

## Scope Control

Work only on the active project.

Do not modify sibling projects unless explicitly instructed, even if they appear related.

---

## Preferred Files Per Project

Recommended minimum:

- `PRD.md`
- `ARCHITECTURE.md`
- `TASKS.md`

Recommended optional:

- `DECISIONS.md`
- `GEMINI.local.md`
- `TESTING.md`