# Chapter 7: three agents, one folder

Three Claude Code sessions share one project folder. They never share a conversation. Each has its own folders to write in and leaves a signal file when it's done, and you start the next one.

![Who writes where: the Researcher writes research/, the Builder writes src/ and config/, the Reviewer writes tests/ and reviews/. Every agent reads contracts/; only you or the setup step write it. The order: you start the Researcher, research/DONE.md appears, you start the Builder, src/BUILD_COMPLETE.md appears, you start the Reviewer, reviews/REVIEW_COMPLETE.md appears.](../../docs/images/who-writes-where.png)

What is here:

- [`prompts.md`](prompts.md): the tmux split, the `vuln-checker` folders, the setup prompt and one prompt per agent, in the order you paste them.
- [`CLAUDE.md.roles`](CLAUDE.md.roles): the role block from ch07:58-78. The setup prompt asks Claude Code to write one; compare its version with this one before you start the Researcher.
- [`examples/DONE.md`](examples/DONE.md) and [`examples/issues.md`](examples/issues.md): what a good signal file and a review look like. They are the book's examples (ch07:132-176). Your agents write their own.

The vuln-checker is done when the Reviewer's tests pass and `node src/index.js lodash` prints a table from the live OSV API (ch07:269).

## On your own project

Keep the three folders and the signal files, and change two things: what goes in `contracts/` (your API spec, your schema) and the three prompts. Below about 45 minutes of single-agent work, one session is faster (ch07:297).

One rough edge in the roles block. The Builder writes only to `src/` and `config/`, but its prompt has it create `package.json` and `node_modules/` in the project root (ch07:240). Add those to its "Writes to" line so the block and the prompt agree.
