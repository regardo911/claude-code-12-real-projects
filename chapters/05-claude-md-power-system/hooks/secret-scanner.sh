#!/bin/bash
# pre-commit hook: secret scanner
#
# secret-scanner.sh: chapter 5 (ch05:204-222). Blocks a commit that adds a hardcoded secret.
# Changed from the book: the printed grep reads the whole working tree, so a gitignored
# .env (where ch08 tells you to keep real keys) blocks every commit. This version reads
# only the files staged for this commit (ch05:210-211). PATTERNS, the --include list and
# the node_modules / .env.example exclusions are the book's. See BOOK-FIXES.md.
# Limit of the book's pattern: it is case-sensitive and wants no space before "=", so
# apiKey = "sk-ant-..." and API_KEY = "..." both get through. Review your own diff too.

PATTERNS="API_KEY=|SECRET_KEY=|password=|token=.*['\"][a-zA-Z0-9]{20}"

# staged copy, not what's on disk. that's what gets committed
# a function because bash 3.2 (macOS) can't parse a case inside $( )
staged_matches() {
  git diff --cached --name-only --diff-filter=ACM | while IFS= read -r f; do
    case "$f" in
      *.ts|*.tsx|*.js|*.env) git show ":$f" | grep -n -E "$PATTERNS" | sed "s|^|$f:|" ;;
    esac
  done
}
MATCHES=$(staged_matches | grep -v node_modules | grep -v .env.example)

if [ -n "$MATCHES" ]; then
  echo "BLOCKED: Possible hardcoded secrets detected:"
  echo "$MATCHES"
  echo ""
  echo "Move secrets to environment variables."
  exit 1
fi

echo "No secrets detected."
