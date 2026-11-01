#!/usr/bin/env bash
# Start the dev server (DEV_CMD from devenv.conf) on a free port in the foreground and
# publish it at http://<worktree>.<APP_DOMAIN>. boot.sh runs this detached; you can also run it directly.
source "$(dirname "$0")/lib.sh"

existing="$(site_port "$HOST")"
if [[ -n "$existing" ]] && port_listening "$existing"; then
  echo "Already running for this checkout: http://$HOST  (port $existing)"; exit 0
fi

PORT="$(pick_port "$HOST")"
export PORT WORKTREE_NAME BRANCH
export APP_URL="http://$HOST"
export PATH="$REPO_TOP/node_modules/.bin:$PATH"

cleanup() { unregister_site "$HOST"; }
trap cleanup EXIT
trap 'exit 130' INT TERM

register_site "$HOST" "$PORT"
printf '\n  ▶ %s (branch %s)\n    App URL : %s\n    Direct  : http://localhost:%s\n\n' "${WORKTREE_NAME:-main}" "$BRANCH" "$APP_URL" "$PORT"
cd "$REPO_TOP"
# not exec'd, so the EXIT trap removes the route when the server stops
bash -c "$DEV_CMD"
