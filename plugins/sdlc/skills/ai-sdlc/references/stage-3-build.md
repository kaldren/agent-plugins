# Stage 3 — Build

> Nothing is implemented without an accepted plan. Institutional knowledge becomes files the agent reads, and the guardrails run as code rather than as habits.

Contents: [P4 CLAUDE.md](#p4-claudemd) · [P3 Plan mode](#p3-plan-mode-as-the-default-starting-point) · [Auto mode](#auto-mode) · [P5 Skills](#p5-skills-as-institutional-knowledge) · [P6 Build hooks](#p6-hooks-as-build-time-guardrails) · [P7 Parallel sessions & subagents](#p7-parallel-sessions-and-subagents)

---

## P4 CLAUDE.md

Gives Claude what a new joiner needs on day one: commands, conventions, architecture, and the mistakes the team sees most. Knowledge from heads and wikis becomes a file the agent reads every session.

**Prerequisites:** none. **You do:** be (or name) the engineer who knows the codebase best, to cut the draft down.

**I'll do**
1. Run `/init` — or, for a new project, write it from `templates/CLAUDE.md`. (`/init` is a built-in command the user types; if you can't run it yourself, ask them to, or generate the equivalent by reading the repo.)
2. Cut to what a new joiner needs on day one: build/test/lint commands, conventions that matter, architecture in a few lines, "Things Claude gets wrong".
3. Add the **Verifying your work** block (P8) and a pointer to the artifact chain (`intent/<change>/{intent,spec,plan}.md`).
4. Keep it **under a page** — Claude reads all of it every session; stale lines cost context for nothing.
5. Commit at the repo root so the team shares one version and changes are reviewed like code.

**Working rule to teach the user:** when Claude makes the same mistake twice, the correction goes into CLAUDE.md (and in Stage 5, PR review does this automatically).

**Governance:** version-controlled, reviewable; code owners approve changes. **Measure:** leading — repeated mistakes CLAUDE.md should have caught (track corrections in git history); lagging — time to first merged PR for a new team member.

**Done when:** committed, < ~60 lines, and the commands in it actually work when run.

---

## P3 Plan mode as the default starting point

Work starts with a written plan Claude produces in plan mode, where it can read the codebase without changing anything. The engineer corrects the plan *before* code exists, and the approved plan is committed as `plan.md` for later stages (PR review) to check against.

**Prerequisites:** intent.md/spec.md if they exist; CLAUDE.md helps. **Infrastructure:** Claude Code with repo access.

### Running it (`ai-sdlc plan <spec path>`)

Plan mode is a session permission mode, entered by the user: **Shift+Tab** to cycle into plan mode, or start with `claude --permission-mode plan`. If this skill is invoked outside plan mode, tell the user to switch (or use the EnterPlanMode tool if available) — the point is that edits are impossible until the plan is accepted.

1. Read intent.md + spec.md + CLAUDE.md and the code involved.
2. Produce a plan that names **the files that change, the order of work, the risks, and the tests that prove it** (`templates/plan.md`).
3. **Let the engineer interrogate it.** Invite these questions explicitly: What could this break? Which step is riskiest? What options did you consider and reject? Interview the engineer back about anything ambiguous.
4. Iterate until **an engineer who never saw the conversation could implement it from the plan alone**.
5. On acceptance, commit the plan as `intent/<change>/plan.md` (`plan: <slug>`). Routine changes: engineer approves. Higher-risk (as classified in the spec): tech lead/architect approves.
6. Implement. With a solid plan this is often one pass. Run the feedback loop (P8) as you go.
7. **If implementation departs from the plan, update plan.md in the same commit.** PR review's compliance pass checks the diff against it.

**Governance:** design review happens before code is generated, when changing course is just editing a document. Plan mode enforces this itself. The plan, revisions and who accepted it are logged. **Measure:** leading — share of changes merged from the first implementation pass; time from plan approval to merged PR. Lagging — rework cycles per change; how often the merged diff still matches plan.md.

### Auto mode
Once guardrails mature (tuned CLAUDE.md, policy skills, blocking hooks, a test suite Claude can run), let Claude apply the accepted plan without per-edit prompts — switch to auto mode with Shift+Tab after approving the plan. Use it by default for routine work: tight spec, small blast radius, code the tests already cover. Review shifts from watching edits to reviewing artifacts after longer autonomous sessions — and it's what makes parallel worktrees (P7) and the closed loop (Stage 6) possible. Recommend it only after P6 and P8 are ✅.

---

## P5 Skills as institutional knowledge

Skills make institutional knowledge operational: explicit, versioned, applied broadly, updated centrally when policy changes. **Rule of thumb:** write a skill for knowledge that must be applied consistently; don't write one for things that belong in CLAUDE.md or a prompt.

**Prerequisites:** none. **You do:** pick the policy, name its owner, point me at its written source of truth (doc, wiki page, or your head — then we write it down first). The owner signs off the skill and every later change to it.

**I'll do**
1. Pick one policy enforced inconsistently today (security standard, API convention, brand rule).
2. Write it as `.claude/skills/<name>/SKILL.md` from `templates/policy-skill.SKILL.md`: frontmatter `description` says *when it triggers* (be specific and a little pushy), body says *what to do*, and ends with a deterministic check script if one exists.
3. Ship it in the repo (`.claude/skills/<name>/`) or, for an org, via a plugin in a private marketplace.
4. **Test that it triggers.** Ask for the relevant task 3–4 different ways (new endpoint, review existing code, generate an OpenAPI spec…) in fresh sessions or subagents and confirm the skill loads each time. Tune the description if it doesn't.
5. When the policy changes: change the skill, policy owner approves the PR. Engineers get it next session.

**Governance:** a skill is an **advisory** control — nothing forces compliance. If the policy must always hold, back it with a hook (P6/P11) or a PR review pass that re-checks it (P10). **Measure:** leading — time from policy-owner approval to skill merged; lagging — PR review findings citing the policy should fall toward zero (if not, the skill isn't triggering or has drifted from the policy).

---

## P6 Hooks as build-time guardrails

The deterministic layer behind skills. Build is where Claude acts most (edits, shell commands), so hooks fire most here. Keep them **fast and scoped to the file that changed**; heavy checks (full test suite) belong at commit or PR. Hooks that *ask a human* belong in Stage 5 — an approval prompt during build puts a person back on the critical path of every parallel session.

**Prerequisites:** none (`jq` installed). **You do:** list protected paths (generated code, frozen packages) and change-controlled paths (migrations, infra) — kickoff Q15.

**I'll do** — copy from `templates/hooks/` into `.claude/hooks/`, `chmod +x`, and merge `templates/settings.json` into `.claude/settings.json`:
| Hook | Event | What it does |
|---|---|---|
| `protect-paths.sh` | PreToolUse `Edit\|Write\|MultiEdit\|NotebookEdit` | Blocks edits to globs in `.claude/protected-paths.txt`; blocks `.claude/change-controlled-paths.txt` unless `CHANGE_TICKET` is set |
| `block-secrets.sh` | PreToolUse `Edit\|Write\|MultiEdit` | Blocks content that looks like credentials (keys, tokens, private keys) |
| `protect-tests.sh` | PreToolUse `Edit\|Write\|MultiEdit` | During a fix (`AI_SDLC_FIX_MODE=1 claude`), blocks edits to test files so the agent can't weaken the check (P8) |
| `format-on-edit.sh` | PostToolUse `Edit\|Write\|MultiEdit` | Runs the project formatter on the changed file so drift never accumulates |

Also add a `permissions.allow` list for the safe inner loop (the project's build/test/lint commands, `git status/diff/log`) so sessions don't wait on prompts, and `permissions.deny` for `Read(./.env*)`, `Read(./secrets/**)`.

Every block must **explain itself**: the reason and the route to approval go to stderr (exit code 2), so Claude can tell the user.

**Done when:** each hook is exercised once — try to edit a protected file, write a fake `AKIA…` key, edit a test with `AI_SDLC_FIX_MODE=1` — and each is blocked with a clear message. Show the user the output. Then confirm a normal edit still works.

---

## P7 Parallel sessions and subagents

- **Parallel session** = another full Claude Code instance on a separate task in its own **git worktree**. Sessions know nothing about each other; the engineer is the only shared thing.
- **Subagent** = scoped helper inside one session with its own context window and tool limits, for jobs that recur across tasks.

**Prerequisites:** CLAUDE.md (all sessions read it); the feedback loop (P8) helps — less supervision when a session can verify itself. **Infrastructure:** git repo; permissions tuned so sessions don't wait on prompts for safe commands (P6).

**Steps**
1. Split work into tasks touching **different files**, using plan.md to see what's independent. Tasks sharing files run sequentially in one session.
2. One worktree per task: `claude --worktree feature-auth` in one terminal, `claude --worktree fix-rate-limit` in another.
3. Start with **2–3 sessions**. The ceiling is how many streams one person can review properly — add sessions only while review keeps up.
4. Turn repeated jobs into subagents in `.claude/agents/` (templates in `templates/agents/`): **verifier** (runs the app, checks behavior vs plan.md, reports only), **code-simplifier** (strips needless complexity after the main agent finishes), **researcher** (explores the codebase and reports back without flooding main context). Commit them.

**Governance:** more sessions → more output, so controls must come from repo config (hooks, permissions apply to all sessions); everything is attributed to the engineer who ran it. **Measure:** leading — concurrent sessions per engineer while review quality holds (OpenTelemetry export); share of the day steering vs waiting. Lagging — changes merged per engineer per week alongside rework rate.
