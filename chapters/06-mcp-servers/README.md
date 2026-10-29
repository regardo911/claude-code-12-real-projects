# Chapter 6: three MCP servers, one prompt

You connect GitHub, a database and a fetch server, then write one prompt that uses all three. The commands are in [`mcp-commands.md`](mcp-commands.md), the prompts in [`prompts.md`](prompts.md). Run the commands in your own project folder. `claude mcp add` writes the config there or in your home folder.

![Where each MCP server is saved: github with --scope project goes in .mcp.json, which you commit, and runs on GitHub's servers; db and fetch with no flag go in ~/.claude.json, only for you, and run on your machine. Keep the GitHub header in single quotes so .mcp.json holds the variable name, not your token.](../../docs/images/where-mcp-config-goes.png)

The quotes matter. With `'Bearer ${GITHUB_PAT}'` the committed `.mcp.json` holds the text `${GITHUB_PAT}`; with double quotes it holds your token (ch06:24, and the output in [BOOK-FIXES.md](../../BOOK-FIXES.md)).

After the three `claude mcp add` lines, `claude mcp list` shows `github`, `db` and `fetch`. In Claude Code, the first prompt in `prompts.md` lists your five newest repositories. You pass when the combined prompt pulls from GitHub, writes to your database and calls an API in one go, and the rows are there when you query the table (ch06:363).

## Your own server

[`custom-server/server.js`](custom-server/server.js) is the chapter's one-tool server (ch06:279-307), with a two-key `package.json` so Node loads it as an ES module. Check that it answers before you register it:

```bash
cd chapters/06-mcp-servers/custom-server && npm install
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}' | node server.js
```

It prints one line that starts `{"result":{"protocolVersion":"2025-06-18"` and names `my-custom-server`. Tested on Node 26.5.0 with `@modelcontextprotocol/sdk` 1.32.2 and `zod` 4.6.7. Before you use it for real, point the `fetch` URL at your own API: `internal-api.company.com` is the book's example host.

## A read-only database user

Before you connect a production Postgres, make a read-only user with [`readonly-user.sql`](readonly-user.sql) (ch06:142-149) and put that user in the DSN. It can't write, but it can read every table in `public`. Change `mydb` and the password first.
