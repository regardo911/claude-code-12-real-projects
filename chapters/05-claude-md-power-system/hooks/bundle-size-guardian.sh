#!/bin/bash
# pre-commit hook: bundle-size guardian
#
# bundle-size-guardian.sh: chapter 5 (ch05:228-249). Blocks a commit that adds a dependency
# over 50KB gzipped, unless you list it in .claude/hooks/allowed-large-deps.txt.
# Changed from the book (ch05:233-237), see BOOK-FIXES.md:
#   - the printed sed returns the version ("^4.17.21"), not the package name, so every
#     dependency passed. This reads the names added under "dependencies" in the staged
#     package.json, compared with the last commit.
#   - the printed npx bundlephobia-cli is not on npm (404). The size comes from the
#     bundlephobia.com size API over curl: the gzip size of the package's latest version.
#   - a size it cannot find now blocks, instead of passing in silence.
#   - it reads the allowlist the book's message names. One package name per line.
# The 50KB threshold, the WARNING text and the exit codes are the book's.
# Needs node (to read package.json) and network (for the size), like the book's version.

ALLOWLIST=.claude/hooks/allowed-large-deps.txt

git diff --cached --name-only | grep -qx package.json || { echo "Bundle size check passed."; exit 0; }

if ! command -v node >/dev/null 2>&1; then
  echo "BLOCKED: node not found, so package.json cannot be read."
  exit 1
fi

# deps added under "dependencies" since the last commit
NEW_DEPS=$(node -e '
  const { execSync } = require("child_process");
  const deps = (rev) => JSON.parse(execSync("git show " + rev + ":package.json", { stdio: ["ignore", "pipe", "ignore"] })).dependencies || {};
  let before = {};
  try { before = deps("HEAD"); } catch (e) { /* first commit: everything is new */ }
  console.log(Object.keys(deps("")).filter((d) => !(d in before)).join("\n"));
') || { echo "BLOCKED: the staged package.json is not valid JSON."; exit 1; }

for dep in $NEW_DEPS; do
  if [ -f "$ALLOWLIST" ] && grep -qxF "$dep" "$ALLOWLIST"; then
    echo "$dep is in $ALLOWLIST, not checked."
    continue
  fi
  BYTES=$(curl -s -f -m 60 "https://bundlephobia.com/api/size?package=$dep" 2>/dev/null \
    | node -e 'let d = ""; process.stdin.on("data", (c) => (d += c)).on("end", () => {
        try { const g = JSON.parse(d).gzip; if (Number.isFinite(g)) console.log(g); } catch (e) {} })')
  if [ -z "$BYTES" ]; then
    echo "WARNING: size unknown for $dep (bundlephobia.com returned no gzip size)."
    echo "To proceed anyway, add $dep to .claude/hooks/allowed-large-deps.txt"
    exit 1
  fi
  SIZE=$(echo "scale=1; $BYTES / 1024" | bc)
  if (( BYTES > 50 * 1024 )); then
    echo "WARNING: $dep is ${SIZE}KB gzipped. Consider a lighter alternative."
    echo "To proceed anyway, add $dep to .claude/hooks/allowed-large-deps.txt"
    exit 1
  fi
  echo "$dep is ${SIZE}KB gzipped."
done

echo "Bundle size check passed."
