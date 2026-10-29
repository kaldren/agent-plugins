# <Project name>

<One line: what this is and who uses it.>

## Commands
- Build: `<cmd>` (healthy output ends with "<…>")
- Test: `<cmd>` (all green; integration tests: `<cmd>`, needs <docker/…>)
- Lint: `<cmd>` (zero warnings; runs in CI)
- Run locally: `<cmd>`

## Conventions
- <language/framework versions; things not to introduce>
- <domain rules, e.g. money is always Decimal, never float>
- <testing rule, e.g. every endpoint needs an integration test>

## Architecture
- <dir>/ — <responsibility>
- <generated/ or schemas/ — never edit generated code>

## How we work (AI-SDLC)
- Every change has `intent/<date>-<slug>/{intent,spec,plan}.md`. Read them before working on the change.
- Start non-trivial work in plan mode; when implementation departs from plan.md, update it in the same commit.
- Review policy lives in REVIEW.md.

## Verifying your work
- Build: `<cmd>` (must finish with "<success marker>")
- Test: `<cmd>` (all green; never skip or delete a failing test)
- Lint: `<cmd>` (zero warnings)
Run all three before reporting any task complete, and paste the output.
If a test fails, fix the code, not the test.

## Things Claude gets wrong
<!-- When Claude makes the same mistake twice, add the correction here. Keep this file under a page. -->
- <e.g. don't bump dependency versions; the platform team owns them>
