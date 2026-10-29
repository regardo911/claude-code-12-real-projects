<!-- Chapter 6, verbatim from the book. Run these in your terminal, in your project folder, then restart Claude Code or type /mcp. -->

# Chapter 6: the three servers

GitHub, shared with your team through `.mcp.json` (ch06:19-22). Keep the single quotes:

```bash
export GITHUB_PAT=your_token_here
claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/ --header 'Authorization: Bearer ${GITHUB_PAT}'
```

A database through DBHub, private to you in `~/.claude.json` (ch06:93). Put the absolute path to your own `.db` file where `/Users/you/project/app.db` is; a relative path resolves to `/` and will not open (ch06:96).

```bash
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "sqlite:///Users/you/project/app.db"
```

Postgres and MySQL take the same server with a different DSN (ch06:129, ch06:135):

```bash
claude mcp add --transport stdio db-prod -- npx -y @bytebase/dbhub --dsn "postgresql://user:password@localhost:5432/mydb"
```

```bash
claude mcp add --transport stdio db-mysql -- npx -y @bytebase/dbhub --dsn "mysql://root:yourpassword@localhost:3306/mydb"
```

Fetch, for any public URL (ch06:160). It runs through `uvx`, so install `uv` first (`brew install uv` on a Mac):

```bash
claude mcp add --transport stdio fetch -- uvx mcp-server-fetch
```

Check what registered:

```bash
claude mcp list
```

## When a server will not connect (ch06:209-229)

Run a stdio server on its own first. If this fails, the package or the DSN is the problem, not Claude Code (ch06:214):

```bash
npx -y @bytebase/dbhub --dsn "sqlite:///Users/you/project/app.db"
```

1. Does `claude mcp list` show the server, and is it connected?
2. For a stdio server, does the `npx` command work in a standalone terminal?
3. Are your credentials correct and not expired?
4. Is Node.js v18 or higher installed (for stdio servers)?
5. For a server you just added mid-session, did you run `/mcp` or restart so the session picks it up?

## Five more (ch06:259-265)

| Server | How to add it | Why You Want It |
|---|---|---|
| **Playwright** | `claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest` | Browser automation: scrape sites, test UIs, fill forms |
| **Slack** | `claude mcp add --transport http slack https://mcp.slack.com/mcp` | Read/write Slack channels, summarize conversations |
| **Filesystem** | `claude mcp add --transport stdio fs -- npx -y @modelcontextprotocol/server-filesystem ~/projects` | Controlled file access outside your project directory |
| **Notion** | `claude mcp add --transport http notion https://mcp.notion.com/mcp` | Read/write Notion pages, query databases |
| **Memory** | `claude mcp add --transport stdio memory -- npx -y @modelcontextprotocol/server-memory` | Persistent storage that survives session restarts |

Slack and Notion ask for an OAuth login the first time you use them (ch06:267). Stay at three or four servers in one session: each one adds tool descriptions to the context (ch06:346).

## Your own server (ch06:309)

After `custom-server/` answers (see its folder), register it with the path to your copy of `server.js`:

```bash
claude mcp add --transport stdio company -- node path/to/server.js
```
