# Automation paths — what is possible today?

| Level | Trigger | Worker environment | Report | Does ChatGPT web auto-review? |
|---|---|---|---|---|
| 0: manual | User pastes Issue URL into OpenCode | Any remote server | PR + report | No; return with PR URL |
| 1: assisted | ChatGPT creates Issue; OpenCode skill executes and reports | Any remote server | PR + report | No; user starts review |
| 2: GitHub-native | `/opencode` or `/oc` on GitHub Issue/PR with OpenCode GitHub integration | GitHub Actions runner, hosted or suitably configured self-hosted | Issue comments + PR | No; user starts review |
| 3: remote hooks | OpenCode `session.idle` / custom webhook, opt-in | Your persistent remote Linux session/agent | PR + report + optional GitHub notification | No by itself |
| 4: automation service | PR webhook/Actions -> dedicated review service using an API or preconfigured automation | Dedicated runner/service | PR review and next task after policy checks | Not the existing ChatGPT web conversation by default |

## Existing relevant tools

1. **OpenCode's official GitHub integration**: `opencode github install`; then mention `/opencode` in an Issue or PR comment. Its Action runs in a GitHub Actions runner and may create a branch and PR. Official guide: https://opencode.ai/docs/github/ . Beware: a GitHub-hosted runner cannot see your private local ns-3 datasets or remote lab hardware unless configured; a **self-hosted** runner or separately connected worker may be required. Configuration of credentials, workflow privileges and security is the user's responsibility.
2. **OpenCode Skills and AGENTS.md**: on-demand `SKILL.md` is for full task behavior; `~/.config/opencode/AGENTS.md` is a small always-loaded pointer. Docs: https://opencode.ai/docs/skills/ and https://opencode.ai/docs/rules/ .
3. **OpenCode plugins**: event `session.idle` can trigger a local hook after a session is idle, useful to post report links, subject to credentials, safeguards and idempotency. Docs: https://opencode.ai/docs/plugins/ .
4. **GitHub CLI `gh`**: `gh repo create --private`, `gh issue view`, `gh pr create`. Docs: https://cli.github.com/manual/ .
5. **GitHub Actions**: `issues`, `pull_request`, `issue_comment`, `workflow_dispatch`, `repository_dispatch` and CI can trigger work. Workflow events alone **cannot reach a ChatGPT Plus browser conversation**. Docs: https://docs.github.com/en/actions/reference/events-that-trigger-workflows .
6. **OpenCode SDK or HTTP server**: lets an authorized orchestrator start/headlessly manage sessions on a server. Network-exposing it requires authentication; prefer no public port. Docs: https://opencode.ai/docs/server/ .

## Recommended upgrade route

- Run level 1 first on a *sandbox/private* repository with a toy deterministic task and expected output. Validate `Issue -> skill -> PR -> ChatGPT review` and repo permissions.
- For GitHub-hosted compute and trivial jobs, use the official `/opencode` GitHub Action (level 2). For ns-3 and persistent lab servers, keep the existing local OpenCode workers, optionally add a project-specific hook (level 3) after the manual reporting is reliable.
- If fully autonomous review is necessary, design an explicit service or opt-in scheduled review with credential, model-cost and risk budgets. ChatGPT cannot simply be invoked by agent message in the same webpage chat.

## Cost and governance

- Reuse a project's repository; Issues and PRs are cheap pointers, not a substitute for secure artifact storage.
- Avoid dumping entire conversation transcripts into GitHub. Link or summarize decisions and publish only necessary reproducibility details.
- A GitHub Actions workflow can incur runner/API/model costs; verify billing and quota before enabling automatic triggers.
- Treat GitHub Issue comments as untrusted input, restrict writable tokens, protect default branch, and require user review for expensive experiments and merges.
