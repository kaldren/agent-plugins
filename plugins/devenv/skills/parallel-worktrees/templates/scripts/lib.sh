#!/usr/bin/env bash
# Shared helpers for dev.sh / boot.sh / halt.sh / wt.sh / proxy.sh / url.sh.
# "Which checkout am I" comes from git, so it works the same for the main checkout,
# `claude --worktree`, plain `git worktree add` and worktrees made by other tools/IDEs.
set -euo pipefail

REPO_TOP="$(git rev-parse --show-toplevel)"                                        # this checkout
MAIN_ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"  # main checkout

# shellcheck source=/dev/null
source "$REPO_TOP/scripts/devenv.conf"

# One Caddy for ALL projects on this machine. Each running dev server drops a site file
# here; it lives outside every repo so worktrees never write into the main checkout.
PROXY_STATE="$HOME/.local/state/localhost-proxy"
SITES_DIR="$PROXY_STATE/sites"
PIDS_DIR="$PROXY_STATE/pids"
CADDYFILE="$PROXY_STATE/Caddyfile"
CADDY_ADMIN="http://localhost:2019"

slugify() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'; }
name_for() { [[ "$1" == "$MAIN_ROOT" ]] && echo "" || slugify "$(basename "$1")"; }
host_for() { local n; n="$(name_for "$1")"; [[ -z "$n" ]] && echo "$APP_DOMAIN" || echo "$n.$APP_DOMAIN"; }

WORKTREE_NAME="$(name_for "$REPO_TOP")"
HOST="$(host_for "$REPO_TOP")"
BRANCH="$(git branch --show-current 2>/dev/null)"; BRANCH="${BRANCH:-detached}"

site_file() { echo "$SITES_DIR/$1.caddy"; }
pid_file()  { echo "$PIDS_DIR/$1.pid"; }
site_port() { [[ -f "$(site_file "$1")" ]] && grep -oE '127\.0\.0\.1:[0-9]+' "$(site_file "$1")" | cut -d: -f2 || true; }
port_listening() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
port_claimed() { grep -qsE "127\.0\.0\.1:$1\b" "$SITES_DIR"/*.caddy; }

# Stable per host (a worktree usually keeps its port across restarts); probe forward past
# ports that are listening or claimed by any project's route.
pick_port() {
  local base p i
  base=$(( $(printf '%s' "$1" | cksum | cut -d' ' -f1) % 900 + 3100 ))
  for ((i = 0; i < 900; i++)); do
    p=$(( (base - 3100 + i) % 900 + 3100 ))
    if ! port_listening "$p" && ! port_claimed "$p"; then echo "$p"; return; fi
  done
  echo "no free port in 3100-3999" >&2; return 1
}

# The global Caddyfile is written once and shared by every project using this setup.
ensure_caddyfile() {
  mkdir -p "$SITES_DIR" "$PIDS_DIR"
  [[ -f "$CADDYFILE" ]] && return
  cat > "$CADDYFILE" <<CADDY
# Shared local reverse proxy for every project using the parallel-worktrees setup.
# http://<name>.<app>.localhost → that checkout's dev port. *.localhost resolves to
# 127.0.0.1 natively (RFC 6761), so no /etc/hosts or dnsmasq. Routes = files in sites/.
{
	admin localhost:2019
	auto_https off
}

import $SITES_DIR/*.caddy

http:// {
	respond "No dev server is registered for {host}. Run scripts/boot.sh in that checkout." 502
}
CADDY
}

caddy_running() { curl -fsS -o /dev/null "$CADDY_ADMIN/config/" 2>/dev/null; }
caddy_reload() {
  ensure_caddyfile
  if caddy_running; then
    caddy reload --config "$CADDYFILE" --adapter caddyfile >/dev/null 2>&1 \
      || echo "⚠️  caddy reload failed — run: caddy reload --config $CADDYFILE" >&2
  else
    echo "⚠️  Caddy isn't running, so http://$HOST won't route yet. Start it with: bash scripts/proxy.sh" >&2
  fi
}
register_site()   { mkdir -p "$SITES_DIR"; printf 'http://%s {\n\treverse_proxy 127.0.0.1:%s\n}\n' "$1" "$2" > "$(site_file "$1")"; caddy_reload; }
unregister_site() { rm -f "$(site_file "$1")"; caddy_reload; }
