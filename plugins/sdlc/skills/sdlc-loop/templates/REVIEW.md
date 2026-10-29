# Review instructions

Place this file at the repo root as `REVIEW.md`. Every PR gets the same passes.

## Passes
Run three passes and tag each finding with its pass:
- **Bugs**: logic errors, broken edge cases, regressions, unhandled failures.
- **Security**: injection, auth gaps, secrets in the diff, PII in logs, unsafe deps.
- **Compliance**: the diff matches `spec.md` (every acceptance criterion covered) and `plan.md` (files, order, proof); any deviation is recorded in `plan.md`'s Deviations section; test files were not weakened; `CLAUDE.md` is still accurate after this change.

## Severity
- **Important**: would break behaviour, leak data, breach a policy, or diverge from the accepted spec/plan without a recorded deviation.
- **Nit**: style, naming, minor clarity.

## Caps
Report at most five nits per review; summarize the rest as a count.

## Do not report
Generated files, lockfiles, and anything CI already enforces (typecheck, lint, formatting).

## Feedback loop
If a finding repeats a mistake already caught in an earlier PR, add the correction to `CLAUDE.md` in this PR and say so in the finding.

## Output
Findings grouped by pass, severity first, each with file:line and a one-line fix. End with the verification output check: is `pnpm typecheck && pnpm test` output present in the PR? Findings inform the human; they never approve or block on their own.
