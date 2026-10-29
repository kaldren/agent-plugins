#!/bin/bash
# PostToolUse (Edit|Write|MultiEdit): format the file that just changed so drift never accumulates.
# Fast and scoped to one file. Replace the cases with the project's real formatter commands.
# Never blocks: formatting failures are reported but exit 0.

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

run() { command -v "$1" >/dev/null 2>&1 && "$@" >/dev/null 2>&1 || true; }

case "$file" in
  *.js|*.jsx|*.ts|*.tsx|*.json|*.css|*.scss|*.md|*.html|*.yml|*.yaml)
    [ -x node_modules/.bin/prettier ] && node_modules/.bin/prettier --write "$file" >/dev/null 2>&1 ;;
  *.py)   run ruff format "$file" || run black -q "$file" ;;
  *.go)   run gofmt -w "$file" ;;
  *.rs)   run rustfmt "$file" ;;
  *.java|*.kt) : ;;  # usually formatted by the build (spotless etc.)
esac
exit 0
