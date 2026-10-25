# Research Relay: One Real Round Trip

## Roles

Four actors cooperate across one repository:

- **Controller (ChatGPT)** — plans research, writes a task contract, and reviews the result.
- **Worker (OpenCode)** — picks exactly one ready task, runs it on an isolated branch, and submits evidence.
- **GitHub (task/evidence ledger)** — Issues and PRs are the durable message bus between the two agents.
- **User (final decision)** — approves merges, asks for review, and never delegates irreversible actions.

See [`../README.md`](../README.md) for the framework overview and [`AUTOMATION_LEVELS.md`](AUTOMATION_LEVELS.md) for what is automatable today.

## End-to-end walkthrough

1. The Controller opens an Issue labeled `relay:ready` with a pinned base commit and acceptance checks.
2. The User tells the Worker `接一轮新任务`. On hosts with another orchestrator, the User may instead need to explicitly load the `research-relay-worker` skill before that phrase routes.
3. The Worker claims the lowest-numbered ready Issue via the fixed-name lock ref, creates branch `agent/issue-N-...` at the pinned commit, makes the smallest coherent change, and opens a PR with `Refs #N`.
4. The User returns to the Controller and says `验收一下结果`, sharing the PR URL.
5. The Controller either accepts (Issue → `relay:done`) or posts actionable rework (Issue → `relay:ready` with a new attempt marker) via GitHub.

## Verification checklist

- Changed files (only those allowed by the Issue scope).
- Exact head commit SHA of the PR.
- Checks actually performed, with real command output.
- Failures or `UNTESTED` items; never claim a check that was not run.

## Limitations

- GitHub does not automatically wake a ChatGPT browser conversation when a PR arrives; the User must return to chat to start review.
- PR merge or deployment requires explicit User approval; the Worker never self-merges or auto-deploys.
