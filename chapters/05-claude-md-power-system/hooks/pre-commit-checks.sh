#!/bin/bash
# pre-commit-checks.sh: chapter 5 (ch05:167-192), verbatim from the book.
# Blocks a commit when tsc, eslint or vitest fails. Needs a Node project with
# typescript, eslint and vitest installed. Turn it on: chmod +x .claude/hooks/pre-commit-checks.sh
# shellcheck disable=SC2181  # the book's if [ $? -ne 0 ] style, kept as printed

# Run TypeScript compiler
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "TypeScript errors found. Fix before committing."
  exit 1
fi

# Run linter
npx eslint . --ext .ts,.tsx
if [ $? -ne 0 ]; then
  echo "Lint errors found. Fix before committing."
  exit 1
fi

# Run tests
npx vitest run
if [ $? -ne 0 ]; then
  echo "Tests failed. Fix before committing."
  exit 1
fi

echo "All checks passed."
