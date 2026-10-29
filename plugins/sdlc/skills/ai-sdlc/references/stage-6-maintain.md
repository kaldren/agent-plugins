# Stage 6 — Maintain: closing the loop

> A trigger invokes Claude with no person in the invocation path, and what it finds re-enters the pipeline as intent.md.

Until now every stage needed a human to launch it. Here Claude runs headless: a trigger (control-band breach, ticket, channel message, schedule) invokes it, it diagnoses, acts only through gated routes, and writes what it finds as `intent.md`. Between autonomous stages sits an independent **confidence gate** — a deterministic check or an adversarial reviewing agent — deciding whether output continues or is escalated to a human. People triage and review; they no longer have to start the work.

---

## P13 Closing the loop with control bands

**Prerequisites:** intent.md format (P1), PR review (P10), hooks as the action boundary (P11), a rehearsed rollback (P12). **Infrastructure:** a metrics store the detection script can query (Prometheus, CI API, git host API…), read access to the repo, a way to run Claude non-interactively in CI (or the Agent SDK for a webhook-receiving service).

**You do:** pick the metric and its owner; decide who triages the queue; add CI secrets for metrics access.

**Steps**
1. **Pick one metric with a stable rolling baseline:** CI test failure rate, post-deploy 5xx rate, or PR cycle time. Solo/small projects: CI failure rate or PR cycle time — available from the git host API with no monitoring stack.
2. **Write the detection script — deterministic, no model.** Mean and standard deviation over a rolling window plus Western Electric rules so bands catch slow drift as well as spikes. Version-controlled and unit-tested. Template: `templates/monitoring/detect.py` (reads the series on stdin, prints the tier as JSON).
3. **Define response tiers in config** (`templates/monitoring/bands.yaml`): 1σ → log only; 2σ → invoke Claude **read-only** to diagnose; 3σ → Claude may act, but only by opening a PR into the review gate or triggering a pre-approved runbook (e.g. rollback).
4. **Trigger layer:** scheduled workflow (`templates/workflows/control-loop.yml`), a webhook from monitoring, or a cron job inside the network. Claude runs stateless — `claude -p` on a CI runner, or an Agent SDK service in a sandboxed container — so a loop begins and ends without anyone starting it.
5. **The agent writes its diagnosis as intent.md** in the Stage 1 format: anomaly and evidence, proposed outcome, affected systems, open questions. It then flows through the pipeline like any other intent.
6. **Triage:** service owner/on-call routes product-facing findings to the product owner. Fix now, schedule, or dismiss. **Dismissals tune the bands** to cut noise.
7. **When a fix ships, add an eval** for the incident (P9).

**Examples:** CI failure rate > 3σ → agent quarantines the flaky test or opens a revert PR, review gate decides. Post-deploy 5xx > 3σ with a deploy in the window → agent triggers the existing rollback pipeline. PR cycle time trips a drift rule → agent writes a report for engineering leadership.

**Governance:** tier boundaries enforced from version-controlled config; permissions and managed settings deny production access; invocations, findings and triage decisions logged with timestamps; service owner approves findings; changes go through normal PR review; runbooks the agent may trigger were approved in advance.
**Measure:** leading — time from band breach to intent.md in the triage queue (vs old incident → post-mortem action). Lagging — share of findings that become merged fixes; repeat incidents of the same class (should fall as fixes add evals).

---

## P14 Claude on call with Claude Tag

Incidents also arrive as a 10pm Slack message. **Claude Tag** (public beta, Slack) makes Claude a channel member under its own identity — a first responder for every incident, with the conversation and knowledge staying in the channel.

**You do:** a Slack admin installs it — in Claude Code, `/install-slack-app` starts the setup (the claude-code-guide agent can walk through current steps). Invite Claude to the incident channel(s). Connect MCP servers for metrics/logs so it can verify recovery.

**I'll do**
- Create `lessons/` in the repo with a `README.md`: one post-mortem file per incident (`lessons/YYYY-MM-<slug>.md`) that future investigations read. Add a CLAUDE.md line pointing at it.
- Add a short runbook to CLAUDE.md or a skill: how to diagnose (compare error signatures with the deploy diff), when to propose rollback (only the rehearsed one, only with a human "go"), how to confirm the metric is back in band, where to write the post-mortem.

**How it flows:** someone tags `@claude` → Claude diagnoses → proposes the rehearsed rollback → a human authorizes in-thread → Claude acts, verifies the metric is back at baseline, writes `lessons/…md`. Tagged on a ticket or asked in channel, it triages the same way: a small bounded fix arrives as a PR through review; anything bigger is written up as intent.md — and the loop feeds itself.

**Governance:** the channel is the audit trail — request, diagnosis, human authorization and fix stay where the incident was handled.
