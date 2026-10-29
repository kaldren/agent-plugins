# Stage 5 — Deploy

> Review runs in both directions, and governance is enforced as the agent acts. The agent does everything up to the production gate and nothing past it.

---

## P10 AI in the PR review loop

Claude reviews incoming PRs against the organization's policies **and** addresses review comments on its own PRs. Every PR gets the same review passes, findings ranked by severity; humans judge intent and risk.

**Prerequisites:** an up-to-date CLAUDE.md; skills if review enforces written policies; defined subagents. **Infrastructure:** either the managed **Code Review** service (research preview — an admin enables it and selects repos), or **claude-code-action** in your own CI (needed for control of the pipeline, or to route calls via Bedrock/Vertex/Foundry). Branch protection requiring code-owner approval.

**You do**
- GitHub: run `/install-github-app` in Claude Code (installs the GitHub app and adds the workflow + `ANTHROPIC_API_KEY` secret), or have an admin enable managed Code Review. Other hosts: add a CI job calling `claude -p` (see P12).
- Turn on branch protection for `main`: require PRs, require code-owner review, require status checks. Add `CODEOWNERS`.
- Tech lead: own REVIEW.md and the monthly tuning.

**I'll do**
1. Write `REVIEW.md` at the repo root from `templates/REVIEW.md`: passes (**Bugs**, **Security**, **Compliance** vs spec.md, plan.md and design principles), what **Important** vs **Nit** means, the nit cap, what not to report (generated paths, anything CI already enforces).
2. If using your own CI: `templates/workflows/claude-review.yml` (review on PR open/sync) — check inputs against the current claude-code-action README.
3. **Human threshold:** findings never approve or block by themselves; branch protection still requires a code owner. A platform engineer who wants to gate merges on findings can read the machine-readable severity tally the check run publishes.
4. **Fix loop:** tagging `@claude` on a review comment makes Claude address it and push the fix (claude-code-action). In the managed service, `@claude review` requests a fresh review instead.
5. **Babysit Claude's own PRs:** install `templates/commands/babysit-pr.md` as `.claude/commands/babysit-pr.md` — it sweeps unresolved comments and failing checks, fixes, pushes, repeats until the PR is green and waiting only on code-owner approval.
6. **Feed findings back:** when review flags the same mistake a second time, add the correction to CLAUDE.md in that PR. Review reads CLAUDE.md, so it's caught from the next PR on. Review also flags when a change made CLAUDE.md stale.
7. **Monthly tuning** (put a reminder in the progress file): rate findings, cap nit volume, exclude generated paths and CI-enforced rules.

**Governance:** separation of duties — the agent that wrote the code can't approve it. REVIEW.md applies to all PRs; findings, fixes, ratings, approvals live in the PR history (the PR is the audit record). **Measure:** leading — time to first review (→ minutes); share of review comments resolved without a human touching the branch. Lagging — defects/vulnerabilities caught before merge vs escaping to production.

---

## P11 Hooks as approval gates

Build hooks allow or block with no human involved. A hook can also **ask** — pause the action until a specific person approves — which is what release gating needs. Hooks run wherever Claude acts: block migration/infra edits without a change ticket in Build, block test edits during fixes in Test, gate production deploys here.

**Prerequisites:** none. **Infrastructure:** a written list of the approvals the change process requires.

**You do:** with change management/compliance (or yourself, if solo), list the human gates that must survive — change-management sign-off, release authorization, protected-path edits. Decide what counts as approval (an approved change ticket ID, release manager sign-off).

**I'll do**
1. Express each gate as a PreToolUse hook that **allows, asks, or blocks**:
   - `templates/hooks/production-gate.sh` — blocks `deploy … production` commands unless `RELEASE_APPROVAL` is set (blocking via exit 2), or asks for confirmation (JSON `permissionDecision: "ask"`) — pick per gate.
   - `protect-paths.sh` change-controlled mode (from P6) — migrations/infra need `CHANGE_TICKET`.
