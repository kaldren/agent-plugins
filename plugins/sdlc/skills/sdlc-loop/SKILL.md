---
name: sdlc-loop
description: The required process for every code change in any project (intent → spec → plan → code + tests → PR → maintain). Load before writing, editing, planning or reviewing any code, in any app or package, and when an incident, bug or review finding needs to re-enter the process.
---

# The loop

Every change is a chain of committed artifacts. Each stage ends by committing one; the next stage starts by reading it. The chain is the audit trail: who asked for what, what the agent produced, who approved it.

Every change lives in `intent/<YYYY-MM-DD>-<slug>/`. **Read that folder first.** Whatever the latest artifact is, that is the stage you are in. If the folder doesn't exist, start at Plan.

| Stage | Artifact | Human gate | What accepting it triggers |
|---|---|---|---|
| 1 Plan | `intent.md` | Status `draft` → `accepted` / `rejected` | Design pass |
| 2 Design | `spec.md` | Status `accepted`, all flagged concerns resolved | Plan mode |
| 3 Build | `plan.md` | Accepted before any code | Implementation |
| 4 Test | code + tests | `pnpm typecheck && pnpm test` green, output pasted | PR |
| 5 Deploy | PR + review findings | Findings resolved; a human merges | Pipeline |
| 6 Maintain | incident / finding → new `intent.md` | Triage: fix now, schedule, dismiss | Back to stage 1 |

Templates for each artifact are in `templates/`. Use them verbatim as the skeleton.

## Hard rules

- Never skip a gate. Never write code without an accepted `plan.md`.
- An artifact is accepted only when its `Status:` line says so. Draft means not accepted. The agent never changes the status; a human does.
- When implementation departs from the plan, update `plan.md` in the same commit.
- If a test fails, fix the code, not the test. Never skip, weaken or delete a failing test.
- The agent never approves its own work and never merges.
- Small fix (typo, one-liner): ask the user whether a short `intent.md` alone is enough. If yes, still run stage 4 and open a PR.
- Solo mode: the user approves each artifact after a re-read later (e.g. the next day). Don't ask for acceptance in the same session that produced the artifact unless the user says so.

## Stage 1 — Plan → `intent.md`

Intent enters from three routes: a person's idea, a ticket, or an incident/finding from stage 6. Same steps regardless.

1. Let the originator describe the problem in their own words: what they can't do today, who is affected, what better looks like, what's out of scope.
2. Brainstorm until concrete. Ask what an analyst would ask: scope, users, constraints, what success looks like.
3. Write `templates/intent.md`. Keep the originator's terms; don't translate into engineering language.
4. The originator corrects what you misunderstood. Commit as `Status: draft`.
5. Gate: a human sets `accepted` or `rejected`.

Don't prescribe a solution in `intent.md`; that's the spec's job.

## Stage 2 — Design → `spec.md`

Requirements and design are one session, not two phases.

1. Read `intent.md`. Load every policy skill that applies (security, UX, data, API conventions, anything in `.claude/skills/`).
2. Write `templates/spec.md`: requirements, acceptance criteria (each one testable), design, risk, and **flagged concerns** — every point where you cannot satisfy a constraint, where two policies contradict, or where an analyst would escalate.
3. Carry forward every open question from `intent.md`: answered, or explicitly still open.
4. Gate: the human reviews against the idea (does it solve the stated problem?) and resolves flagged concerns *first*, before anything is planned.

If `spec.md` has to change after `plan.md` exists, note why in `spec.md`'s changelog. That count is the rework signal.

## Stage 3 — Build → `plan.md`, then code

1. Enter plan mode. Read the codebase; change nothing.
2. Write `templates/plan.md` from `intent.md` + `spec.md`: files that change, order of work, risks, proof.
3. Interrogate your own plan before showing it: what could this break? which step is riskiest? what alternatives did you reject and why? Put the answers in the plan.
4. The plan is done when an engineer who never saw this conversation could implement it from the file alone.
5. Mark which tasks touch disjoint files; those may run in parallel worktrees. Tasks that share files run sequentially in one session.
6. Gate: human accepts. Commit `plan.md`.
7. Implement in one pass if the plan is solid. Respect `CLAUDE.md` conventions and protected paths.
8. Departed from the plan? Update `plan.md` in the same commit.

Mistake made twice → the correction goes into `CLAUDE.md` in the same PR. Keep `CLAUDE.md` under a page.

## Stage 4 — Test

Always give yourself a way to verify before a human sees the work.

- State the target quantifiably before coding: "all tests in X pass", "endpoint returns 200 with field Y", "screenshot matches the mock".
- **Bug fixes: failing test first.** Reproduce the bug as a test, run it, confirm it fails for the expected reason, commit that test. Only then fix, without touching the test file.
- UI work: screenshot, compare against the mock, adjust. Two or three rounds is normal.
- Done means: `pnpm typecheck && pnpm test` (and lint if configured) green, literal output pasted into the PR description or the session summary.
- Final check in a fresh context where possible (a verifier subagent that runs the app and reports, never fixes), so the verdict isn't coloured by the assumptions that produced the code.

## Stage 5 — Deploy → PR

1. Open the PR. Description links `intent/<folder>/` and pastes the verification output.
2. Review passes, as defined in `REVIEW.md` at repo root (template in `templates/REVIEW.md`): bugs, security, compliance against `spec.md` and `plan.md`. Tag each finding with its pass and severity (Important vs Nit).
3. Address findings and failing checks until the PR is green and waiting only on human approval. Each fix is a commit on the PR thread.
4. A finding that repeats something already caught before → correction into `CLAUDE.md` in the same PR. Review also flags when the change made `CLAUDE.md` stale.
5. A human merges. The agent acts up to the gate and never past it. No path to `main` except a merged PR; production deploys require explicit named authorization.

## Stage 6 — Maintain → closes the loop

An incident, a breached metric, a flaky test, a bug ticket or a channel message re-enters the process as a new `intent.md` in the stage-1 format: the anomaly and its evidence, proposed outcome, affected systems, open questions. It then goes through all stages like anything else.

- Detection is deterministic (a script, a threshold); the agent is invoked after detection, and what it may do is tiered: log → diagnose read-only → propose a PR or a pre-approved runbook (e.g. rollback). Never act outside those routes.
- Every shipped incident fix gets a regression test, and a short entry in `lessons/<YYYY-MM>-<slug>.md` (`templates/lesson.md`) that future investigations read first.
- Rollback must be rehearsed before it's needed.

## Source of truth

If a ticket system holds the record, every artifact notes the record ID and the record links the commit SHA. One system is the source of truth per artifact; the other holds a copy or a link.

## Signals worth watching (read from git history, no tooling needed)

- Time from first conversation to committed `intent.md`.
- `spec.md` commits dated after the first `plan.md` commit (requirements rework).
- Share of changes merged from the first implementation pass; merged diff still matches `plan.md`.
- Review findings citing a policy a skill should have applied (skill not triggering or drifted).
- Repeat incidents of the same class (should fall as the regression suite grows).
