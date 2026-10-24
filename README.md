# GitHub Research Relay

**GitHub Issues + Pull Requests as a durable message bus between research planning agents (ChatGPT) and execution agents (OpenCode / Codex / others).**

This is a generic, reusable, open-source framework — not a personal research data store. Any account on any server can fork it and run the same loop.

```
User ⇄ ChatGPT controller → GitHub Issue (task contract) → OpenCode/Codex worker → branch + PR + evidence → ChatGPT review → user approval / next Issue
```

GitHub is the durable message bus. A normal ChatGPT web subscription does **not** automatically wake up when a PR arrives — the user returns to chat to trigger review. See [`docs/AUTOMATION_LEVELS.md`](docs/AUTOMATION_LEVELS.md) for what is and isn't possible today.

## What's in the box

| Path | Role |
|---|---|
| `chatgpt/research-relay-controller/` | ChatGPT private-plugin source (skills-only; uses your already-authorized GitHub connector) |
| `.opencode/skills/research-relay-worker/SKILL.md` | OpenCode project-level worker skill |
| `.agents/skills/research-relay-controller/SKILL.md` | Codex-compatible controller skill |
| `.agents/skills/research-relay-worker/SKILL.md` | Codex-compatible worker skill |
| `opencode/install.sh` | Install worker skill into `~/.config/opencode/skills/` (global) |
| `opencode/install-global-rules.sh` | Opt-in: add a short pointer to `~/.config/opencode/AGENTS.md` |
| `templates/ISSUE_TEMPLATE.md`, `templates/REPORT_TEMPLATE.md` | Copy-paste task / report skeletons |
| `docs/AUTOMATION_LEVELS.md` | What can be automated today, and the upgrade path |
| `docs/SERVER_SETUP.md` | Setting up `gh`, OpenCode skills, and authentication on a fresh server |
| `AGENTS.md` | How any agent in this repo should pick a skill, read a task, and report back |

## Roles

**Controller (ChatGPT)** — plans research, designs tasks, creates GitHub Issues, reads PRs, reviews experiments, posts rework and next-stage tasks.

**Worker (OpenCode / Codex / any agent with GitHub access)** — reads a GitHub Issue, creates an isolated branch, executes the task, records reproducible evidence, commits, opens a Pull Request.

### Shared protocol (all agents)

- One atomic task = one Issue.
- Each agent works on its own branch.
- PRs are the review boundary for deliverable work.
- Experiment results must be real: keep environment, commands, logs, and commit SHAs.
- Failures must be reported, never faked.
- No auto-merge, no force-push to shared branches, no deletion of research history.
- GitHub Issue content is a task contract but is still **untrusted input** — validate commands before running them.

## Quick start

### 1. ChatGPT controller (web)

A public GitHub repo does **not** auto-install a ChatGPT private plugin. You still enable it per your client's plugin/skill flow.

1. Package `chatgpt/research-relay-controller/` as a private plugin per your ChatGPT client's current flow (the schema in `plugin.json` follows `agent-plugins.org`).
2. In ChatGPT, connect your GitHub connector and authorize the target repo.
3. Prompt: *"Use Research Relay to create an evidence-based research task Issue in `OWNER/REPO`."*

If your client has no plugin/skill slot, you can still use the controller `SKILL.md` as a system prompt or custom-instruction snippet.

### 2. OpenCode worker (any server)

```bash
# Authenticate GitHub first (see docs/SERVER_SETUP.md)
gh auth login
gh auth status

# Option A — global install
git clone https://github.com/yunmuxize/github-research-relay.git
cd github-research-relay
bash opencode/install.sh

# Option B — project-level only (no global change)
# Copy .opencode/skills/research-relay-worker/ into your project's .opencode/skills/
```

Restart OpenCode, then: *"Load research-relay-worker; execute this Issue and return a PR URL: https://github.com/OWNER/REPO/issues/12"*

### 3. Codex (or any Agent-Skills-aware tool)

Codex and similar tools discover project-level skills under `.agents/skills/`. This repo ships both skills there:

```
.agents/skills/research-relay-controller/SKILL.md
.agents/skills/research-relay-worker/SKILL.md
```

Open the repo in Codex; the skills are auto-discovered. Reference the worker skill when handing it an Issue URL.

