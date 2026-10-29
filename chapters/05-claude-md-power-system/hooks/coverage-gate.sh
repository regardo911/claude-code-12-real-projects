#!/bin/bash
# pre-commit hook: test-coverage gate
#
# coverage-gate.sh: chapter 5 (ch05:255-273). Blocks a commit when line coverage is under 80%.
# Changed from the book (ch05:260-262), see BOOK-FIXES.md: --reporter=json is Vitest's
# test-results reporter and has no total.lines.pct, so the printed version printed
# "Coverage: % (minimum: 80%). Passed." on every run. This version asks Vitest for the
# json-summary coverage report and reads coverage/coverage-summary.json. When it cannot
# read a number it says "coverage unknown" and blocks. MINIMUM=80 and the messages are
# the book's. Tested with vitest 5.0.5 + @vitest/coverage-v8 5.0.5 on Node 26.5.0.
# Needs in your project: npm i -D vitest @vitest/coverage-v8

SUMMARY=coverage/coverage-summary.json

# Run tests with coverage and enforce minimum threshold
# old summary goes first so a failed run can't pass on yesterday's number
rm -f "$SUMMARY"
npx vitest run --coverage --coverage.reporter=json-summary >/dev/null 2>&1
COVERAGE=$(node -e "const j=JSON.parse(require('fs').readFileSync('$SUMMARY','utf8')); \
  console.log(j.total.lines.pct)" 2>/dev/null)

MINIMUM=80

case "$COVERAGE" in
  ''|*[!0-9.]*)
    echo "BLOCKED: coverage unknown (no line coverage in $SUMMARY)."
    echo "Run: npx vitest run --coverage --coverage.reporter=json-summary"
    exit 1
    ;;
esac

if (( $(echo "$COVERAGE < $MINIMUM" | bc -l) )); then
  echo "BLOCKED: Test coverage is ${COVERAGE}%, minimum is ${MINIMUM}%."
  echo "Add tests for uncovered code before committing."
  exit 1
fi

echo "Coverage: ${COVERAGE}% (minimum: ${MINIMUM}%). Passed."
