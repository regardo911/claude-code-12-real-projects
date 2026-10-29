#!/bin/bash
# tests/run.sh: the repo's offline test suite.  bash tests/run.sh
#
# Everything runs in throwaway git repos under a temp folder. curl, wget, npx and npm
# are replaced by stubs on PATH, so a test that reaches for the network fails instead
# of passing on a lucky connection. The two Node hooks need node (the book's Node 18+);
# without it those tests are skipped and counted as skipped, never as passed.
# bash 3.2 compatible, because that is the bash macOS ships.
#
# Each check is a single-quoted string that eval runs later, so the variables in it
# expand at check time. That is what SC2016 and SC2034 flag, and it is on purpose.
# shellcheck disable=SC2016,SC2034

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CH05="$ROOT/chapters/05-claude-md-power-system"
HOOKS="$CH05/hooks"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# git without the tester's own config, identity or global hooks
export GIT_CONFIG_GLOBAL="$TMP/gitconfig" GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
git config --file "$TMP/gitconfig" init.defaultBranch main

PASS=0; FAIL=0; SKIP=0
ok()   { PASS=$((PASS + 1)); echo "  ok    $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  FAIL  $1"; [ -n "${OUT:-}" ] && printf '%s\n' "$OUT" | sed 's/^/          /'; }
skip() { SKIP=$((SKIP + 1)); echo "  skip  $1"; }
# check NAME CMD...: pass when CMD exits 0
check() { local name="$1"; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
has() { printf '%s\n' "$OUT" | grep -qF -- "$1"; }

# Network stubs. Each one logs its call and fails. The bundle tests swap in a curl
# that answers from tests/fixtures/bundlephobia/ instead.
NET="$TMP/net"; mkdir -p "$NET"
for tool in curl wget npx npm; do
  printf '#!/bin/sh\necho "%s $*" >> "%s/calls.log"\nexit 97\n' "$tool" "$NET" > "$NET/$tool"
  chmod +x "$NET/$tool"
done
: > "$NET/calls.log"
OFFLINE="$NET:$PATH"

# Fixtures. lodash and chart.js are answers recorded from https://bundlephobia.com/api/size;
# the two limit packages and the coverage summaries are made up to sit on the thresholds.
FIX="$TMP/fixtures"; mkdir -p "$FIX/bundlephobia" "$FIX/coverage"
echo '{"name":"lodash","version":"4.18.1","size":71267,"gzip":25842}' > "$FIX/bundlephobia/lodash.json"
echo '{"name":"chart.js","gzip":69624}' > "$FIX/bundlephobia/chart.js.json"
echo '{"name":"at-the-limit","gzip":51200}' > "$FIX/bundlephobia/at-the-limit.json"
echo '{"name":"one-byte-over","gzip":51201}' > "$FIX/bundlephobia/one-byte-over.json"
echo '{"error":{"code":"PackageNotFoundError"}}' > "$FIX/bundlephobia/not-a-real-package.json"
for pct in 72.5 80 85 '"Unknown"'; do
  name=$(echo "$pct" | tr -d '"' | tr 'U' 'u')
  echo "{\"total\": {\"lines\":{\"pct\":$pct}}}" > "$FIX/coverage/lines-$name.json"
done

FAKECURL="$TMP/fakecurl"; mkdir -p "$FAKECURL"
cat > "$FAKECURL/curl" <<EOF
#!/bin/sh
echo "curl \$*" >> "$TMP/curl.log"
for a in "\$@"; do case "\$a" in *package=*) pkg="\${a##*package=}" ;; esac; done
f="$FIX/bundlephobia/\$pkg.json"
[ -f "\$f" ] || exit 22
grep -q '"error"' "\$f" && exit 22
cat "\$f"
EOF
chmod +x "$FAKECURL/curl"

FAKENPX="$TMP/fakenpx"; mkdir -p "$FAKENPX"
cat > "$FAKENPX/npx" <<'EOF'
#!/bin/sh
# vitest: write the coverage summary named in $FAKE_SUMMARY, the way
# --coverage.reporter=json-summary does. tsc / eslint: fail when named in $FAKE_FAIL.
case "$1" in
  vitest)
    if [ -n "${FAKE_SUMMARY:-}" ]; then mkdir -p coverage && cp "$FAKE_SUMMARY" coverage/coverage-summary.json; fi
    case " ${FAKE_FAIL:-} " in *" vitest "*) exit 1 ;; esac ;;
  *) case " ${FAKE_FAIL:-} " in *" $1 "*) exit 1 ;; esac ;;
