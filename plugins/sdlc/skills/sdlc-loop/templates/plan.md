# Plan: <short title>

From: intent.md + spec.md in intent/<folder>/. Status: draft.
Written in plan mode; no files changed while writing this.

## Files that change
- `path/to/file.ts` (new | modified | deleted) — what and why
- `path/to/file.test.ts` (new) — covers AC1, AC2

## Order of work
Numbered steps. Mark which can run in parallel worktrees (disjoint files) with [P].
1. …
2. …

## What this could break
Existing behaviour, callers, and data paths touched by each step.

## Riskiest step
Which one, why, and how it is checked before moving on.

## Alternatives rejected
Approaches considered and why not.

## Proof
What demonstrates each acceptance criterion from spec.md:
- AC1 → `pnpm test -- <file>` green
- AC2 → screenshot matches mock at `…`
- All → `pnpm typecheck && pnpm test` output pasted in the PR

## Deviations
Filled in during implementation, in the same commit as the deviation.
- <date> — what changed from the plan and why
