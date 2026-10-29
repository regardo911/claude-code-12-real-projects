<!-- Appendix B (appendices.md:293-463), verbatim from the book, plus one note under the GitHub command (see BOOK-FIXES.md). -->

# Appendix B: MCP Server Directory

Quick-reference for the most useful MCP servers. The way you add a server changed: you no longer hand-edit a config file or `npm install -g` a server package. You run `claude mcp add`, and Claude Code writes the config for you. By default that config is *local*: private to you in the current project, stored in `~/.claude.json`. Add `--scope project` to write a shared `.mcp.json` at your project root (the file you check into git so your team gets the same servers), or `--scope user` to make a server available across all your own projects. Two shapes cover almost everything:

```bash
# Hosted remote server (an HTTPS URL; OAuth or a header for auth)
claude mcp add --transport http <name> <url> [--header "Authorization: Bearer TOKEN"]

# Local stdio server (a command Claude Code runs)
claude mcp add --transport stdio <name> -- <command> [args]
```

Manage what's registered with `claude mcp list`, `claude mcp get <name>`, `claude mcp remove <name>`, and `/mcp` inside a session. The single best place to find current servers is the **Anthropic Directory at claude.ai/directory**, which lists each connector with the exact command or OAuth flow. One blanket warning: the `@anthropic-ai/mcp-*` package names that floated around early write-ups never existed, and many `@modelcontextprotocol/server-*` reference servers were archived as the ecosystem moved to hosted remotes. Use the commands below or the Directory, not those old package names.

## Development

### GitHub MCP Server

**Connects to:** GitHub repositories, issues, pull requests, actions.

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

*Note from this repo:* to use the `GITHUB_PAT` variable from chapter 6 here, write the header in single quotes, `--header 'Authorization: Bearer ${GITHUB_PAT}'`. In double quotes your shell puts the real token into the config file (ch06:24).

**Setup:** Add to your Claude Code MCP config with a GitHub personal access token. Grants Claude Code read/write access to repos, issues, and PRs. Use read-only tokens for repos you don't want modified.

### PostgreSQL MCP Server

**Connects to:** PostgreSQL databases.

```bash
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "postgresql://user:pass@localhost:5432/mydb"
```

**Setup:** Provide a connection string in the MCP config. Claude Code can query tables, inspect schemas, and run SQL. Use a read-only database user for production databases. Never connect Claude Code to a production database with write access.

### SQLite MCP Server

**Connects to:** Local SQLite database files.

```bash
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "sqlite:///Users/you/project/app.db"
```

**Setup:** Point to an absolute path to a `.sqlite` or `.db` file (a relative `./file` resolves to your filesystem root and fails to open). Good for local development and prototyping. Claude Code can create tables, insert data, and run queries directly.

### Playwright MCP Server

**Connects to:** Browser automation and web scraping.

```bash
claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest
```

**Setup:** Runs a headless browser that Claude Code can control. Browse to pages, click elements, fill forms, take screenshots. Essential for E2E testing and web scraping tasks.

## Data

### Filesystem MCP Server

**Connects to:** Local or remote file systems beyond the project directory.

```bash
claude mcp add --transport stdio fs -- npx -y @modelcontextprotocol/server-filesystem ~/allowed-directory
```

**Setup:** Configure allowed directories in the MCP config. Claude Code can read and write files outside the project root. Restrict to specific directories for safety.

### Google Drive MCP Server

**Connects to:** Google Drive files and folders.

A managed **directory connector**, not a `claude mcp add` server. Enable it once at **claude.ai/customize/connectors** (toggle Google Drive on → OAuth with your Google account); once on, it's automatically available in Claude Code whenever you're signed in with that same Claude.ai account. (There is no `@anthropic-ai/mcp-google-drive` package; that name was never real.)

**Setup:** OAuth authentication with your Google account. Claude Code can search, read, and create files in Drive. Useful for pulling data from shared team documents.

### Notion MCP Server

**Connects to:** Notion workspaces, databases, and pages.

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

**Setup:** Requires a Notion integration token with access to the pages and databases you want Claude Code to read. Good for pulling project specs or documentation into Claude Code sessions.