esac
exit 0
EOF
chmod +x "$FAKENPX/npx"

newrepo() { rm -rf "$1"; mkdir -p "$1"; git -C "$1" init -q; }
tree_sum() { (cd "$1" && find . -path ./.git/objects -prune -o -type f -print | sort | while IFS= read -r f; do cksum "$f"; done); }

echo
echo "install.sh"
P="$TMP/projects/my-project"; newrepo "$P"
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" 2>&1); CODE=$?
check "no argument: usage, exit 2" eval '[ $CODE -eq 2 ] && has "usage: ./install.sh"'
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$TMP/nope" 2>&1); CODE=$?
check "missing folder: shows the ch03 mkdir line, exit 2" eval '[ $CODE -eq 2 ] && has "mkdir ~/my-first-claude-project"'
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$P" 2>&1); CODE=$?
check "empty git repo: exit 0, 9 copied, 0 kept" eval '[ $CODE -eq 0 ] && has "9 copied, 0 kept."'
check "CLAUDE.md is the chapter 5 template, byte for byte" cmp -s "$CH05/CLAUDE.md.template" "$P/CLAUDE.md"
check "both skills land in .claude/commands/" eval '[ -f "$P/.claude/commands/new-table.md" ] && [ -f "$P/.claude/commands/new-endpoint.md" ]'
check "four hooks and the allowlist land in .claude/hooks/" eval '[ $(ls "$P/.claude/hooks" | wc -l) -eq 5 ]'
check "only secret-scanner.sh is switched on" eval '[ -x "$P/.claude/hooks/secret-scanner.sh" ] && [ ! -x "$P/.claude/hooks/coverage-gate.sh" ] && [ ! -x "$P/.claude/hooks/bundle-size-guardian.sh" ] && [ ! -x "$P/.claude/hooks/pre-commit-checks.sh" ]'
check "the runner is .git/hooks/pre-commit, executable" eval '[ -x "$P/.git/hooks/pre-commit" ] && cmp -s "$HOOKS/pre-commit" "$P/.git/hooks/pre-commit"'
BEFORE=$(tree_sum "$P")
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$P" 2>&1)
check "second run: 0 copied, 9 kept, nothing changed" eval 'has "0 copied, 9 kept." && [ "$BEFORE" = "$(tree_sum "$P")" ]'

P2="$TMP/projects/has-files"; newrepo "$P2"
echo "# my own rules" > "$P2/CLAUDE.md"
printf '#!/bin/sh\necho mine\n' > "$P2/.git/hooks/pre-commit"; chmod +x "$P2/.git/hooks/pre-commit"
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$P2" 2>&1)
check "an existing CLAUDE.md is kept as it was" eval '[ "$(cat "$P2/CLAUDE.md")" = "# my own rules" ] && has "kept:   CLAUDE.md"'
check "an existing pre-commit is kept, and the line to add is printed" eval 'grep -q "echo mine" "$P2/.git/hooks/pre-commit" && has "for h in .claude/hooks/*.sh"'

P3="$TMP/projects/no git here"; mkdir -p "$P3"
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$P3" 2>&1); CODE=$?
check "no git repo (and a space in the path): says git init, still copies 8 files" eval '[ $CODE -eq 0 ] && has "no git repo" && has "8 copied, 0 kept."'

P4="$TMP/projects/hooks-elsewhere"; newrepo "$P4"; mkdir -p "$TMP/outside-hooks"
git -C "$P4" config core.hooksPath "$TMP/outside-hooks"
OUT=$(PATH="$OFFLINE" "$ROOT/install.sh" "$P4" 2>&1); CODE=$?
check "core.hooksPath outside the project: no hook written there, the line to add is printed" eval '[ $CODE -eq 0 ] && [ -z "$(ls "$TMP/outside-hooks")" ] && has "skipped: pre-commit hook" && has "for h in .claude/hooks/*.sh"'

