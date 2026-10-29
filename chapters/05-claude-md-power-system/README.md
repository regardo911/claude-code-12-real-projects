# Chapter 5: the CLAUDE.md power system

This folder is the template the author describes at ch05:387: a base CLAUDE.md, two skills and the hook scripts, copied into each new project and then customised. One command puts it into yours:

```bash
./install.sh ~/path/to/your-project
```

Run from the root of this repo on a project with a `.git` folder, the output includes:

```
9 copied, 0 kept.
Runs on every commit: secret-scanner.sh
Off until you chmod +x .claude/hooks/<name>.sh: bundle-size-guardian.sh coverage-gate.sh pre-commit-checks.sh
```

A file that is already in your project is left alone and listed as `kept:`.

## Where each file goes

| In this folder | In your project | When it runs |
|---|---|---|
| `CLAUDE.md.template` | `CLAUDE.md` | Claude Code reads it at the start of every session |
| `skills/new-table.md`, `skills/new-endpoint.md` | `.claude/commands/` | When you type `/new-table` or `/new-endpoint` |
| `hooks/*.sh` | `.claude/hooks/` | On `git commit`. The scanner is on after install; `chmod +x` turns on the rest |
| `hooks/pre-commit` | `.git/hooks/pre-commit` | On every `git commit`, yours or Claude Code's. It runs each executable `.claude/hooks/*.sh` in name order and stops at the first failure |
| `hooks/allowed-large-deps.txt` | `.claude/hooks/` | Read by the bundle guardian: packages you allow over 50KB |
| `CLAUDE.md.skeleton` | stays here | The author's filled-in example, to read next to the template |
| `conventions.md` | paste into `CLAUDE.md` | The naming, code style and co-location rules from ch05:104-137 |

![Which file runs when: CLAUDE.md in your project folder at the start of every session; settings.json in ~/.claude/ in every project; new-table.md in .claude/commands/ when you type /new-table; pre-commit in .git/hooks/ on every git commit from you or Claude Code; a PostToolUse hook in .claude/settings.json after Claude Code edits a file.](../../docs/images/which-file-runs-when.png)

Two things are called hooks (ch05:157-161). The four scripts here are git hooks. The `pre-commit` runner runs them on every commit, whoever made it. A Claude Code hook lives in `.claude/settings.json` and fires on Claude Code's own events. The chapter's example lints each file after an edit (ch05:277). It leaves the settings entry to you; the event names are in the Claude Code hooks docs.

## Fill in CLAUDE.md

Replace every `[bracket]` with a fact about your project. All six sections stay: Tech Stack, File Structure, Coding Conventions, When Writing Tests, Known Issues, Do NOT (ch05:399). Keep it under 200 lines (ch05:147). `CLAUDE.md.skeleton` shows what a filled-in one looks like for a Next.js and Supabase app.

## Switch the hooks on

`secret-scanner.sh` is on after install. The other three are off, because each one needs something your project may not have yet:

| Hook | Needs | Switch on |
|---|---|---|
| `pre-commit-checks.sh` | `typescript`, `eslint`, `vitest` in your project | `chmod +x .claude/hooks/pre-commit-checks.sh` |
| `coverage-gate.sh` | `npm i -D vitest @vitest/coverage-v8` | `chmod +x .claude/hooks/coverage-gate.sh` |
| `bundle-size-guardian.sh` | node, a `package.json`, network | `chmod +x .claude/hooks/bundle-size-guardian.sh` |

Three of the four scripts differ from the printed ones. The printed secret scanner blocks every commit once you have a `.env`; the printed coverage gate and bundle guardian pass when they should block. Each header says what changed; [BOOK-FIXES.md](../../BOOK-FIXES.md) has the book's output next to this repo's.

## Test a hook

The chapter's test is to break something on purpose and try to commit it (ch05:447). For the secret scanner, in your project:

```bash
echo 'const API_KEY="sk-live-4f9a8b7c6d5e4f3a2b1c"' > key-test.ts
git add key-test.ts && git commit -m "hook test"
```

You should see this, and no commit:

```
BLOCKED: Possible hardcoded secrets detected:
key-test.ts:1:const API_KEY="sk-live-4f9a8b7c6d5e4f3a2b1c"

Move secrets to environment variables.
```

Clean up with `git rm --cached key-test.ts && rm key-test.ts`. The same block is what Claude Code sees when it commits a pasted key; the chapter says it then moves the key into an environment variable (ch05:224). Try it once and check the diff.

## Test CLAUDE.md and the skills

In a session, with no conventions in the prompt (ch05:445):

```
Add a new component for displaying user notifications.
```

Check the result against your CLAUDE.md: directory, names, file layout, a test. If it misses, the CLAUDE.md is too vague. Make the rule more specific and ask again.

Then a skill (ch05:338):

```
/new-table products: name (text, not null), price (integer, not null), category (text), active (boolean, default true)
```

Both skills are written for the chapter's stack: Supabase, `supabase/migrations/`, Vitest, `app/api/`. On another stack, edit the paths and commands in the steps. Same format, other paths. Write your second skill for a task you do twice a week (ch05:441).

You pass when Claude Code follows your style without a reminder, a bad commit is blocked, and a skill runs all its steps from one line (ch05:451).
