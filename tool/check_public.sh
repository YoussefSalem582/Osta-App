#!/bin/sh
# Guard for a PUBLIC repository: blocks added lines that look like secrets or
# private machine details. Mark a deliberate fake value with "public-ok" on
# the same line.
#
#   tool/check_public.sh                 # staged changes (pre-commit hook)
#   tool/check_public.sh origin/develop  # everything added since that ref (CI)
#
# Install the hook once per clone: git config core.hooksPath tool/hooks
patterns='eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.|[Bb]earer [A-Za-z0-9._-]{24,}|/Volumes/|/Users/[A-Za-z]|/home/[a-z]|C:\\Users\\|BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|sk_(live|test)_[0-9A-Za-z]{16,}|ghp_[0-9A-Za-z]{30,}|xox[baprs]-[0-9A-Za-z-]{10,}'
if [ -n "$1" ]; then
  diff=$(git diff -U0 --no-color "$1"...HEAD -- . ':(exclude)tool/check_public.sh')
else
  diff=$(git diff --cached -U0 --no-color -- . ':(exclude)tool/check_public.sh')
fi
hits=$(printf '%s\n' "$diff" | grep '^+' | grep -v '^+++' | grep -v 'public-ok' | grep -Ei "$patterns")
files=$(printf '%s\n' "$diff" | grep '^+++ b/' | sed 's|^+++ b/||' \
  | grep -Ei '(^|/)\.env(\..*)?$|\.jks$|\.keystore$|\.p12$|\.pem$|key\.properties$|CLAUDE\.local\.md$|settings\.local\.json$')
if [ -n "$hits$files" ]; then
  echo "Blocked: this repository is PUBLIC and the change looks private:" >&2
  [ -n "$hits" ] && printf '%s\n' "$hits" | cut -c1-160 >&2
  [ -n "$files" ] && printf 'file: %s\n' $files >&2
  echo "Remove it, or add 'public-ok' on the line if it is a deliberate fake." >&2
  exit 1
fi
