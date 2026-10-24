# Server setup — fresh host to running worker

This guide gets a new Linux/macOS server from zero to "can execute a Research Relay Issue and open a PR". It is intentionally generic; replace `OWNER` with your GitHub account.

## 0. One-time default repository configuration (optional, no secrets)

After install, if you want the natural-language trigger "接一轮新任务" to work without passing an Issue URL or directory each time, configure the default repository **once per host**. This stores only the repository coordinate — never tokens or passwords.

Pick exactly one mechanism:

```bash
# Option A — environment variable (e.g. in ~/.bashrc or ~/.zshrc)
export RESEARCH_RELAY_REPO="owner/repo"

# Option B — one-time config file (no tokens, no passwords)
mkdir -p "$HOME/.config/research-relay"
echo "RESEARCH_RELAY_REPO=owner/repo" > "$HOME/.config/research-relay/config"
```

The Worker resolves the default repo in this order: `RESEARCH_RELAY_REPO` env var → `$HOME/.config/research-relay/config` → the current Git `origin` remote only when it is clearly this Relay repository. If none resolve, the Worker asks for one-time configuration rather than guessing.

The host reuses its existing `gh` CLI authentication; no credentials live in this config. Verify with `gh auth status` (do not print tokens).

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

### Explicit Issue URL (always works)

```
Load research-relay-worker; execute this Issue and return a PR URL:
https://github.com/OWNER/REPO/issues/12
```

### Natural-language trigger (needs one-time config from step 0)

After configuring `RESEARCH_RELAY_REPO`, the Worker can discover the next task by itself:

```
接一轮新任务
```

The Worker searches `relay:ready` Issues, picks the lowest-numbered one (FIFO), claims it (`relay:ready` → `relay:in-progress`), executes, opens a PR, and transitions to `relay:review`. If no ready Issue exists it reports an empty queue and does nothing. It handles exactly one Issue per invocation.

### Queue labels

The Controller creates these labels idempotently; the Worker transitions them:

| Label | Meaning |
|---|---|
| `relay:ready` | Controller prepared a task; a Worker may pick it up |
| `relay:in-progress` | A Worker has claimed the task |
| `relay:review` | A PR is submitted and awaits Controller review |
| `relay:blocked` | Waiting for clarification or user action |
| `relay:done` | Controller accepted; Issue stays open unless user asks to close |

## 5. Multi-server notes

- Each server authenticates GitHub independently. Do not share a token across hosts.
- A server does not need ChatGPT access. The controller (ChatGPT) and worker (OpenCode/Codex) communicate only through GitHub.
- Private repos require the worker token to be granted access; a public repo (like this framework) needs no extra grant to clone.
- If a server has no outbound GitHub access except through a proxy, configure `gh` and `git` per your environment (e.g. `HTTPS_PROXY`). Do not hardcode proxy addresses into the skill — keep them in the host environment.

## 6. Verify the loop on a sandbox task

Before real research, run one toy task end-to-end:

1. Controller creates an Issue: "Add a `docs/EXAMPLE.md` describing the relay loop in one paragraph. Acceptance: file exists, ≤200 words, links to README." Apply `relay:ready`.
2. Worker: "接一轮新任务" → claims the lowest-numbered ready Issue, branches, writes the file, opens a PR referencing the Issue, transitions to `relay:review`.
3. Controller: "验收一下结果" → reviews the PR, returns ACCEPT or REWORK, transitions to `relay:done` (accept) or back to `relay:ready` (rework).
4. Leave the PR open; do not auto-merge.

### Manual trigger boundary

A normal ChatGPT web subscription does **not** wake up automatically when a PR arrives. The user returns to chat and says "验收一下结果" to trigger review. Likewise the Worker is triggered by the user running OpenCode and saying "接一轮新任务". No hooks, daemons, or automatic wake-ups are part of this framework.

If all four steps succeed, the server is ready for real tasks.
