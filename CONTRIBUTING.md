# Contributing

Found a file that doesn't match the book, or a hook that lets through what it should stop? Open an issue or a pull request.

- Book files stay as printed. A change to one needs an entry in BOOK-FIXES.md with the command you ran and its output, before and after, and a header line in the file naming the changed lines.
- Book files say in their first lines which chapter and lines they come from (JSON can't carry a comment). Keep that when you edit.
- Run `bash tests/run.sh` before you push. It needs bash and git; node for the Node-hook tests. CI runs it on Ubuntu and on macOS, where bash is 3.2, so no `mapfile`, no associative arrays, no `${var,,}`.
- Keep `.claude/`, `.mcp.json` and a `CLAUDE.md` out of this repo: Claude Code would load them in any session opened here. That's why the files are named `settings.deny.json` and `CLAUDE.md.template`.
