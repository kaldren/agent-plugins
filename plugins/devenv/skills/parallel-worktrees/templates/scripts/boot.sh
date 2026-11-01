#!/usr/bin/env bash
# Bring this checkout fully up, idempotently:
#   env files → deps → shared services → migrations → Caddy → dev server (detached) → wait for URL.
# Runs from the SessionStart hook, so starting an agent session in a worktree is all you do.
source "$(dirname "$0")/lib.sh"
cd "$REPO_TOP"
log() { echo "[boot] $*" >&2; }

# 0. gitignored files listed in .worktreeinclude. Claude Code copies these itself, but other
#    tools (IDEs, plain `git worktree add`) don't, so fill them in from the main checkout.
if [[ "$REPO_TOP" != "$MAIN_ROOT" && -f .worktreeinclude ]]; then
  while IFS= read -r f; do
    [[ -z "$f" || "$f" == \#* || -e "$f" ]] && continue
    [[ -e "$MAIN_ROOT/$f" ]] && { log "copying $f from main checkout"; cp -R "$MAIN_ROOT/$f" "$f"; }
  done < .worktreeinclude
fi

# 1. dependencies
if [[ -n "${INSTALL_CMD:-}" && -f package.json && ! -d node_modules ]]; then
  log "installing dependencies"; bash -c "$INSTALL_CMD" >&2
fi

# 2. shared services (one instance for every worktree)
if [[ -n "${SERVICES_CHECK:-}" ]] && ! bash -c "$SERVICES_CHECK" >/dev/null 2>&1; then
  if [[ "${NEEDS_DOCKER:-0}" == 1 ]] && ! docker info >/dev/null 2>&1; then
    log "starting Docker Desktop"; open -ga Docker
    for _ in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 2; done
  fi
  log "starting shared services"; bash -c "$SERVICES_UP" >&2
fi

# 3. migrations
[[ -n "${MIGRATE_CMD:-}" ]] && bash -c "$MIGRATE_CMD" >&2

# 4. shared Caddy proxy
caddy_running || bash "$REPO_TOP/scripts/proxy.sh" start >&2

# 5. dev server, detached into its own process group so it outlives this script
mkdir -p "$PIDS_DIR" .dev
port="$(site_port "$HOST")"
if [[ -n "$port" ]] && port_listening "$port"; then
  started="already running"; [[ -f "$(pid_file "$HOST")" ]] || started="already running, started outside boot"
else
  log "starting dev server"
  nohup perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' bash scripts/dev.sh > .dev/dev.log 2>&1 < /dev/null &
  echo $! > "$(pid_file "$HOST")"
  started="started"
  for _ in $(seq 1 60); do
    port="$(site_port "$HOST")"
    [[ -n "$port" ]] && curl -fsS -o /dev/null --max-time 20 "http://$HOST" 2>/dev/null && break
    sleep 0.5
  done
fi

# stdout = context for the agent when run from the SessionStart hook
cat <<MSG
Dev environment for this checkout is up (${started}): http://$HOST  (port ${port:-?}, branch $BRANCH).
Dev server log: $REPO_TOP/.dev/dev.log. Do NOT start another dev server or use localhost:3000; use http://$HOST.
Shared services (one instance for all worktrees of this project) and the Caddy proxy are running.
MSG
