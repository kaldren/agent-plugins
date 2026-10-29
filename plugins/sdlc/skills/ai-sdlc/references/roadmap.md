# Roadmap: the order to adopt the plays

The playbook groups 14 plays into six stages, but **stage order is not adoption order**. Adopt a play only after the plays it depends on. Plays with no prerequisites can start any time.

## Dependency graph (from each play's "Prerequisites")

| Play | Stage | Depends on |
|---|---|---|
| P1 Capture as intent.md | Plan | — |
| P2 Requirements & design → spec.md | Design | P1, at least one policy skill (P5) |
| P3 Plan mode → plan.md (+ auto mode later) | Build | intent/spec if they exist; CLAUDE.md helps |
| P4 CLAUDE.md | Build | — |
| P5 Skills as institutional knowledge | Build | — (CLAUDE.md helps) |
| P6 Hooks as build-time guardrails | Build | — |
| P7 Parallel sessions & subagents | Build | P4; P8 helps |
| P8 Feedback loop | Test | — |
| P9 Continuous evals in CI | Test | P4, P8 |
| P10 AI in the PR review loop | Deploy | P4; P5 if review enforces policies; subagents (P7) |
| P11 Hooks as approval gates (+ managed settings) | Deploy | — |
| P12 CI/CD integration & deployment | Deploy | P10, P11 |
| P13 Closing the loop (control bands) | Maintain | P1, P10, P11, P12 (rollback) |
| P14 Claude on call with Claude Tag | Maintain | P1, P10 (works best after P13) |

## Default phased roadmap ("start with the basics")

**Phase 0 — Prerequisites (setup, ~1 hour)**
- Claude Code installed and logged in; project is a git repo with a remote (unless the user chose none).
- `jq` installed (hooks use it): `brew install jq` / `apt-get install jq`.
- Build, test and lint each run with **one command** that exits non-zero on failure. If not, creating those wrappers is the first job (it's also step 1 of P8).
- New project: pick the stack, scaffold, add one passing test and a minimal CI job that runs the test command.

**Phase 1 — Foundations (no dependencies)**
1. P4 CLAUDE.md — `/init`, cut to a page, commit.
2. P8 Feedback loop — verification block in CLAUDE.md, "done means tests pass with output shown".
3. P1 setup — intent home (`intent/` folder), intent template, commit.

**Phase 2 — The artifact chain, by hand, on the pilot change**
4. P1 Capture the pilot `intent.md` (`/ai-sdlc intent`).
5. P5 First policy skill — the one most inconsistently applied (needed by P2).
6. P2 `spec.md` from the intent (`/ai-sdlc spec`).
7. P3 Plan mode → `plan.md` → implement in one pass (`/ai-sdlc plan`).
→ Checkpoint: walk the user through the chain in `git log` — that's their audit trail.

**Phase 3 — Guardrails**
8. P6 Build hooks: protected paths, secrets, format-on-edit, test protection during fixes; permissions allowlist for the safe inner loop.
9. P3 Auto mode for routine work (tight spec, small blast radius, tests cover it).

**Phase 4 — Scale and review**
10. P7 Subagents (verifier first), then 2–3 parallel worktree sessions.
11. P10 REVIEW.md + automated PR review; `@claude` fix loop; babysit-PR command.

**Phase 5 — Gates and pipeline**
12. P11 Approval-gate hooks (production deploy, change-ticket paths); managed settings if org/regulated.
13. P12 Claude in CI: read-only triage → write steps via PR → MCP deploy tools → per-environment tiers → rehearsed rollback.
14. Automate the triggers: merged intent → spec job; approved spec → plan session.

**Phase 6 — Test the agent itself**
15. P9 Continuous evals on any change to CLAUDE.md, `.claude/**`, on a schedule.

**Phase 7 — Close the loop**
16. P13 One control band (CI failure rate or PR cycle time first), detection script, tiers, agent writes `intent.md`.
17. P14 Claude Tag in the incident channel.

Stop at the phase that matches the user's ambition (kickoff Q3), but mention what the next phase would unlock.

## Tailoring rules

**Solo developer**
- One person holds every role. Keep the artifacts and the order of gates; replace sign-offs with "review the artifact before you commit it". PR review still pays off — the agent that wrote the code can't approve it, and the findings catch what self-review misses.
- Skip: managed settings via MDM, policy-owner routing, Claude Tag (unless they use Slack for alerts), org plugin marketplaces.
- Simplify: `intent/` in the same repo; skills in `.claude/skills/`; evals can start at 10 tasks on a nightly schedule.

**Small team**
- Name a product owner and tech lead even if informal; add CODEOWNERS and branch protection in Phase 4.
- Team hooks in `.claude/settings.json` (committed). Personal tweaks in `.claude/settings.local.json`.

**Organization / several teams**
- Distribute skills, hooks and agents through a plugin in a private marketplace; intent may need its own repo if it spans many repos.
- OpenTelemetry export (monitoring-usage docs) early — most metrics come from it.

**Regulated**
- Pull forward: P11 + managed settings (secrets deny, sandbox, managed hooks only), source-of-truth linkage with the existing tracker (`governance-and-metrics.md`), branch protection with code-owner approval, model access through the cloud agreement (Bedrock/Vertex/Foundry).
- Every artifact carries the record ID; every legacy record carries the commit SHA.
- Higher-risk changes: tech lead/architect approves the plan; policy owners resolve spec concerns before engineering sees it.

**Existing Claude Code user**
- Audit first: CLAUDE.md length and staleness, existing hooks/skills, permissions. Mark plays already satisfied as ✅ and start from the first gap.
