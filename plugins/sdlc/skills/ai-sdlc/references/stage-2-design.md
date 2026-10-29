# Stage 2 — Design: requirements and design → spec.md (P2)

> Requirements and design collapse into one session. Policy is applied while the spec is written, not discovered in a review weeks later.

**Traditional:** analysts formalize requirements; designers parse them back into a design. Slow and lossy.
**AI-native:** one prompted session turns the accepted `intent.md` into `spec.md`, constrained by the organization's skills (brand, security, compliance, UX), with **areas of concern flagged**. The product owner reviews the spec but doesn't write it.

**Prerequisites:** an accepted intent.md (P1); policies written as skills (P5) — at least the one that matters most for this change. If no policy skill exists yet, do P5 first (see `stage-3-build.md` → Skills); it takes ~30 minutes for one policy.

**You do**
- Be (or name) the product owner who reviews the spec.
- Resolve each flagged concern with its policy owner before engineering sees the spec.
- Decide whether the spec progresses to build; consult a tech lead if the change is higher risk.

## Producing a spec (`/ai-sdlc spec <intent path>`)

1. **Load context:** the intent.md, CLAUDE.md, and the relevant policy skills. For changes to an existing codebase, read the code the change will touch so the spec fits reality.
2. **Run the spec pass.** The playbook's prompt, which is what you're executing:
   > Read the attached intent.md and produce a requirements and design spec for integrating it into our existing codebase. Apply the skills available to you so the plan conforms to our brand guidelines, security policies and UX standards. Document the spec fully as spec.md, ready to hand to the engineering team. Describe clearly any areas of concern, especially where you cannot satisfy contradicting policies.
3. **Write `spec.md`** beside the intent using `templates/spec.md`. Record which skills (and their git versions — `git log -1 --format=%h -- .claude/skills/<name>`) were applied; that's part of the governance record.
4. **Review with the product owner, concerns first.** Walk the "Areas of concern" section before anything else — these are the points an analyst would have escalated. Then: does the spec solve the stated problem? Are the intent's open questions answered or explicitly carried forward?
5. **Commit `spec.md`** alongside intent.md (PR from a `spec/<slug>` branch). The pair records what was asked for and what was decided.
6. **Decision:** the product owner (never the agent) accepts → status `accepted`, which starts Stage 3 plan mode.

**UI work:** after the intent is accepted, the product owner can mock the design in Claude Design (beta), iterate, and export to Claude Code. Link the mock from the spec; it becomes the visual target for the Stage 4 screenshot loop.

## Automating it later (Phase 5)
Run by hand first. Then codify as a project slash command (`templates/commands/spec-from-intent.md` → `.claude/commands/`). Finally, make the merge of an intent the trigger: a non-interactive CI job (`claude -p` with the skills loaded) writes spec.md and opens a PR. From then on the product owner's first involvement is the review. See `stage-5-deploy.md` → CI/CD for plumbing.

## Governance
Live policy is read and applied while the spec is written. Spec, the prompt that produced it, and skill versions are logged in version control. Product owner signs off; flagged concerns route to named policy owners.

## Measure
- **Leading:** time between intent.md commit and spec.md commit for the same change (two git timestamps) vs the old requirements+design cycle.
- **Lagging:** requirements rework after build starts — spec.md commits dated after the first plan.md commit for the same change.