check "nothing written outside the project folders" eval '[ "$(ls "$TMP/projects" | sort | tr "\n" "|")" = "has-files|hooks-elsewhere|my-project|no git here|" ]'
check "install.sh made no network call" eval '[ ! -s "$NET/calls.log" ]'

echo
echo "secret-scanner.sh (ch05:204-222, scans staged files)"
S="$TMP/sec"; newrepo "$S"; mkdir -p "$S/src" "$S/node_modules/pkg"
scan() { OUT=$(cd "$S" && PATH="$OFFLINE" bash "$HOOKS/secret-scanner.sh" 2>&1); CODE=$?; }
printf '.env\nnode_modules/\n' > "$S/.gitignore"; printf 'API_KEY=sk-live-123\n' > "$S/.env"
printf 'export const greet = () => "hi";\n' > "$S/src/app.ts"
git -C "$S" add .gitignore src/app.ts
scan
check "a gitignored .env with a key does not block the commit" eval '[ $CODE -eq 0 ] && has "No secrets detected."'
printf 'const API_KEY="sk-live-abcdefghijklmnopqrstuv"\n' > "$S/src/config.ts"; git -C "$S" add src/config.ts
scan
check "a staged src/config.ts with API_KEY= blocks, exit 1" eval '[ $CODE -eq 1 ] && has "BLOCKED: Possible hardcoded secrets detected:" && has "src/config.ts:1:"'
git -C "$S" rm -q --cached src/config.ts
printf 'STRIPE_SECRET_KEY=sk_test_your_stripe_test_key\n' > "$S/.env.example"; git -C "$S" add .env.example
printf 'var API_KEY="x"\n' > "$S/node_modules/pkg/index.js"; git -C "$S" add -f node_modules/pkg/index.js
printf 'Set API_KEY= in your shell.\n' > "$S/NOTES.md"; git -C "$S" add NOTES.md
scan
check ".env.example, node_modules and a .md file pass (the book's exclusions and include list)" eval '[ $CODE -eq 0 ]'
git -C "$S" commit -qm base
printf 'export const greet = () => "hi";\nconst password="hunter2"\n' > "$S/src/app.ts"
scan
check "a key only in the working tree, not staged, does not block" eval '[ $CODE -eq 0 ]'
git -C "$S" add src/app.ts
scan
check "the same key once staged blocks" eval '[ $CODE -eq 1 ] && has "src/app.ts:2:"'
check "the scanner made no network call" eval '[ ! -s "$NET/calls.log" ]'

echo
echo "pre-commit runner, through a real git commit"
C="$TMP/projects/commit-test"; newrepo "$C"
PATH="$OFFLINE" "$ROOT/install.sh" "$C" >/dev/null 2>&1
mkdir -p "$C/src"; printf 'export const API_KEY="sk-live-4f9a8b7c6d5e4f3a2b1c"\n' > "$C/src/stripe.ts"
git -C "$C" add -A
OUT=$(cd "$C" && PATH="$OFFLINE" git commit -m "add stripe client" 2>&1); CODE=$?
check "git commit with a hardcoded key is rejected, nothing committed" eval '[ $CODE -ne 0 ] && has "BLOCKED" && ! git -C "$C" rev-parse -q --verify HEAD >/dev/null'
printf 'export const keyName = "STRIPE_SECRET_KEY";\n' > "$C/src/stripe.ts"; git -C "$C" add -A
OUT=$(cd "$C" && PATH="$OFFLINE" git commit -m "add stripe client" 2>&1); CODE=$?
check "after the fix the commit goes through" eval '[ $CODE -eq 0 ] && has "No secrets detected."'
printf '#!/bin/bash\nexit 3\n' > "$C/.claude/hooks/zz-stop.sh"
echo "one" > "$C/one.txt"; git -C "$C" add one.txt
OUT=$(cd "$C" && PATH="$OFFLINE" git commit -qm one 2>&1); CODE=$?
check "a hook without chmod +x is skipped" eval '[ $CODE -eq 0 ]'
chmod +x "$C/.claude/hooks/zz-stop.sh"; echo "two" > "$C/two.txt"; git -C "$C" add two.txt
OUT=$(cd "$C" && PATH="$OFFLINE" .git/hooks/pre-commit 2>&1); CODE=$?
check "with chmod +x it runs, and its exit code (3) comes back" eval '[ $CODE -eq 3 ]'

