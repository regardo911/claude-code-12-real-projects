<!-- Chapter 3, verbatim from the book. Paste each block at the Claude Code > prompt. -->

# Chapter 3 prompts

In order. The first two go in `~/my-first-claude-project`. The memory prompt works in any session (ch03:213). The worklog prompt goes in `~/claude-book-ch03`, after you write `practice-CLAUDE.md` there as `CLAUDE.md`.

## First prompt (ch03:99-101)

```
Create a file called hello.py that prints "Claude Code is working" and then run it
```

## A script with a table (ch03:115-119)

```
Create a Python script called system_info.py that displays the current date, OS name,
Python version, current working directory, and disk usage of the home directory.
Format the output as a clean table.
```

## Auto memory (ch03:215-217)

```
Remember that we decided to use Redis for caching instead of Memcached.
```

Claude keeps that note under `~/.claude/projects/` and loads it next session (ch03:219).

## The build step: worklog.py (ch03:288-297)

```
Read my CLAUDE.md, then build a command-line tool called "worklog.py" that:
1. Accepts a one-line description of what I worked on
2. Saves it to a JSON file called worklog.json with a timestamp
3. Can display all entries for today when called with --today
4. Can display all entries for the past 7 days when called with --week
5. Include a test file that verifies all four operations work correctly

Run the tests after creating everything.
```

Then try the tool Claude Code built (ch03:318, ch03:324). On macOS the command is `python3`:

```bash
python3 worklog.py "Finished Chapter 3 of the Claude Code book"
```

```bash
python3 worklog.py --today
```

Pass condition, from the chapter checkpoint (ch03:344): Claude Code reads your CLAUDE.md and writes `worklog.py` with snake_case names, type hints, a comment at the top and `pathlib`, and the tests it ran are green.
