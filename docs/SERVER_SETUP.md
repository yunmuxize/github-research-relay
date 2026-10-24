# Server setup — fresh host to running worker

This guide gets a new Linux/macOS server from zero to "can execute a Research Relay Issue and open a PR". It is intentionally generic; replace `OWNER` with your GitHub account.

## 1. Install prerequisites

```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y git gh

# macOS (Homebrew)
brew install git gh

# Or use official installers:
#   git:  https://git-scm.com/downloads
#   gh:   https://cli.github.com/
```

OpenCode (optional, only if this host runs OpenCode as the worker):

```bash
curl -fsSL https://opencode.ai/install | bash
```

Codex (optional, only if this host runs Codex as the worker): install per Anthropic/OpenAI current instructions and ensure `.agents/skills/` discovery is enabled.

## 2. Authenticate GitHub with minimum privilege

Prefer a **fine-grained personal access token** scoped to only the repositories this server will touch. Avoid classic tokens with broad `repo` scope on shared servers.

```bash
gh auth login
# Choose: GitHub.com -> HTTPS -> Paste token (or browser flow if local)
gh auth status   # confirm the logged-in account; never print the token in logs/reports
```

Minimum token permissions for a worker:

- Contents: Read and Write (commit + push branch)
- Pull requests: Read and Write (open PR)
- Issues: Read (read task; the controller creates Issues)
- Metadata: Read (always required)

Do **not** grant repository administration, secrets, or webhook permissions to a worker token.

## 3. Install the worker skill

### Option A — global OpenCode skill (applies to all projects for this user)

```bash
git clone https://github.com/yunmuxize/github-research-relay.git /tmp/relay
cd /tmp/relay
bash opencode/install.sh                 # installs to ~/.config/opencode/skills/research-relay-worker/
bash opencode/install-global-rules.sh    # opt-in: short pointer in ~/.config/opencode/AGENTS.md
```

### Option B — project-level only (no global change)

Copy `.opencode/skills/research-relay-worker/` into your research project's `.opencode/skills/`. The skill loads only when OpenCode runs inside that project.

### Codex / Agent-Skills-aware tools

Clone this repo (or copy `.agents/skills/research-relay-{controller,worker}/`) into your project root. Codex auto-discovers `.agents/skills/*/SKILL.md`.

## 4. Point the worker at a task

The worker takes only an Issue URL — no prompt body, no secrets:

```
Load research-relay-worker; execute this Issue and return a PR URL:
https://github.com/OWNER/REPO/issues/12
```

The worker will: read the Issue, create `agent/issue-12-<short-name>`, do the smallest coherent slice, write `reports/issue-12.md`, commit, push, open a PR with `Refs #12`, and return the PR URL.

## 5. Multi-server notes

- Each server authenticates GitHub independently. Do not share a token across hosts.
- A server does not need ChatGPT access. The controller (ChatGPT) and worker (OpenCode/Codex) communicate only through GitHub.
- Private repos require the worker token to be granted access; a public repo (like this framework) needs no extra grant to clone.
- If a server has no outbound GitHub access except through a proxy, configure `gh` and `git` per your environment (e.g. `HTTPS_PROXY`). Do not hardcode proxy addresses into the skill — keep them in the host environment.

## 6. Verify the loop on a sandbox task

Before real research, run one toy task end-to-end:

1. Controller creates an Issue: "Add a `docs/EXAMPLE.md` describing the relay loop in one paragraph. Acceptance: file exists, ≤200 words, links to README."
2. Worker reads the Issue, branches, writes the file, opens a PR referencing the Issue.
3. Controller reviews the PR, returns ACCEPT or REWORK.
4. Leave the PR open; do not auto-merge.

If all four steps succeed, the server is ready for real tasks.
