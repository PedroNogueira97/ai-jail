# GIT_WORKFLOW.md

## Purpose

This document defines the default Git workflow for all projects in `/workspace`.

Project-specific rules may override this document.

---

## Branching

Unless otherwise specified:

- do not work directly on `main` or `master`
- create a task-focused branch
- use clear branch names

Recommended branch naming:

- `feature/<short-description>`
- `fix/<short-description>`
- `refactor/<short-description>`
- `chore/<short-description>`

Examples:

- `feature/user-auth`
- `fix/login-timeout`
- `refactor/api-client`

---

## Commit Discipline

Commits should be:

- small
- focused
- meaningful
- easy to review

Do not mix unrelated changes in the same commit.

Recommended style:

- `feat: add password reset request flow`
- `fix: prevent null crash in billing summary`
- `test: add regression coverage for token refresh`
- `refactor: simplify order status mapping`

---

## Before Commit

Before creating a commit, verify:

- relevant tests pass
- linting/type checks pass when applicable
- changed files are within task scope
- documentation is updated if required

---

## Pull Request Expectations

When preparing work for review, include:

- summary of the problem
- summary of the solution
- testing performed
- known limitations
- follow-up work if needed

---

## Safety Rules

Do not:

- force push shared branches unless explicitly instructed
- rewrite history on shared branches unless explicitly instructed
- commit secrets, credentials, or environment files
- include unrelated formatting-only changes in feature work

---

## Preferred Review Style

Optimize for reviewer clarity:

- small pull requests
- isolated concerns
- explicit test coverage
- clean commit history