#!/usr/bin/env bash
# proxy.sh [start|stop|routes] — the shared Caddy on :80 (one for all projects)
source "$(dirname "$0")/lib.sh"
command -v caddy >/dev/null || { echo "Caddy not installed: brew install caddy" >&2; exit 1; }
ensure_caddyfile

case "${1:-start}" in
  start)
    if caddy_running; then caddy reload --config "$CADDYFILE" --adapter caddyfile && echo "Caddy reloaded."
    else caddy start --config "$CADDYFILE" --adapter caddyfile >"$PROXY_STATE/caddy.log" 2>&1 && echo "Caddy started on :80 (admin $CADDY_ADMIN)."; fi ;;
  stop) caddy stop ;;
  routes)
    shopt -s nullglob
    for f in "$SITES_DIR"/*.caddy; do
      h="$(basename "$f" .caddy)"; p="$(site_port "$h")"
      printf '%-44s → :%-5s %s\n' "http://$h" "$p" "$(port_listening "$p" && echo up || echo DOWN)"
    done ;;
  *) echo "usage: proxy.sh [start|stop|routes]" >&2; exit 1 ;;
esac
