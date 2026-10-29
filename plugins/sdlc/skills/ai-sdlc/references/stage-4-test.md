# Stage 4 — Test

> Every session checks its own work before a human sees it, and the configuration that steers the agent gets regression-tested like the code it writes.

---

## P8 Give Claude a feedback loop

Always give Claude a way to verify its own work — tests, a build, a screenshot diff — so it fixes its own mistakes before an engineer sees them. (Not the same as the verifier subagent: the loop runs throughout the task; the verifier is one way to package the *final* check in a fresh context, uncolored by the assumptions that produced the code.)

**Prerequisites:** none. **Infrastructure:** a test suite and a build that each run locally with one command. For UI work, a way for Claude to *see* the result — a browser tool (Claude in Chrome, Playwright MCP) or a screenshot utility via MCP.

**You do:** for UI projects, install/enable a browser or screenshot MCP. Decide what "done" means for this project in one sentence.

**I'll do**
1. If checking work takes several commands or environment knowledge, wrap it in **one target** (`make test`, `npm test`, `just check`…) that exits non-zero on failure.
2. In CLAUDE.md's Commands section, list each command **with an example of healthy output**.
3. Add the verification block (from `templates/CLAUDE.md`): run build, test, lint before reporting any task complete and paste the output; if a test fails, fix the code, not the test.
4. Teach the user to **state quantifiable targets** in prompts: "all tests in test_status.py pass", "the screenshot matches the attached mock", "the endpoint returns 200 with the new field".
5. **Bug fixes — failing test first:** reproduce the bug as a test, run it, confirm it fails *for the expected reason*, commit the test. Only then fix, with `AI_SDLC_FIX_MODE=1` so the test-protection hook stops the agent editing the test. A test that existed before the fix and that the agent couldn't rewrite is proof the bug is gone.
6. **UI work — visual loop:** implement → screenshot → compare with the mock → adjust. Two or three rounds is normal.
7. **Protect the loop** — install `protect-tests.sh` (P6). Alternative: reject any fix PR whose diff touches tests.

**Governance:** enforced = verification before "done", and the block on editing tests during a fix (as hooks where it must be guaranteed). Evidence = literal toolchain output pasted in the session and the PR check run. Approver = code owner, who can focus on intent and risk because mechanical evidence is attached.
**Measure:** leading — first-pass CI success rate for agent-written changes. Lagging — review time per PR; change failure rate.

**Done when:** a fresh session asked to make a trivial change runs the checks unprompted and shows the output.

---

## P9 Continuous evals in CI

Evals are the AI-native equivalent of stage-gate QA: a suite that runs whenever the agent's configuration changes (new model, rewritten CLAUDE.md, changed skill or hook) and says whether the agent still does the work to the same standard. It's a **live suite** — as models improve, old cases stop discriminating; add new ones from monitoring and incidents.

**Prerequisites:** CLAUDE.md (P4) and feedback loop (P8). **Infrastructure:** CI that can run Claude Code non-interactively; an API key (or Bedrock/Vertex/Foundry credentials) with budget for eval runs.

**You do:** add the API key as a CI secret (`ANTHROPIC_API_KEY`); set a monthly budget; pick 20–50 real recent tasks with known accepted outcomes (solo: start with 10).

**I'll do**
1. Turn each task into `evals/<id>.json` (`templates/evals/example-eval.json`): the prompt plus the checks that define acceptable — tests pass, lint clean, behavior unchanged, policy followed. Good sources: merged PRs (revert the change, prompt with its intent, check with its tests).
2. Add `evals/check.sh` (`templates/evals/check.sh`) and the workflow (`templates/workflows/agent-evals.yml`): runs on PRs touching `CLAUDE.md` or `.claude/**`, and nightly. Each eval runs from a clean checkout.
3. **Gate configuration changes on the pass rate:** a skill change that drops it gets reviewed before merge (make the job a required check, or compare against the last nightly).
4. **Every production incident gets an eval**, written by the team that owned the incident, kept as a regression test.

Offline evals on a cadence instead of every change are fine for some teams — say so if cost matters.

**Governance:** pass-rate threshold as a merge check; runs logged for comparison over time; the team owning the config change approves it.
**Measure:** leading — pass rate over time; time for an incident to become a permanent eval. Lagging — regressions caught in CI vs regressions found in production.
