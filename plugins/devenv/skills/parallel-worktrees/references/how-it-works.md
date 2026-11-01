# How it works, and why

## The problem
Parallel agents each need their own checkout (git worktree) and their own running app. A naive
setup collides on port 3000. Moving to `localhost:3001/3002/…` is still subtly broken: **cookies
are scoped by host, not by port**, so every worktree shares one cookie jar, and logging in or out
in one changes the session in the others. Loopback aliases (`127.0.0.2`, …) need
`sudo ifconfig lo0 alias` again after every macOS reboot, and IPs don't say which worktree is which.

## The approach
- `*.localhost` always resolves to 127.0.0.1 (RFC 6761; Chrome, Firefox, Safari, curl), so there's
  no `/etc/hosts` or dnsmasq. Each `<name>.<app>.localhost` is its own origin with its own cookies.
- One Caddy on :80 for all projects (no sudo needed on macOS). Each dev server picks a free port
  (hash of the hostname into 3100–3999, then probe), writes `~/.local/state/localhost-proxy/sites/<host>.caddy`
  and reloads Caddy. When it stops, it removes the file. Unknown hosts get a 502 that says what to run.
- One shared instance of backing services per project (DB, Supabase). Cheap and simple; the cost is
  that schema changes must be additive (rules go in CLAUDE.md).
- Claude Code hooks (`.claude/settings.json`):
  - `SessionStart` (startup|resume) → `scripts/hooks/session.sh start` → `boot.sh`: copy
    `.worktreeinclude` files, install deps, start services, migrate, start Caddy, start the dev
    server detached, wait for the URL, and print a message (stdout becomes the agent's context).
  - `SessionEnd` → `halt.sh`: stop the worktree's dev server (the main checkout's stays up).
  - `CwdChanged` (async) → boot if Claude entered a worktree mid-session (EnterWorktree). Not yet
    verified end-to-end.
- Worktree identity = `basename` of `git rev-parse --show-toplevel`; "main" = the parent of the shared
  `--git-common-dir`. That works for `claude --worktree` (`.claude/worktrees/<name>`, branch
  `worktree-<name>`), `git worktree add` anywhere, and IDEs that put worktrees elsewhere.

## Lessons learned (don't regress these)
- Other tools don't honour `.worktreeinclude`, so `boot.sh` copies those files from the main checkout itself.
- Hooks get `cwd` in stdin JSON. Use it, not the hook process's own cwd or `$CLAUDE_PROJECT_DIR`, to find the checkout.
- The dev server must be fully detached (`perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV'`, all fds
  redirected) or it dies with the hook. Store its pid (= process group id) so `halt.sh` can
  `kill -TERM -- -<pgid>`. `dev.sh`'s EXIT trap then removes the route.
- `dev.sh` must not `exec` the server, or the trap never runs.
- `SessionEnd` hooks get a 1.5s budget by default; set `"timeout": 15`.
- Docker Compose: pin `name:` or each worktree spawns its own DB.
- `boot.sh` prints only the context message on stdout. Everything else goes to stderr, which the hook wrapper sends to `.dev/boot.log`.
- `claude --worktree` branches from `origin/HEAD` by default, not local HEAD. An unpushed setup
  commit isn't in new worktrees: they run old scripts or none. Push it, or set `worktree.baseRef: "head"`.
- `claude -p --worktree` leaves the worktree locked; `wt.sh rm <name> --force` unlocks it first.

## Reference implementation
Private repo `kaldren/multiagent-worktrees` (local: `~/Projects/multiagent-worktrees`): a Next.js +
Postgres feature board showing the per-worktree banner, the shared DB and cookie isolation.
