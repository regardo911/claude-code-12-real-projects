<!-- chapter 6, verbatim, plus the note under the "trending" prompt (BOOK-FIXES.md). Paste each one into Claude Code once the server it needs shows as connected. -->

# Chapter 6 prompts

Swap `my-app`, `[your-repo-name]` and `[your-repo]` for one of your own repositories.

## GitHub server

The connection test (ch06:32-34):

```
List my 5 most recently updated GitHub repositories.
```

Review a pull request (ch06:44-48):

```
Read PR #47 in my-app repo. Review it for: security issues,
performance problems, missing error handling, and anything that
violates the patterns used in the rest of the codebase.
```

Triage the last week of issues (ch06:54-59):

```
Show me all open issues in my-app that were created in the last
7 days. Group them by type: bug reports, feature requests, and
questions. For each bug report, check if there's a related PR
that might fix it.
```

Search across repos (ch06:65-69):

```
Search across my 10 most recent repos for any function that
formats dates into ISO 8601 strings. Show me the file path and
the function signature for each match.
```

What changed this week (ch06:75-78):

```
Look at the last 10 commits in [your-repo-name] and summarize what
changed this week.
```

## Database server

Make a table (ch06:100-104), read it back (ch06:108-110), then join it to GitHub (ch06:114-118):

```
Create a table called 'tasks' with columns: id (integer primary key),
title (text), status (text), created_at (datetime), and github_issue_id
(integer). Insert 5 sample tasks.
```

```
Show me all tasks ordered by creation date.
```

```
Look at my open GitHub issues in [your-repo] and create a task in the
database for each one that doesn't already have a matching
github_issue_id.
```

## Fetch server, then all three

One server (ch06:167-170):

```
Fetch the top 5 trending repositories on GitHub from the GitHub API
(api.github.com) and show me their names, stars, and descriptions.
```

All three in one prompt (ch06:174-179):

```
Fetch the top 5 trending GitHub repos today. For each one, check if I've
already starred it (using the GitHub MCP server). For any I haven't
starred, create a task in my database with the repo name, URL, star count,
and status "to-review".
```

In the chapter's walkthrough of this prompt (ch06:328), "trending" becomes the search `q=stars:>100&sort=stars&order=desc`. That returns the most-starred repositories of all time, not the ones trending today. If you want this week, say so: "repos created in the last 7 days, sorted by stars".

## The build step workflow (ch06:359)

```
Fetch my open GitHub issues. For each issue, check if a task exists in my database. Create tasks for any new issues. Then fetch the latest status of my CI pipeline from GitHub Actions and update each task's status based on whether its branch is passing or failing.
```

## A Linear ticket (ch06:245-247)

Needs the Linear server from `appendices/b-mcp-directory.md`:

```
Create a Linear ticket titled "Fix: search returns 500 on empty string" in the Backend project, priority High, and assign it to me.
```
