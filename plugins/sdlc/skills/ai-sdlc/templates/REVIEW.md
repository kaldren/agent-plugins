# Review instructions

## Passes
Run three passes and tag each finding with its pass:
- **Bugs:** logic errors, broken edge cases, subtle regressions
- **Security:** injection risks, authentication gaps, secrets or PII in logs
- **Compliance:** the change matches its `intent/<change>/spec.md` and `plan.md`, and our design principles (CLAUDE.md, `.claude/skills/`)

## What Important means here
Reserve **Important** for findings that would break behavior, leak data or breach a policy. Style and naming are **Nits**.

## Cap the nits
Report at most five nits per review; summarize the rest as a count.

## Keep CLAUDE.md honest
- If this PR repeats a mistake already flagged in an earlier review, propose the CLAUDE.md line that would prevent it.
- If the change makes something in CLAUDE.md outdated, say so.

## Do not report
- Generated files under <paths>
- Anything CI already enforces (formatting, lint rules, type errors)
