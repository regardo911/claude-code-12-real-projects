<!-- Chapter 7, verbatim from the book. One setup session, then one Claude Code session per agent, each in its own terminal pane. -->

# Chapter 7 prompts: the three-agent vuln-checker

Three panes with tmux (ch07:35-40), or VS Code split terminals:

```bash
tmux new-session -s cowork
# Ctrl+B then % to split vertically
# Ctrl+B then " to split horizontally
# Ctrl+B then arrow keys to move between panes
```

The project folders (ch07:194-198). Node 18+ first: the Builder runs `npm install` (ch07:188).

```bash
mkdir -p vuln-checker/{contracts,research,src,tests,reviews}
cd vuln-checker
claude  # This is your setup session
```

## Setup session (ch07:202)

```
Create a CLAUDE.md for a multi-agent project. Three agents: Researcher, Builder, Reviewer. Include the role definitions with directory boundaries. Also create contracts/api-spec.md describing a CLI tool that takes an npm package name, queries the OSV API (https://api.osv.dev/v1/query), and returns a formatted list of known vulnerabilities with severity ratings. The CLI should accept a package name as an argument and output results to stdout.
```

Before you go on, open `contracts/api-spec.md` and check it names, at minimum (ch07:206-210):

- Input: `vuln-check <package-name>` (e.g., `vuln-check lodash`)
- Output: formatted table with columns: CVE ID, Severity, Summary, Affected Versions
- Error cases: invalid package name, API unreachable, no vulnerabilities found
- Exit codes: 0 for no vulns, 1 for vulns found, 2 for errors

## Pane 1, Researcher (ch07:225)

```bash
cd vuln-checker
claude
```

```
You are Agent 1: Researcher. Read CLAUDE.md for your role. Research the OSV API: authentication requirements, rate limits, request/response format, and any quirks. Also research the best Node.js libraries for making HTTP requests and formatting CLI output. Write all findings to research/osv-api.md and research/libraries.md. When done, create research/DONE.md with a summary of key findings and recommendations for the Builder agent.
```

## Pane 2, Builder (ch07:240)

Start it when `research/DONE.md` exists and the files it lists look complete (ch07:283).

```
You are Agent 2: Builder. Read CLAUDE.md for your role. Read the contract in contracts/api-spec.md and the research in research/. Build the CLI tool in src/. Use the libraries and API patterns recommended by the Researcher. Initialize a package.json, install dependencies, and make sure the CLI is runnable with `node src/index.js <package-name>`. When the tool is working, create src/BUILD_COMPLETE.md with a summary of what was built and any design decisions you made.
```

## Pane 3, Reviewer (ch07:255)

Start it when `src/BUILD_COMPLETE.md` exists.

```
You are Agent 3: Reviewer. Read CLAUDE.md for your role. Read the contract in contracts/api-spec.md. Review the code in src/ for correctness, error handling, edge cases, and security issues. Write tests in tests/ that verify the CLI works as specified. Run the tests. Document any issues in reviews/issues.md with severity levels (critical, minor, suggestion). When done, create reviews/REVIEW_COMPLETE.md.
```

## Back in the Builder pane (ch07:263)

```
Read reviews/issues.md. Fix all critical and minor issues. Run the tests in tests/ after each fix to verify.
```

## When an agent drifts

Add this line to the roles block in CLAUDE.md if two agents touched one file (ch07:279):

```
NEVER modify files outside your designated directories. If you see a problem in another agent's code, document it in your signal file instead.
```

Say this to an agent that forgot its lane (ch07:291):

```
Re-read CLAUDE.md. You are Agent 2: Builder. You write to src/ only. Stay in your lane.
```

## A subagent instead of a second pane (ch07:106)

For a 30-second side question that would crowd the main session:

```
Spawn a subagent to compare Redis vs Memcached for caching API responses. Requirements: Node.js, JSON payloads averaging 2KB, 10,000 requests per minute, TTL-based expiration. Write the recommendation to research/caching-decision.md with a clear winner and the npm package to install.
```
