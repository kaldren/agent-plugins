#!/bin/bash
# PreToolUse (Bash): production deploys require a named release authorization.
# Adapt DEPLOY_PATTERN to the project's real deploy command(s).
# GATE_MODE=block (default): exit 2 unless RELEASE_APPROVAL is set.
# GATE_MODE=ask: pause and ask the human in the session instead of blocking outright.

DEPLOY_PATTERN='(deploy|release|promote).*(prod|production)'

cmd=$(jq -r '.tool_input.command // empty' < /dev/stdin)
[ -z "$cmd" ] && exit 0

if grep -Eiq -- "$DEPLOY_PATTERN" <<<"$cmd"; then
  if [ -n "$RELEASE_APPROVAL" ]; then
    exit 0
  fi
  if [ "${GATE_MODE:-block}" = "ask" ]; then
    jq -n --arg r "Production deploy: confirm a release manager has authorized this release." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
    exit 0
  fi
  echo "Blocked: production deploys need a release authorization. Ask the release manager (<name>) to approve, then restart with RELEASE_APPROVAL=<approval id>. Prepare the release (changelog, PR, staging verification) in the meantime." >&2
  exit 2   # exit 2 blocks the action; the message goes to Claude
fi
exit 0
