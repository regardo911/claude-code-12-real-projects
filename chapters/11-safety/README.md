# Chapter 11: guardrails before you need them

Five steps.

1. Merge [`settings.deny.json`](settings.deny.json) into `.claude/settings.json` in your project (the nine rules from ch11:158-174). If that file already has a `permissions` block, add the nine lines to its `deny` list. Add your own secret paths. `Read(./deploy/production/**)` is the author's; keep it only if you have that folder.
2. Ask Claude Code to read your `.env`. It should refuse (ch11:176). If it reads it, the rules aren't in the file Claude Code loads. Check the path and restart the session.
3. Append [`CLAUDE.md.safety-rules`](CLAUDE.md.safety-rules) to your CLAUDE.md. These rules steer; the deny rules block (ch11:190).
4. Set the cost alerts in your Anthropic dashboard: a warning and a hard cap, daily and monthly. The author's amounts are $20 and $50 a day, $150 and $300 a month (ch11:194).
5. Print [`preflight-checklist.md`](preflight-checklist.md).

## The ask rules

The chapter also has you add `ask` rules for deletions and for writes to `.env*`, `*.pem` and `*.key`, and test them by asking Claude Code to delete a test file (ch11:154). The book prints no `ask` list, so write those lines yourself in the same `permissions` block.

You pass when a permission prompt appears before a destructive action, the `.env` read is refused, and your work is committed before each session (ch11:198).
