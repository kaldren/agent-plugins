# Kickoff questions

Ask these at the start of each project to tailor the roadmap. Use AskUserQuestion, up to 4 questions per round, 2–4 options each (the tool adds "Other" automatically). **Skip any question the repo scan already answered** — state what you detected instead ("I see a Next.js app on GitHub with Vitest; correct me if that's wrong"). Skip whole rounds that the user's ambition makes irrelevant.

After each round, write the answers into the Profile section of `docs/ai-sdlc/progress.md`, with one line on what each answer changes in the roadmap.

---

## Round 1 — The shape of the project (always ask)

**Q1. Project state** — *header: "Project"*
- New project (empty or near-empty repo)
- Existing codebase, not using Claude Code yet
- Existing codebase, already using Claude Code
→ New: Phase 0 includes creating the repo, stack choice and a one-command test/build. Existing: start from `/init` and the real commands. Already using: audit what exists (CLAUDE.md quality, hooks, skills) and skip done plays.

**Q2. Who works on it** — *header: "Team"*
- Just me (solo)
- Small team (2–10 engineers, informal process)
- Several teams / organization with defined roles
- Regulated organization (audit, change board, separation of duties)
→ Drives the tailoring rules in `roadmap.md` (ceremony, managed settings, approval routing).

**Q3. How far do you want to go** — *header: "Ambition"*
- Foundations: CLAUDE.md, feedback loop, intent→spec→plan by hand
- Through review: + guardrail hooks, agentic PR review, parallel sessions
- Through deploy: + approval gates, Claude in CI/CD, evals
- Full closed loop: + monitoring that writes new intents, Claude on call
→ Sets where the roadmap stops (can be extended later).

**Q4. Where does the code live** — *header: "VCS host"*
- GitHub
- GitLab
- Azure DevOps / Bitbucket / other
- No remote yet
→ GitHub unlocks `/install-github-app`, claude-code-action and the managed Code Review service. Others: Claude runs via `claude -p` in their CI runner.

## Round 2 — Process and policy

**Q5. Where do work items / requirements live today** — *header: "Tracker"*
- Nowhere formal (ideas in my head / chat)
- GitHub/GitLab Issues
- Jira / Linear / Azure Boards
- A regulated requirements tool (e.g. Polarion, DOORS, ServiceNow)
→ Decides the source-of-truth configuration (repo-as-truth, legacy-as-truth, or linkage) — see `governance-and-metrics.md`. A tracker with an MCP connector lets Claude read/write records in the same session.

**Q6. Who holds the roles** (ask as free text if Team ≠ solo) — *header: "Roles"*
Product owner (accepts intents and specs), tech lead (accepts higher-risk plans, owns REVIEW.md), policy owners (security, brand, UX, compliance), release manager (authorizes production), platform engineer (hooks, CI, evals).
→ Names go into the progress file; they become the approvers in templates (CODEOWNERS, hook messages, REVIEW.md).

**Q7. Which policies should be encoded as skills** — *header: "Policies", multiSelect*
- Security (auth, input validation, secrets, PII)
- Brand / UX / accessibility
- API or architecture conventions
- Compliance / regulatory
→ Each selected policy becomes a skill play (Stage 2/3). Ask which one is applied *most inconsistently today* — that's the first skill to write.

**Q8. Data sensitivity** — *header: "Data"*
- No sensitive data
- Personal data (PII)
- Regulated data (finance, health, government)
→ Raises the default risk class, pulls secrets-blocking hooks, permission deny rules and sandboxing earlier, and decides which changes need a tech-lead sign-off.

## Round 3 — Engineering setup (skip if ambition = Foundations, except Q11)

**Q9. CI platform** — *header: "CI"*
- GitHub Actions
- GitLab CI
- Other (Jenkins, CircleCI, Azure Pipelines…)
- No CI yet
→ Chooses workflow templates. No CI: add a minimal one in Phase 0, because evals, review and gates all run there.

**Q10. Model access for automation** — *header: "Model access"*
- Anthropic API key (or Claude subscription for local use only)
- AWS Bedrock
- Google Vertex AI
- Microsoft Foundry
→ Determines CI secrets/env vars and whether traffic must stay on the organization's cloud agreement.

**Q11. Does the project have a UI** — *header: "UI"*
- Yes, web UI
- Yes, mobile/desktop UI
- No (API, CLI, library, data)
→ UI work needs a visual feedback loop (browser or screenshot tool via MCP) in Stage 4, and Claude Design for mocks in Stage 2.

**Q12. Deployment** — *header: "Environments"*
- Not deployed yet
- One environment (prod only)
- Dev + prod
- Dev + staging + prod
→ Sets the per-environment autonomy tiers and where rollback gets rehearsed (staging, or a stand-in if there is none).

## Round 4 — Operations (only if ambition = Full closed loop)

**Q13. Metrics store** — *header: "Metrics"*
- Prometheus / Grafana
- Datadog / New Relic / cloud-native monitoring
- Only CI and git data
- Nothing yet
→ "Only CI/git" is fine: CI test-failure rate or PR cycle time is the recommended first control band anyway.

**Q14. Team chat** — *header: "Chat"*
- Slack
- Microsoft Teams
- Other / none
→ Slack enables Claude Tag as an incident first responder (`/install-slack-app`).

**Q15. Protected code** (free text) — *header: "Protected"*
"Are there paths Claude must never edit (generated code, frozen packages, migrations, infra) or that need a change ticket?"
→ Seeds `.claude/protected-paths.txt` and `.claude/change-controlled-paths.txt` for the build hooks.

## Always end kickoff with

**Q16. Pilot change** (free text) — "What's one small, real change you'd like to ship through the new process first?"
→ This becomes the pilot intent in Phase 2. A good pilot is small, low-risk and touches code that has tests.