echo
echo "pre-commit-checks.sh (ch05:167-192, with stub tsc / eslint / vitest)"
K="$TMP/checks"; newrepo "$K"
OUT=$(cd "$K" && PATH="$FAKENPX:$OFFLINE" FAKE_FAIL="" bash "$HOOKS/pre-commit-checks.sh" 2>&1); CODE=$?
check "all three pass: All checks passed., exit 0" eval '[ $CODE -eq 0 ] && has "All checks passed."'
OUT=$(cd "$K" && PATH="$FAKENPX:$OFFLINE" FAKE_FAIL="eslint" bash "$HOOKS/pre-commit-checks.sh" 2>&1); CODE=$?
check "eslint fails: Lint errors found, exit 1" eval '[ $CODE -eq 1 ] && has "Lint errors found. Fix before committing."'

echo
echo "bundle-size-guardian.sh (ch05:228-249, sizes from recorded bundlephobia answers)"
if ! command -v node >/dev/null 2>&1; then
  skip "node not installed: 9 bundle-size tests"
else
  G="$TMP/bundle"
  pkg() { printf '{\n  "name": "demo",\n  "dependencies": {%s\n  },\n  "devDependencies": {%s\n  }\n}\n' "$1" "${2:-}" > "$G/package.json"; }
  guard() { : > "$TMP/curl.log"; OUT=$(cd "$G" && PATH="$FAKECURL:$OFFLINE" bash "$HOOKS/bundle-size-guardian.sh" 2>&1); CODE=$?; }
  newrepo "$G"; echo x > "$G/README"; git -C "$G" add README
  guard
  check "no package.json staged: passes without a lookup" eval '[ $CODE -eq 0 ] && [ ! -s "$TMP/curl.log" ]'
  pkg '
    "lodash": "^4.17.21"'; git -C "$G" add package.json
  guard
  check "first commit: every dependency is new (lodash 25.2KB passes)" eval '[ $CODE -eq 0 ] && has "lodash is 25.2KB gzipped."'
  git -C "$G" commit -qm base
  pkg '
    "lodash": "^4.18.1"'; git -C "$G" add package.json
  guard
  check "a version bump on an existing dependency is not a new dependency" eval '[ $CODE -eq 0 ] && [ ! -s "$TMP/curl.log" ]'
  pkg '
    "lodash": "^4.17.21",
    "chart.js": "^4.5.0"'; git -C "$G" add package.json
  guard
  check "chart.js at 67.9KB blocks with the book's WARNING, exit 1" eval '[ $CODE -eq 1 ] && has "WARNING: chart.js is 67.9KB gzipped. Consider a lighter alternative." && has "add chart.js to .claude/hooks/allowed-large-deps.txt"'
  mkdir -p "$G/.claude/hooks"; echo chart.js > "$G/.claude/hooks/allowed-large-deps.txt"
  guard
  check "chart.js in allowed-large-deps.txt passes without a lookup" eval '[ $CODE -eq 0 ] && [ ! -s "$TMP/curl.log" ]'
  rm -rf "$G/.claude"
  pkg '
    "lodash": "^4.17.21",
    "not-a-real-package": "^1.0.0"'; git -C "$G" add package.json
  guard
  check "no size found: says size unknown and blocks" eval '[ $CODE -eq 1 ] && has "size unknown for not-a-real-package"'
  pkg '
    "lodash": "^4.17.21"' '
    "chart.js": "^4.5.0"'; git -C "$G" add package.json
  guard
  check "devDependencies are not checked" eval '[ $CODE -eq 0 ] && [ ! -s "$TMP/curl.log" ]'
  pkg '
    "lodash": "^4.17.21",
    "at-the-limit": "1.0.0"'; git -C "$G" add package.json
  guard
  check "exactly 50KB (51200 bytes) passes" eval '[ $CODE -eq 0 ]'
  pkg '
    "lodash": "^4.17.21",
    "one-byte-over": "1.0.0"'; git -C "$G" add package.json
  guard
  check "51201 bytes blocks" eval '[ $CODE -eq 1 ]'
fi

echo
echo "coverage-gate.sh (ch05:255-273, MINIMUM=80)"
if ! command -v node >/dev/null 2>&1; then
  skip "node not installed: 6 coverage tests"
