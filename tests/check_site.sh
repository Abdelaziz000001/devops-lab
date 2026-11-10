#!/usr/bin/env bash
# Test stage. Prints a readable checklist; exits non-zero on any FAIL,
# which turns the pipeline red and (once the wiring is fixed) blocks deploy.

failures=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures + 1)); }

# 1. index.html exists, is non-empty, and has the heading
if [ -f index.html ] && [ -s index.html ]; then
  pass "index.html exists and is non-empty"
else
  fail "index.html is missing or empty"
fi

if grep -q "Check-in opens at" index.html 2>/dev/null; then
  pass "index.html contains 'Check-in opens at'"
else
  fail "index.html does not contain 'Check-in opens at'"
fi

# 2. exact title
if grep -qF "<title>ingeniums.club</title>" index.html 2>/dev/null; then
  pass "index.html has <title>ingeniums.club</title>"
else
  fail "index.html is missing <title>ingeniums.club</title>"
fi

# 3. every local src=/href= reference must resolve to a file in the repo
missing=0
for ref in $(grep -oE '(src|href)="[^"]+"' index.html 2>/dev/null | sed -E 's/^(src|href)="//; s/"$//'); do
  case "$ref" in
    http://*|https://*|//*|mailto:*|tel:*|'#'*|data:*) continue ;;  # external — not ours to check
  esac
  ref="${ref%%#*}"   # strip anchor
  ref="${ref%%\?*}"  # strip query string
  if [ -n "$ref" ] && [ ! -f "$ref" ]; then
    fail "index.html references $ref but it is not in the repo — did you forget to push it?"
    missing=1
  fi
done
if [ "$missing" -eq 0 ]; then
  pass "all local src=/href= references resolve to files in the repo"
fi

# TODO: check that the time after "opens at" is a valid HH:MM (00:00–23:59)

echo "----------------------------------------"
if [ "$failures" -gt 0 ]; then
  echo "RED: $failures check(s) failed — deploy is blocked."
  exit 1
fi
echo "GREEN — all checks passed."
