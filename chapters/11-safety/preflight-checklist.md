<!-- Chapter 11 (ch11:196, ch11:224, ch11:130). The four questions and the two prompts are verbatim from the book. Print it and tape it to your monitor (ch11:196). -->

# Before every Claude Code session

- [ ] Are changes committed?
- [ ] Are my `permissions.deny` rules up to date?
- [ ] Are cost alerts active?
- [ ] Am I about to give a vague, destructive instruction?

A "no" on the first one: `git add -A && git commit -m "before session"` (or `git stash`). Then the worst case is `git checkout .` (ch11:27).

# After a session

`git diff --stat`, then `git diff` on anything that touched setup or `.env` files (ch11:106, ch11:216).

Something slipped through and you are not sure what else did (ch11:224):

```
Review all changes from today's session and flag anything that looks like it could fail under edge cases.
```

# Every few builds

The cleanup session that catches copy-paste before it spreads (ch11:130):

```
Look at src/api and identify any duplicated logic. Extract it into shared utilities.
```