2. Team hooks → `.claude/settings.json` (committed). **Non-negotiable hooks → managed settings** owned by the platform/IT admin, where engineers can't switch them off.
3. Every block explains itself: the reason and the route to approval in Claude's output.

**Managed settings (organizations / regulated):** `templates/managed-settings.json` is the playbook's worked example — a starting point to tailor, not to copy. Deployed via MDM or the admin console (server-managed settings); on macOS the file path is `/Library/Application Support/ClaudeCode/managed-settings.json`. What each part buys:
- `permissions.deny` keeps secrets out of context and blocks network egress through tools; `permissions.allow` pre-approves the safe inner loop so the deny list doesn't cause prompt fatigue.
- `disableBypassPermissionsMode` + `allowManagedPermissionRulesOnly`: nobody can widen the rules.
- `sandbox` closes what permissions can't: an OS-level domain allowlist blocks egress from shell commands; `failIfUnavailable` + `allowUnsandboxedCommands: false` make it a hard gate; `credentials` denies `~/.ssh`, `~/.aws/credentials` and strips named env secrets.
- `allowManagedHooksOnly`: only the approved gates run. `disableSideloadFlags` + `strictKnownMarketplaces`: every skill/agent/hook/MCP server comes from the approved marketplace. `allowManagedMcpServersOnly`: tool surface is an allowlist. `requiredMinimumVersion`: only an assessed build runs.
Every deny trades against capability; tune to the repo's data classification. Verify keys against code.claude.com/docs/en/settings before deploying.

**Solo developer:** skip managed settings; put gates in `.claude/settings.json`.

**Governance:** the gate condition is enforced every time, for everyone; allow/block decisions are logged with timestamps (OpenTelemetry). **Measure:** leading — time waiting at each gate; lagging — gate violations reaching production before vs after.

**Done when:** a simulated `deploy --env production` is blocked with a clear message, and allowed once the approval variable is set.

---

## P12 CI/CD integration and deployment

Run Claude non-interactively inside the pipeline for judgment steps, sandboxed with scoped credentials; expose deployment through MCP; rehearse rollback before the agent ever needs it.

**Prerequisites:** P10 and P11 — the gates must exist before automation accelerates anything through them. **Infrastructure:** CI with claude-code-action or any runner that can call `claude -p`; model access (API, or Bedrock/Vertex/Foundry); MCP servers for deployment targets; a sandbox profile for agent jobs with no standing production credentials.

**Steps — in this order**
1. **Read-only judgment first:** `claude -p` to triage a failed build, summarize a flaky test, draft the changelog (`templates/workflows/triage-failed-build.yml`).
2. **Write steps behind existing gates:** fix lint, update generated docs, address `@claude` review comments. Everything arrives as a PR through branch protection; the agent has **no route to push to main**.
3. **Sandbox execution:** containers, network policy, short-lived scoped tokens, no production credentials by default.
4. **Expose deployment through MCP:** deploy, status, rollback as tools scoped per environment — an allowlist, not a shell script with credentials. (Vercel, Azure, AWS, Supabase etc. have MCP servers; check which the user's platform offers.)
5. **Tier autonomy by environment:** dev — agent deploys freely; staging — in between; production — agent prepares the release, release manager authorizes, hook enforces.
6. **Rollback is the most rehearsed path:** a single command the agent can run, exercised regularly in staging. Stage 6 calls it when a control band is breached, so prove it in advance. Record the last rehearsal date in the progress file.
7. **Automate the stage triggers** now that plumbing exists: merged intent → job writes spec.md as a PR (`claude -p` with skills loaded); accepted spec → engineer opens plan mode (or a job drafts plan.md as a PR).

**Governance:** the agent may act up to the production gate and cannot pass it — branch protection, production hook with a named release manager, each non-interactive run under the agent's own identity (pipeline log separates agent from triggering engineer), per-environment permission tiers. **Measure:** leading — share of pipeline failures triaged without paging a human; lagging — DORA metrics (deploy frequency, lead time, change failure rate, time to restore).
