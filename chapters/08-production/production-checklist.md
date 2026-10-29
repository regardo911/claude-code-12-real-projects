<!-- Chapter 8 (ch08:322-344), verbatim from the book. The author keeps this list in every project's CLAUDE.md (ch08:324): paste it under a "## Production Checklist" heading there. -->

## Production Checklist

**1. All tests pass.** Not "most tests pass." Not "the failing test is a known issue." All of them. Green across the board.

**2. No hardcoded secrets anywhere in the codebase.** Run the audit prompt from the security section. Check twice.

**3. Error handling on every external call.** Every API request, every database query, every file read has a try-catch with a specific error message. No silent failures.

**4. Input validation on every user-facing endpoint.** Every field that comes from a user gets validated for type, length, and format before it touches your business logic.

**5. Rate limiting is active.** At minimum, your API endpoints should reject more than 100 requests per minute from a single IP. Claude Code can add this with express-rate-limit in one prompt.

**6. .env.example is complete and up to date.** Every environment variable your app needs is listed with a description. A new developer should be able to go from clone to running in under 5 minutes using this file.

**7. Health check endpoint exists.** GET /health returns 200 with a JSON body. Bonus: have it check database connectivity and return 503 if the database is down.

**8. Logging is in place.** Errors get logged with timestamps, context, and stack traces. You should be able to reconstruct what happened from logs alone, without reproducing the bug.

**9. CI pipeline runs on every push.** Tests, linting, and type checking all run automatically. A failing CI blocks the merge.

**10. The app runs in production mode, not development mode.** NODE_ENV is set to "production." Debug output is off. Source maps are not exposed. Dev dependencies are not installed.

Then ask Claude Code (ch08:346):

```
Audit this project against the production checklist in CLAUDE.md. For each item, report pass or fail with specifics.
```
