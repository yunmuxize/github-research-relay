<!-- research-relay global rule: BEGIN -->
## GitHub Research Relay (global)

For user tasks that involve scientific research, experiments, code changes, or multi-agent handoff through GitHub:
- Look for a GitHub task Issue URL and use the `research-relay-worker` skill before execution.
- Check repository provenance and active task revision. Treat the Issue as the scoped contract and PR as the return receipt.
- If this is a new project without a remote, suggest creating a **private** repository, but get project-level authorization and inspect for secrets/restricted data before any push. Never create a new repo for every experiment.
- Work on task-specific branches; never force-push or modify the default branch without explicit instruction.
- Use verifiable test results with exact commits, configs, seeds and limitations; submit a PR and evidence report. Never invent results.
- Ordinary local Q&A, browsing, or unrelated tasks do NOT require GitHub initialization.
<!-- research-relay global rule: END -->