else
  V="$TMP/cov"; newrepo "$V"
  gate() { OUT=$(cd "$V" && PATH="$FAKENPX:$OFFLINE" FAKE_SUMMARY="$1" bash "$HOOKS/coverage-gate.sh" 2>&1); CODE=$?; }
  gate "$FIX/coverage/lines-72.5.json"
  check "72.5% blocks with the book's message, exit 1" eval '[ $CODE -eq 1 ] && has "BLOCKED: Test coverage is 72.5%, minimum is 80%."'
  gate "$FIX/coverage/lines-85.json"
  check "85% passes" eval '[ $CODE -eq 0 ] && has "Coverage: 85% (minimum: 80%). Passed."'
  gate "$FIX/coverage/lines-80.json"
  check "exactly 80% passes" eval '[ $CODE -eq 0 ]'
  rm -rf "$V/coverage"; gate ""
  check "no summary file: coverage unknown, blocks" eval '[ $CODE -eq 1 ] && has "coverage unknown"'
  gate "$FIX/coverage/lines-unknown.json"
  check "a summary with no number (\"Unknown\"): coverage unknown, blocks" eval '[ $CODE -eq 1 ] && has "coverage unknown"'
  mkdir -p "$V/coverage"; cp "$FIX/coverage/lines-85.json" "$V/coverage/coverage-summary.json"; gate ""
  check "an old summary from an earlier run does not count" eval '[ $CODE -eq 1 ] && has "coverage unknown"'
fi

echo
echo "the repo itself"
OUT=""
cd "$ROOT" || exit 1
SHS=$(find . -path ./.git -prune -o \( -name '*.sh' -o -name pre-commit \) -type f -print)
check "every script parses (bash -n)" eval 'for f in $SHS; do bash -n "$f" || exit 1; done'
LIVE=$(find . -path ./.git -prune -o \( -name .claude -o -name .mcp.json -o -name CLAUDE.md -o -name settings.json \) -print)
check "no live .claude/, .mcp.json, CLAUDE.md or settings.json to configure a session opened here" eval '[ -z "$LIVE" ]'
check "the one workflow under .github/ is this repo's own CI" eval '[ "$(ls .github/workflows)" = "ci.yml" ] && ! grep -q "npm ci" .github/workflows/ci.yml'
check "secret scanner keeps the book's PATTERNS" grep -qF 'PATTERNS="API_KEY=|SECRET_KEY=|password=|token=.*['"'"'\"][a-zA-Z0-9]{20}"' "$HOOKS/secret-scanner.sh"
check "coverage gate keeps MINIMUM=80" grep -qx 'MINIMUM=80' "$HOOKS/coverage-gate.sh"
check "both skills open with the frontmatter Claude Code reads" eval 'for f in "$CH05"/skills/*.md; do [ "$(head -1 "$f")" = "---" ] && sed -n 2p "$f" | grep -q "^description: " || exit 1; done'
if command -v node >/dev/null 2>&1; then
  check "settings.deny.json is valid JSON with the nine deny rules of ch11:158-174" \
    node -e 'const j=JSON.parse(require("fs").readFileSync("chapters/11-safety/settings.deny.json","utf8")); process.exit(j.permissions.deny.length===9?0:1)'
  check "custom-server/package.json is valid JSON with type module" \
    node -e 'process.exit(JSON.parse(require("fs").readFileSync("chapters/06-mcp-servers/custom-server/package.json","utf8")).type==="module"?0:1)'
else
  skip "node not installed: 2 JSON checks"
fi
BROKEN=$(find . -path ./.git -prune -o -name '*.md' -type f -print | while IFS= read -r md; do
  grep -oE '\]\([^)#[:space:]]+' "$md" | sed 's/^](//' | grep -vE '^(https?:|mailto:)' | while IFS= read -r link; do
    [ -e "$(dirname "$md")/$link" ] || echo "$md -> $link"
  done
done)
OUT="$BROKEN"
check "every relative link in the Markdown files points at a file that exists" eval '[ -z "$BROKEN" ]'


echo
TOTAL=$((PASS + FAIL))
echo "$PASS passed, $FAIL failed, $SKIP skipped ($TOTAL run)"
if [ "$TOTAL" -eq 0 ]; then echo "no tests ran"; exit 1; fi
[ "$FAIL" -eq 0 ]
