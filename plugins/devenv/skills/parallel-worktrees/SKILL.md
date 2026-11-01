---
name: parallel-worktrees
description: Sets up a project so several coding agents can build features in parallel, each in its own git worktree with its own auto-started dev server at http://<worktree>.<app>.localhost (one shared Caddy proxy, no port clashes, separate cookies per worktree) and one shared database or backing services. Claude Code SessionStart/SessionEnd hooks boot and stop everything, so creating a worktree is the only step. Use when the user wants to run multiple agents or worktrees on the same app at once, asks for per-worktree URLs, local domains or *.localhost instead of ports, fixes port 3000 conflicts between worktrees, or says "set up parallel worktrees / parallel agents / the worktree setup" in a project. Supports Next.js, Vite and other dev servers, with plain Postgres (Docker Compose) or local Supabase.
---

# Parallel worktrees: one URL per worktree, one shared DB, auto-boot

Install a small, tested set of scripts and hooks into the current project. When you finish,
starting an agent session in any worktree (`claude --worktree <name>`, an IDE's worktree feature, or
`git worktree add`) does all of this without the user running anything: copy env files, install
deps, start the shared services, migrate, start the dev server on a free port, and publish it at
`http://<name>.<app>.localhost`. When the session ends, the dev server stops.

Read `references/how-it-works.md` if you need the reasoning or hit something odd. Read
`references/stacks.md` for the per-stack values in step 3. The working reference implementation is
the private repo `kaldren/multiagent-worktrees` (local: `~/Projects/multiagent-worktrees`).

## 1. Inspect the project and confirm

Work out, without asking where you can:
- **App name** → `APP_DOMAIN=<app>.localhost` (short, kebab-case, from the repo or package name).
  It must not clash with another project's domain in `~/.local/state/localhost-proxy/sites/`.
- **Dev server**: framework and the current `dev` command (package.json scripts, framework config).
- **Package manager** from the lockfile → `INSTALL_CMD` and the run command (`{{RUN}}`).
- **Backing services**: `docker-compose.yml`/`compose.yaml` (DB port, whether `name:` is pinned),
  `supabase/config.toml` (project_id, ports), or none. Also the migration tool.
- **Gitignored files a worktree needs** (`.env`, `.env.local`, ...) → `.worktreeinclude`.
- Existing `.claude/settings.json` hooks and `CLAUDE.md`/`AGENTS.md` that you must merge into, not overwrite.

