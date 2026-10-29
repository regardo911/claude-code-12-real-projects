# Book fixes

Where a file printed in the book doesn't do what its chapter says: what this repo ships instead, and the run that shows it. The three changed hook scripts say so in their headers. Smaller mismatches (the chapter 7 Builder's root files, the missing chapter 11 `ask` list) are in the chapter READMEs.

## Chapter 5: the secret scanner blocks every commit once you have a .env (ch05:209-211)

The printed scanner runs `grep -rn ... .`, which reads the whole folder, including a `.env` that git ignores. Chapter 8 (ch08:241) tells you to keep your real keys in exactly that file.

A repo with a clean staged `src/app.ts` and `API_KEY=sk-live-123` in a gitignored `.env`:

```
$ bash book/secret-scanner.sh          # as printed
BLOCKED: Possible hardcoded secrets detected:
./.env:1:API_KEY=sk-live-123

Move secrets to environment variables.
exit=1

$ bash hooks/secret-scanner.sh         # this repo
No secrets detected.
exit=0
```

The fix reads the staged copy of each staged file (`git diff --cached --name-only --diff-filter=ACM`, then `git show :<file>`). The pattern, the `--include` list and both exclusions are the book's. A staged key still blocks:

```
BLOCKED: Possible hardcoded secrets detected:
src/config.ts:1:const API_KEY="sk-live-abcdefghijklmnopqrstuv"
```

## Chapter 5: the bundle-size guardian passes every dependency (ch05:233-237)

Three things stop it. The `sed` keeps the last quoted string on the line, which is the version:

```
$ git diff --cached package.json | grep "^+" | grep -v "^+++" | grep -E '"[^"]+":' | sed 's/.*"\([^"]*\)".*/\1/'
^2.1.1
^7.5.0
```

The size tool it calls isn't on npm:

```
$ npm view bundlephobia-cli
npm error 404 Not Found - GET https://registry.npmjs.org/bundlephobia-cli - Not found
```

And an empty size skips the check instead of failing it. Staging `"chart.js": "^4.5.0"` (69624 bytes gzipped, per bundlephobia.com):

```
$ bash book/bundle-size-guardian.sh    # as printed
Bundle size check passed.
exit=0

$ bash hooks/bundle-size-guardian.sh   # this repo
WARNING: chart.js is 67.9KB gzipped. Consider a lighter alternative.
To proceed anyway, add chart.js to .claude/hooks/allowed-large-deps.txt
exit=1
```

Here the hook reads the package names added under `dependencies` (node compares the staged `package.json` with the last commit). It gets the gzip size from `https://bundlephobia.com/api/size?package=<name>` with curl. It reads `.claude/hooks/allowed-large-deps.txt`, which the printed message names and the printed script never opens. It blocks with `size unknown for <name>` when it gets no size. The 50KB limit and the WARNING lines are the book's.

## Chapter 5: the coverage gate prints "Coverage: %" and passes (ch05:260-262)

`--reporter=json` is Vitest's test-results reporter. It writes no `total.lines.pct`, so `COVERAGE` comes out empty and the `bc` test is false. A real project with 25% line coverage, vitest 5.0.5 and @vitest/coverage-v8 5.0.5:

```
$ bash book/coverage-gate.sh           # as printed (node's stack trace cut)
SyntaxError: Unexpected token 'J', "JSON repor"... is not valid JSON
Parse error: bad token
Coverage: % (minimum: 80%). Passed.
exit=0

$ bash hooks/coverage-gate.sh          # this repo
BLOCKED: Test coverage is 25%, minimum is 80%.
Add tests for uncovered code before committing.
exit=1
```

The fix runs `npx vitest run --coverage --coverage.reporter=json-summary`, reads `coverage/coverage-summary.json`, and blocks with `coverage unknown` when there is no number in it (with the coverage package removed, for example). `MINIMUM=80` and both messages are the book's. With every function tested, the same project prints `Coverage: 100% (minimum: 80%). Passed.`

## Chapter 6: the "trending" query returns the most-starred repos, not today's (ch06:328)

The prompt asks for "the top 5 trending GitHub repos today" (ch06:175); the walkthrough shows the request Claude Code sends for it. Run as printed:

```
$ curl -s "https://api.github.com/search/repositories?q=stars:>100&sort=stars&order=desc&per_page=5"
codecrafters-io/build-your-own-x   557359 stars, created 2018
sindresorhus/awesome               526840 stars, created 2014
public-apis/public-apis            493259 stars, created 2016
freeCodeCamp/freeCodeCamp          458191 stars, created 2014
morluto/rea                        407604 stars, created 2026
```

That is the five biggest repos on GitHub by stars, whenever they were made. The prompt in `chapters/06-mcp-servers/prompts.md` is unchanged. A line under it says what the query returns and how to ask for this week instead.

## Chapter 10: --add-dir widens a session, it doesn't narrow it (ch10:161, ch10:227)

The chapter says to "use `--add-dir` to point a session at particular directories instead of letting it roam the whole tree". The help text, Claude Code 2.1.312:

```
$ claude --help | grep -A1 add-dir
  --add-dir <directories...>            Additional directories to allow tool
                                        access to
```

It adds folders outside the one you started in. `chapters/10-cost-control/context-cheatsheet.md` keeps the chapter's real lever, naming the files in your prompt (ch10:84, ch10:106), and leaves `--add-dir` out.

## Appendix B: the GitHub command in double quotes puts your token in the config (appendices.md:314)

Chapter 6 keeps the header in single quotes so the shell does not expand `${GITHUB_PAT}` (ch06:24). Appendix B prints the same command with double quotes and a literal `YOUR_GITHUB_PAT`. If you swap in the chapter 6 variable and keep the double quotes, the token lands in the file. With `GITHUB_PAT=abc` and `claude mcp add --scope project ...`:

```
single quotes, .mcp.json:   "Authorization": "Bearer ${GITHUB_PAT}"
double quotes, .mcp.json:   "Authorization": "Bearer abc"
```

`appendices/b-mcp-directory.md` keeps the printed line and adds one note under it.
