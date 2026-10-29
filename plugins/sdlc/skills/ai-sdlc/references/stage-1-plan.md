# Stage 1 — Plan: capture as intent.md (P1)

> Ideas stop waiting for someone to write them up. Intent is captured once, in the originator's own words, as a version-controlled artifact the next stage can act on.

**Traditional:** backlog entries → user stories → story points → refinement meetings; ownership changes at each handoff, so what reaches engineering is several steps removed from what the originator meant.
**AI-native:** the originator brainstorms with Claude and commits `intent.md` — what is wanted, why, and under which constraints. Intents can also come from a ticket or from a production alert (Stage 6).

## Part A — One-time setup of the intent home

**Prerequisites:** none.

**You do**
- Decide who may write to the intent home and who is product owner (accepts/rejects intents).
- If non-engineers will contribute: give them claude.ai or Cowork access with a GitHub (or other VCS) connector so Claude can commit markdown for them — they never need git.
- Regulated/legacy tracker: decide the source of truth for intents (see `governance-and-metrics.md`).

**I'll do**
1. Create the home. Default: `intent/` in the product repo, one folder per change: `intent/<YYYY-MM-DD>-<slug>/intent.md`. Later `spec.md` and `plan.md` sit beside it, so the whole chain for a change is in one folder. (Separate intent repo only if intent spans many repos; in a monorepo it's a directory.)
2. Copy `templates/intent.md` to `intent/_TEMPLATE.md`, adapted to the profile (add a `Tracker:` line if there's a legacy record).
3. Add `intent/README.md` (5–10 lines): how to propose an intent, statuses (`draft` → `accepted` | `rejected`), who accepts.
4. Optionally add CODEOWNERS so the product owner is required reviewer on `intent/**`.
5. Optional, once the template is stable: package the intent-writing procedure as a project skill (`.claude/skills/write-intent/SKILL.md`) so teammates without this coach skill get the same procedure. Signed off by a lead.

**Done when:** `intent/_TEMPLATE.md` and `intent/README.md` are committed.

## Part B — Capturing an intent (`/ai-sdlc intent`)

1. **Let the originator describe the problem in their own words** — what they can't do today, who's affected, what better looks like, what's out of scope. No formal language required.
2. **Brainstorm until it's concrete.** Ask the questions an analyst would — one or two at a time, not a questionnaire:
   - Who exactly is affected, and how often?
   - What does success look like, measurably?
   - What constraints apply (data, auth, performance, budget, deadlines, systems that can't change)?
   - What's explicitly out of scope?
   - What don't we know yet? (→ Open questions)
3. **Write `intent.md` from the template**, in the originator's terms — not a spec. No implementation decisions; that's Stage 2's job.
4. **Have the originator correct anything you misunderstood.** Show the file, ask what's wrong.
5. **Commit it** to the intent home on a branch (`intent/<slug>`) with status `draft`. The product owner accepts by merging (status → `accepted`) or rejects by closing the PR. For a solo dev: re-read it the next morning, then merge.

**Commit message:** `intent: <slug> — <one-line problem>`

## Governance
Evidence = the committed intent.md with author, timestamp and revision history. The accept/reject decision is the merge or the closed review — that's what sends an intent into Stage 2.

## Measure
- **Leading:** time from first conversation to committed intent.md (git history). Expect weeks → hours.
- **Lagging:** survival rate — share of intents accepted rather than closed; and count of intent.md edits made *after* the first spec.md commit for the same change (signals the intent was unclear).