## Communication

### Slack MCP Server

**Connects to:** Slack workspaces, channels, and direct messages.

```bash
claude mcp add --transport http slack https://mcp.slack.com/mcp
```

**Setup:** Create a Slack bot token with the permissions Claude Code needs (read messages, post messages, etc.). Claude Code can read channel history, post updates, and respond to messages. Useful for notification workflows and automated reporting.

### Gmail MCP Server

**Connects to:** Gmail inbox and drafts.

A managed **directory connector**, enabled at **claude.ai/customize/connectors** (toggle Gmail on → OAuth), then automatically available in Claude Code under that Claude.ai login. Not a `claude mcp add` server, and no `@anthropic-ai/mcp-gmail` package exists.

**Setup:** OAuth with your Google account. Claude Code can search emails, read messages, and create drafts. Will not send emails automatically (drafts only) unless you explicitly configure send permissions.

### Twilio MCP Server

**Connects to:** SMS, voice, and messaging APIs.

```bash
claude mcp add --transport stdio twilio -- npx -y @twilio-alpha/mcp YOUR_ACCOUNT_SID/YOUR_API_KEY:YOUR_API_SECRET
```

**Setup:** Twilio's official MCP (`@twilio-alpha/mcp`). Create an API Key + Secret in the Twilio console, then pass them as the single `SID/KEY:SECRET` argument shown above. Claude Code can send SMS, make calls, and manage messaging workflows. Useful for building notification systems and customer communication.

## Productivity

### Linear MCP Server

**Connects to:** Linear project management (issues, projects, cycles).

```bash
claude mcp add --transport http linear https://mcp.linear.app/mcp
```

**Setup:** Linear's official remote MCP. After adding, run `/mcp` in a Claude Code session for the OAuth login (or pass a Linear API key in the `Authorization` header). Claude Code can then create issues, update status, and query project data. Good for workflows where Claude Code files tickets for work it identifies but shouldn't do itself.

### Google Calendar MCP Server

**Connects to:** Google Calendar events and scheduling.

A managed **directory connector**, enabled at **claude.ai/customize/connectors** (toggle Google Calendar on → OAuth), then automatically available in Claude Code under that Claude.ai login. Not a `claude mcp add` server, and no `@anthropic-ai/mcp-google-calendar` package exists.

**Setup:** OAuth with your Google account. Claude Code can read events, check availability, and create new events. Useful for scheduling automation.

## Infrastructure

### AWS MCP Server

**Connects to:** AWS services (S3, Lambda, EC2, etc.).

AWS publishes a **suite** of MCP servers (documentation, IaC, cost, DynamoDB, Lambda, and more), each run with `uvx` (install `uv` first). Example, the read-only AWS Documentation server:

```bash
claude mcp add --transport stdio aws-docs --env FASTMCP_LOG_LEVEL=ERROR -- uvx awslabs.aws-documentation-mcp-server@latest
```

The full list and each server's exact `awslabs.<name>-mcp-server` package are at github.com/awslabs/mcp.

**Setup:** Provide AWS credentials with narrowly scoped IAM permissions. Claude Code can interact with AWS services, deploy Lambda functions, manage S3 buckets, and more. Use the principle of least privilege: give Claude access only to the specific services and actions it needs.

### Vercel MCP Server

**Connects to:** Vercel deployments, projects, and domains.

```bash
claude mcp add --transport http vercel https://mcp.vercel.com
```

**Setup:** Vercel's official remote MCP (OAuth on first use; public docs tools work unauthenticated, project tools require the login). Claude Code can trigger deployments, check deployment status, and manage project settings. Pairs well with the GitHub server for end-to-end CI/CD.

### Stripe MCP Server

**Connects to:** Stripe payments, subscriptions, and customer management.

```bash
claude mcp add --transport http stripe https://mcp.stripe.com
```

**Setup:** Provide a Stripe API key. Use a restricted key with only the permissions needed. Claude Code can create products, manage subscriptions, and query payment data. Use test mode keys during development. Never give Claude Code your live secret key during build phases.