State the plan in two or three lines (domain, dev command, services, migrations, files you'll touch)
and continue unless the user objects.

## 2. Prerequisites

- Git repo with at least one commit (worktrees branch from a commit). If there are no commits,
  ask before making the first one.
- Caddy: `command -v caddy`. If missing, ask, then `brew install caddy`.
- Docker running if the services need it (`boot.sh` can start Docker Desktop itself later).
- Port 80 free or already Caddy's: `lsof -nP -iTCP:80 -sTCP:LISTEN`. Another Caddy from this
  setup is fine, since it's shared. Anything else: stop and tell the user.

## 3. Install the files

Copy from this skill's `templates/` into the project:

| Template | Destination | Notes |
|---|---|---|
| `scripts/*.sh`, `scripts/hooks/session.sh` | `scripts/` (same layout) | `chmod +x`. If `scripts/` holds unrelated files with these names, ask. |
| `scripts/devenv.conf` | `scripts/devenv.conf` | Fill in per `references/stacks.md`. |
| `scripts/migrate.mts` | `scripts/migrate.mts` | **Only** for plain Postgres with no migration tool. |
| `settings.json` | `.claude/settings.json` | Merge the three hook events into existing `hooks` and keep the user's hooks. Must be committed (not `settings.local.json`) so every worktree has it. |
| `CLAUDE.section.md` | append to `CLAUDE.md` (create if absent) | Replace `{{APP_DOMAIN}}`, `{{RUN}}`, `{{MIGRATION_HOW}}`, `{{DESTRUCTIVE_CMDS}}`. Drop the DB section if there are no services. |

Then:
- `.worktreeinclude`: list the gitignored env/config files a worktree needs, one per line.
- `.gitignore`: add `.dev/` and `.claude/worktrees/`.
- package.json scripts, if it's a JS project. Keep the user's original dev command in `DEV_CMD`,
  then point `dev` at the wrapper:
  `"dev": "bash scripts/dev.sh"`, `"boot": "bash scripts/boot.sh"`, `"halt": "bash scripts/halt.sh"`,
  `"wt": "bash scripts/wt.sh"`, `"url": "bash scripts/url.sh"`, `"proxy": "bash scripts/proxy.sh"`.
  Don't use the script name `up`: `pnpm up` is a built-in.
- Apply the stack-specific config from `references/stacks.md`: Vite `allowedHosts`, Supabase
  `site_url`/`additional_redirect_urls` and unique ports, compose `name:`, Django/Rails host allowlists.

## 4. Commit

New worktrees branch from a commit, so the setup has to be committed before it reaches them.
Show the user the changed files and ask before committing. Worktrees created earlier won't have
the scripts until they merge or rebase from the main branch.

**Where new worktrees branch from:** `claude --worktree` branches from the remote's default branch
(`origin/HEAD`), not local HEAD, unless `worktree.baseRef` is `"head"`. If there's a remote, a local-only
setup commit doesn't reach new worktrees: they come up with the old code and no hooks. Ask the user to
push it, or (only if they prefer) add `"worktree": { "baseRef": "head" }` to `.claude/settings.json`.
Other worktree tools have their own base-branch rules; check them the same way.

## 5. Verify end to end

Run these and fix what fails. Don't report success without them:
1. **Main checkout:** `bash scripts/boot.sh` prints `... is up (started): http://<app>.localhost`, and
   `curl -s -o /dev/null -w '%{http_code}' http://<app>.localhost` returns 200 (or the app's normal status).
2. **Unknown host:** `curl http://nope.<app>.localhost` returns Caddy's 502 message.
3. **Worktree through Claude Code**, non-interactively:
   `claude -p --worktree pw-check --allowedTools Bash "Without starting anything, report the dev URL from your session context and the output of: curl -s -o /dev/null -w '%{http_code}' <that URL>; bash scripts/wt.sh ls"`.
   Expect `http://pw-check.<app>.localhost`, status 200, and `pw-check ... up`. Afterwards,
   `bash scripts/wt.sh ls` shows `stopped` (the SessionEnd hook ran). Interactive sessions require
   the user to have trusted the folder once (`claude` in the repo root).
4. **Clean up:** `bash scripts/wt.sh rm pw-check --force && git branch -D worktree-pw-check`.
5. **If services exist:** stop them, then rerun `bash scripts/boot.sh` and check it brings them back.

On failure, read `<checkout>/.dev/boot.log` and `.dev/dev.log`, and `~/.local/state/localhost-proxy/caddy.log`.

## 6. Tell the user

- The URLs: main `http://<app>.localhost`, worktrees `http://<name>.<app>.localhost`.
- That from now on they only start an agent in a new worktree, e.g. `claude --worktree <feature>`.
- Manual controls: `scripts/wt.sh ls|new|rm|prune`, `scripts/boot.sh`, `scripts/halt.sh`, `scripts/proxy.sh routes`.
- After a reboot, nothing to do: the next session's boot hook starts Caddy, Docker and the services.
- The shared-DB trade-off: migrations must be additive, and two branches can pick the same
  migration number.
- In Codex or other agents without these hooks, run `bash scripts/boot.sh` at the start of a session.

## Updating an already-installed project

Diff the project's `scripts/` against `templates/scripts/`. Bring over improvements and keep the
project's `devenv.conf`. Re-run step 5.
