#!/usr/bin/env bash
# Greedy-wrap a commit message body at 72 columns and lint the draft
# against the commit message rules. Reads the full draft on stdin,
# writes the formatted message to stdout and warnings to stderr.
set -euo pipefail

draft=$(cat)
subject=$(printf '%s\n' "$draft" | head -n 1)
body=$(printf '%s\n' "$draft" | tail -n +3)

printf '%s\n' "$subject"
if [ -n "$body" ]; then
  printf '\n'
  printf '%s\n' "$body" | fmt -w 72
fi

warn() { echo "warn: $1" >&2; }

if [ "${#subject}" -gt 50 ]; then
  warn "subject exceeds 50 chars (${#subject})"
fi
case "$subject" in
  *.) warn "subject ends with a period" ;;
esac
if printf '%s' "$draft" | grep -q '`'; then
  warn "draft contains backticks"
fi
if printf '%s' "$body" | grep -q ';'; then
  warn "body contains semicolons"
fi
if printf '%s' "$body" | grep -qE '—|–'; then
  warn "body contains em/en dashes"
fi