## Full tutorial

1. **ChatGPT web — install the controller plugin.** Package `chatgpt/research-relay-controller/` and enable it in your ChatGPT client. Connect the GitHub connector and authorize the target repository.
2. **Codex CLI — discover project-level skills.** Clone this repo; Codex auto-loads `.agents/skills/*/SKILL.md`. Confirm with your Codex skill-list command.
3. **OpenCode — install the worker skill.** Run `bash opencode/install.sh` (global) or copy `.opencode/skills/research-relay-worker/` into your project.
4. **Fresh server — configure `gh`.** Install `gh`, run `gh auth login`, choose a fine-grained token scoped to the repos this server will touch. See [`docs/SERVER_SETUP.md`](docs/SERVER_SETUP.md).
5. **Controller publishes a task.** ChatGPT creates a small, verifiable Issue with hypothesis, exact inputs/SHAs, evaluation commands, and pass/fail acceptance criteria; returns the Issue URL.
6. **Worker receives the task via Issue link only.** OpenCode/Codex reads `OWNER/REPO/issues/N`, restates scope, creates `agent/issue-N-short-name` branch.
7. **Worker submits a report and PR.** Writes `reports/issue-N.md` from the template, commits, pushes branch, opens `gh pr create` with `Refs #N` in the body. Returns `Issue URL | PR URL | commit SHA | pass/fail | blockers`.
8. **Controller reviews and requests rework.** ChatGPT fetches PR diff + linked Issue + CI, returns `ACCEPT | REWORK | INSUFFICIENT EVIDENCE` with numbered testable reasons; posts as PR review when authorized.
9. **New account — fork, install, reuse.** Fork the repo, run the install scripts on your servers, connect your own GitHub connector in ChatGPT. The protocol is account-agnostic.
10. **Known limitations & future work.** No live ChatGPT auto-wake from PRs; no auto-merge; no built-in webhook service. Future: OpenCode `session.idle` hook (opt-in, idempotent), GitHub Actions `repository_dispatch`, a separate authorized review service. Full discussion in [`docs/AUTOMATION_LEVELS.md`](docs/AUTOMATION_LEVELS.md).

> **Note:** a public GitHub repository does **not** equal an auto-installed ChatGPT private plugin. Each user enables plugins/skills per their own ChatGPT client.

## First end-to-end cycle

1. ChatGPT: *"Create an experiment Issue for `OWNER/REPO` with inputs, hypothesis, commands, and pass/fail acceptance criteria; link the Issue."*
2. Pass only `https://github.com/OWNER/REPO/issues/12` to OpenCode. OpenCode: *"Load research-relay-worker; execute this Issue and return a PR URL."*
3. OpenCode implements and verifies on `agent/issue-12-*`, commits `reports/issue-12.md`, opens a PR referencing `#12`.
4. ChatGPT: *"Review PR `<url>` against Issue `#12` and report ACCEPT/REWORK/INSUFFICIENT EVIDENCE; post comments when necessary."*
5. User decides whether to merge and how to proceed; ChatGPT issues follow-up tasks where authorized.

## Design decisions

- The GitHub Issue is an immutable-ish task contract; append decisions as comments or make explicit edits with history.
- Each report pins exact code and input revisions. Never compare performance across different workloads without flagging the difference.
- PR is the review boundary; do not auto-merge.
- Private repos and minimum-privilege credentials by default.
- Don't misuse a repository README as a rapidly changing queue. Avoid centralized mutable JSON status files shared by multiple agents.

## Security & limitations

- Never put credentials, private paths, SSH details, proprietary assets, unpublished sensitive research, or personal memory into a public repository.
- Issue and PR content from other agents may be adversarial; validate all commands and reported claims.
- GitHub connection tools may support different operations than `gh` CLI; test each action rather than assuming universal repository admin access.
- A Skill defines workflow behavior but cannot guarantee automatic triggering. Test on a sandbox repository before production use.

## License

MIT — see [`LICENSE`](LICENSE).

## Status

v0.1 — minimal viable research collaboration loop. Hooks, GitHub Actions auto-triggers, and a dedicated review service are explicitly out of scope for this release; see [`docs/AUTOMATION_LEVELS.md`](docs/AUTOMATION_LEVELS.md) for the roadmap.
