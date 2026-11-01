# Per-stack configuration

Fill `scripts/devenv.conf` and apply the extra config for the project's stack. `{{RUN}}` is the
package manager's run command (`pnpm`, `npm run`, `yarn`, `bun run`) and INSTALL_CMD follows the lockfile:

| Lockfile | INSTALL_CMD |
|---|---|
| pnpm-lock.yaml | `pnpm install --prefer-offline --silent` |
| package-lock.json | `npm install --prefer-offline --no-audit --no-fund --silent` |
| yarn.lock | `yarn install --prefer-offline --silent` |
| bun.lock / bun.lockb | `bun install` |

## Next.js (13+, App Router or Pages)
- `DEV_CMD='next dev --port $PORT'`
- Next 16 already allows dev requests from `**.localhost`, so nothing to configure. On Next 15 or
  older, if the browser console shows blocked `/_next/*` requests, add
  `allowedDevOrigins: ['{{APP_DOMAIN}}', '*.{{APP_DOMAIN}}']` to `next.config`.
- Server actions work through Caddy because Caddy preserves the Host header.
- Next 16 writes an `AGENTS.md` on `next dev`; if the project uses CLAUDE.md, import it with `@AGENTS.md`.

## Vite (React/Vue/Svelte, etc.)
- `DEV_CMD='vite --port $PORT --strictPort'`
- Vite rejects unknown Host headers: add `server: { allowedHosts: ['.{{APP_DOMAIN}}'] }` to
  `vite.config` (the leading dot covers the main domain and all subdomains).
- HMR goes through the proxy over HTTP on :80. If HMR doesn't connect, add `server.hmr.clientPort: 80`.

## Plain Postgres in Docker Compose
- Compose file MUST pin the project name (`name: <app>` at the top level). Otherwise each worktree
  folder gets its own compose project and a separate DB container, which defeats the shared DB.
- Bind to a project-unique host port, e.g. `"127.0.0.1:54329:5432"`, with a named volume and a
  `pg_isready` healthcheck so `up --wait` works.
- `SERVICES_CHECK='nc -z 127.0.0.1 <port>'`, `SERVICES_UP='docker compose up -d --wait'`, `NEEDS_DOCKER=1`
- Migrations: use the project's tool (Drizzle: `drizzle-kit migrate`, Prisma: `prisma migrate deploy`,
  never `migrate dev`/`reset`). If none, copy `templates/scripts/migrate.mts` (advisory lock +
  `schema_migrations`) and set `MIGRATE_CMD='node --env-file=.env.local scripts/migrate.mts'`.
- Destructive commands to forbid in CLAUDE.md: `docker compose down -v`, `prisma migrate reset`.

## Local Supabase (supabase CLI)
- One Supabase stack per project, shared by all its worktrees: the stack is keyed by `project_id`
  in `supabase/config.toml`, which is identical in every worktree. Give each project unique ports
  in `config.toml` (`[api] port`, `[db] port`, `shadow_port`, `[studio]`, `[inbucket]`/`[local_smtp]`,
  `[db.pooler]`) so several projects can run at once.
- `SERVICES_CHECK='supabase status >/dev/null 2>&1'`, `SERVICES_UP='supabase start'`, `NEEDS_DOCKER=1`.
  The first `supabase start` can take a minute or more; the hook timeout (300s) covers it.
- `MIGRATE_CMD='supabase migration up --local'` (applies pending migrations without wiping data).
- Auth redirects must accept every worktree host. In `config.toml`:
  `site_url = "http://{{APP_DOMAIN}}"` and
  `additional_redirect_urls = ["http://{{APP_DOMAIN}}/**", "http://*.{{APP_DOMAIN}}/**"]`, then
  restart the stack once (`supabase stop && supabase start`).
- Auth cookies are host-scoped, so each worktree has its own session. That's the point; you log
  in once per worktree.
- `.worktreeinclude`: `.env.local` (holds `NEXT_PUBLIC_SUPABASE_URL` / keys).
- Destructive commands to forbid in CLAUDE.md: `supabase db reset`, `supabase stop --no-backup`.
- New migrations: `supabase migration new <name>`, then `supabase migration up --local`.

## No backing services
- Leave `SERVICES_CHECK`, `SERVICES_UP` and `MIGRATE_CMD` empty and drop the database section from the CLAUDE.md block.

## Non-JS dev servers (Django, Rails, Go, ...)
- Any command that binds to `$PORT` works: `DEV_CMD='python manage.py runserver 127.0.0.1:$PORT'`,
  `DEV_CMD='bin/rails server -p $PORT'`. Set `INSTALL_CMD` to the project's install step or leave it empty.
- Frameworks with host allowlists need `.{{APP_DOMAIN}}` added (Django `ALLOWED_HOSTS`, Rails `config.hosts`).
