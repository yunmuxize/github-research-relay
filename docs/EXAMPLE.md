# Example: one page through the Research Relay loop

This is a concrete walk through the smallest end-to-end cycle. Full rules: [`README.md`](../README.md); automation scope: [`docs/AUTOMATION_LEVELS.md`](AUTOMATION_LEVELS.md).

## 1. Controller creates an Issue

A planning agent (ChatGPT) writes a small, verifiable task as a GitHub Issue: a goal, a pinned base commit, exact commands, and pass/fail acceptance criteria. The Issue is the task contract. Only the Issue URL is passed to the worker.

## 2. Worker branches and implements

An execution agent (OpenCode or Codex) loads the `research-relay-worker` skill, reads the Issue, restates scope, and creates a unique `agent/issue-N-short-name` branch from the pinned revision. It does the smallest coherent slice — no scope creep — and keeps commands, configs, seeds, and exact commit SHAs.

## 3. Worker opens a PR with evidence

The worker writes `reports/issue-N.md` from the report template, commits source plus report, pushes the branch, and opens `gh pr create` with `Refs #N` in the body. The handoff is one line: `Issue URL | PR URL | commit SHA | pass/fail | blockers`. It does not merge or self-approve.

## 4. Controller reviews

The planning agent fetches the PR diff, linked Issue, and checks, then returns `ACCEPT`, `REWORK`, or `INSUFFICIENT EVIDENCE` with numbered, testable reasons. The user decides whether to merge; the controller issues the next task only when authorized.
