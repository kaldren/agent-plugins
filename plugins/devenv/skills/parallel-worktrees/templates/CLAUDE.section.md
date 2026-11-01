# Parallel-agent setup (read before running anything)

You may be one of several agents, each in its own git worktree, all sharing ONE set of
backing services (database etc.) and ONE local proxy.

## The app is already running
- A SessionStart hook (`.claude/settings.json` → `scripts/boot.sh`) has already installed deps,
  started the shared services, run migrations and started THIS checkout's dev server in the
  background. Your session context states the URL. It hot-reloads: edit code, reload the URL.
- URL: `http://<worktree-name>.{{APP_DOMAIN}}` (main checkout: `http://{{APP_DOMAIN}}`).
  `bash scripts/url.sh` prints it. Use it for curl/browser checks, never `localhost:3000`.
- Do NOT start the dev server yourself (`{{RUN}} dev`, `next dev`, `vite`, ...). If `scripts/url.sh`
  says "not running", run `bash scripts/boot.sh`. Output is in `.dev/dev.log`.
  After adding dependencies or changing config: `bash scripts/halt.sh --all; bash scripts/boot.sh`.
- `bash scripts/wt.sh ls` lists every worktree, its URL and status. Leave other worktrees' servers alone.

## The database is shared
- Other agents are reading and writing the same database right now.
- Schema changes: create a NEW migration ({{MIGRATION_HOW}}). Additive and backward compatible
  only (new tables, nullable/defaulted columns); no drops or renames: other worktrees' code
  still runs against the same schema. Never edit a migration that's already applied.
- Never reset or wipe it: no {{DESTRUCTIVE_CMDS}}, no TRUNCATE/DROP.
- Test data you insert is visible to everyone; make it identifiable.

## If something is down
- Connection refused, 502 from the proxy, DB refused: run `bash scripts/boot.sh` (idempotent).
