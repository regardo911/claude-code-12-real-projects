<!-- Chapter 8, verbatim from the book. The build step rounds first, then the rest of the chapter's prompts by subject. -->

# Chapter 8 prompts: prototype to production

Static site from chapter 4? Either run this first to add a small server (Path B, ch08:29), or skip the rounds that need a server (Path A, ch08:25):

```
Turn this static dashboard into a minimal Node project. Add a package.json with `npm init -y`, an Express server in server.js that serves the static files and exposes a /health endpoint returning 200, and wire up Vitest so I can write and run tests. Keep the existing HTML, CSS, and JS working exactly as before.
```

CI needs the project in a GitHub repository: `git init`, commit, push, before Round 3 (ch08:33).

## The build step, six rounds (ch08:352-392)

Round 1, tests (ch08:356, ch08:362):

```
Add full test coverage for this project. Use Vitest. Cover every API endpoint with happy path, error, and edge case tests. Cover every utility function. Mock external API calls. Run all tests and fix failures. Target: zero failing tests.
```

```
Review the test coverage. Add tests for: empty API responses, malformed JSON from external APIs, network timeouts, and concurrent requests to the same endpoint. Also add one integration test per route that doesn't use mocks. Run everything.
```

Round 2, errors and security (ch08:368, ch08:372). Fix what breaks, then run the second prompt again:

```
Audit the entire codebase for error handling gaps. Add try-catch with specific error types for all external calls. Add input validation for all user-facing endpoints. Check for hardcoded secrets and replace with env vars. Add rate limiting middleware. Add a .env.example file.
```

```
Test every endpoint with: empty strings, null values, missing fields, extremely long strings (10,000 characters), SQL injection strings, and script tags. Report which ones break.
```

Round 3, CI (ch08:378). Then copy `ci.yml` from this folder if you want to compare:

```
Set up GitHub Actions CI. On push and PR to main: install deps, lint, test. Fail on any error. Keep it simple.
```

Round 4, environment (ch08:382):

```
Create .env.example with every variable this project needs. Create .env.test for the test suite. Verify .env is in .gitignore. Audit every file for hardcoded values that should be environment variables.
```

Round 5, deploy (ch08:386). Run `vercel deploy` yourself afterwards:

```
Configure this project for Vercel deployment. Create any needed config files. Make sure the app reads PORT from the environment. Add a /health endpoint that returns JSON with status and timestamp. Document the required environment variables in the README.
```

Round 6, the audit (ch08:392). Paste `production-checklist.md` into your CLAUDE.md first:

```
Run through the production checklist. For each of the 10 items, report pass or fail. If anything fails, fix it and re-check.
```

You pass when every item on the checklist is green and the app is live at a public URL with CI running on GitHub (ch08:394).

## Tests

For one routes file (ch08:43):

```
Look at src/api/routes.js. Write tests for every endpoint. Include happy path tests, error cases (invalid input, missing auth, server errors from downstream APIs), and edge cases (empty arrays, null values, extremely long strings). Use Vitest. Put tests in tests/api/routes.test.js. Then run them and fix any failures.
```

The dashboard's API layer (ch08:49-57), then the second pass that finds the subtle failures (ch08:71-79):

```
> Add full test coverage for the API layer. Use Vitest. Cover:
> - Successful data fetches (mock the external API)
> - API timeout handling
> - Malformed response handling
> - Rate limit responses (429 status)
> - Authentication failures
> Put tests in tests/ and run them. Fix any failures.
```

```
> Look at the test coverage for the weather API route. Add tests for:
> - API returns 200 but empty body
> - API returns 200 but schema doesn't match (missing "temperature" field)
> - API returns a redirect
> - Network error (DNS failure, connection refused)
> - Response takes exactly the timeout duration (boundary test)
> Run them all.
```

## Errors and edge cases

```
Audit every function in src/ for error handling. For each external call (API requests, database queries, file reads), add try-catch blocks with specific error types. For each user input, add validation. Log errors with enough context to debug them later (timestamp, function name, input that caused the failure). Don't swallow errors silently.
```

```
Now test these edge cases manually by calling each endpoint with: empty strings, null values, arrays with 10,000 items, unicode characters including emoji, SQL injection attempts in string fields, and missing required fields. Fix any that fail.
```

## An existing codebase

Paste `CLAUDE.md.existing-codebase` into its CLAUDE.md, then start read-only (ch08:162) and keep the first change small (ch08:168):

```
Read CLAUDE.md. Then read src/api/users.js and src/services/userService.js. Explain back to me what the createUser flow does, step by step. Don't change anything yet.
```

```
Add input validation to the createUser endpoint in src/api/users.js. Validate email format, password length (min 8 chars), and required fields. Follow the same error response pattern used in src/api/products.js. Write tests for the validation.
```

## CI, secrets, deploy

```
Set up a GitHub Actions CI pipeline in .github/workflows/ci.yml. On every push and pull request to main: install dependencies, run linting (ESLint), run all tests (Vitest), and check for TypeScript errors if applicable. Fail the build if any step fails. Keep the workflow simple; don't over-engineer it.
```

```
Add Stripe integration for processing payments. Use environment variables for all secrets (STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET). Create a .env.example file showing the required variables without actual values. Add .env to .gitignore if it's not already there. Never hardcode secrets.
```

```
Audit the entire codebase for hardcoded secrets, API keys, passwords, or tokens. Check every file. If you find any, replace them with environment variable references and add the variable names to .env.example.
```

Vercel (ch08:282), Railway (ch08:290), Fly.io (ch08:296):

```
Set up this project for Vercel deployment. Add a vercel.json if needed. Make sure all environment variables are documented in .env.example. Add a deployment section to the README with the required Vercel environment variables.
```

```
Configure this project for Railway deployment. Add a Dockerfile if the project doesn't have one. Make sure the app reads DATABASE_URL from environment variables. Document the Railway deployment steps.
```

```
Create a Dockerfile for this project. Create a fly.toml configuration for Fly.io. Set up health checks. Document all required environment variables.
```

Add this to any deploy prompt (ch08:298):

```
Make sure the app starts correctly in production mode, not development mode. Verify that all environment variables are referenced, not hardcoded. Add a health check endpoint at /health that returns 200.
```

The Railway flow, before and after you click deploy on railway.app (ch08:308, ch08:312, ch08:318). Put your own URL in the last one:

```
Make sure this project has a package.json start script that runs the production server (not the dev server). Add a Procfile with 'web: npm start' if it doesn't exist. Verify that the port is read from process.env.PORT, not hardcoded.
```

```
Create a Dockerfile for production. Use a multi-stage build: stage 1 installs dependencies and builds, stage 2 copies only the built output and production dependencies. Expose the PORT environment variable.
```

```
The app is deployed at https://my-app.up.railway.app. Write a quick health check script that hits /health, /api/weather, and the root URL, and reports the status code for each. Run it.
```
