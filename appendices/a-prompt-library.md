<!-- Appendix A (appendices.md:5-289), verbatim from the book. Replace every [bracket] with your own file, framework or command before you paste. -->

# Appendix A: The Claude Code Prompt Library

These 25 prompts are the ones I use most often. Organized by task, with brief notes on when each one works best and what to expect.

## Build Prompts

### 1. Scaffold a New Project

```
Create a new [framework] project in [directory]. Include: TypeScript config,
ESLint, Prettier, a basic folder structure with src/components, src/api,
and src/utils. Add a .gitignore and a README with setup instructions.
Do not add any example components.
```

**When to use it:** Starting any new project. Saves 15-20 minutes of boilerplate setup. Modify the framework and folder structure to match your stack.

**What to expect:** Claude creates all files, installs dependencies, and verifies the project runs. You'll get a clean starting point with no tutorial junk.

### 2. Build a Feature From a Description

```
Build a [feature description] in [file path or module]. Requirements:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]
Use the existing patterns in this codebase. Run the dev server and
verify it works before marking done.
```

**When to use it:** Any time you have clear requirements and want Claude to implement them end-to-end. The "use existing patterns" instruction prevents Claude from introducing new conventions.

### 3. Create an API Endpoint

```
Add a [METHOD] endpoint at /api/[route] in [file]. It should:
- Accept [input description]
- Validate input with [Zod/joi/manual]
- Call [service/database] to [action]
- Return [response shape]
- Handle errors with the same pattern used in [existing endpoint file]
```

**When to use it:** Adding any new API route. Pointing to an existing endpoint file for error handling patterns keeps the codebase consistent.

### 4. Build a React/Vue/Svelte Component

```
Create a [component name] component in [file path]. Props: [list props
with types]. It should [behavior description]. Style with [Tailwind/CSS
modules/styled-components] matching the existing components in [directory].
No prop drilling deeper than 2 levels.
```

**When to use it:** Building UI components. The "matching existing components" instruction prevents style drift.

### 5. Wire Up a Database Model

```
Create a [model name] model in [ORM path] with these fields:
[field: type, field: type, ...].
Add a migration. Add basic CRUD functions in [service file].
Run the migration and verify with a test query.
```

**When to use it:** Adding a new database table. Works with Prisma, Drizzle, TypeORM, SQLAlchemy, or raw SQL. Claude handles the migration creation and execution.

## Debug Prompts

### 6. Fix a Specific Error

```
I'm getting this error when I [action]:
[paste full error message]
The relevant file is [file path]. Fix it and verify the error is gone.
```

**When to use it:** Any error with a clear message. Pasting the full error (not a summary) gives Claude the best signal. Naming the file prevents expensive file searches.

### 7. Trace a Bug From Symptom

```
When I [user action], the expected behavior is [X] but instead I see [Y].
Start from [entry point file] and trace the data flow to find where
the behavior diverges. Fix it and test.
```

**When to use it:** When you know the symptom but not the cause. Claude will read files along the data path and identify the divergence point. More expensive than Prompt 6 but necessary for non-obvious bugs.

### 8. Fix Failing Tests

```
Run the test suite with [test command]. Fix all failing tests. Do not
skip tests or change test expectations unless the test itself is wrong.
If a test expectation is wrong, explain why before changing it.
```

**When to use it:** After a refactor or feature addition that broke tests. The "do not change expectations" instruction prevents Claude from taking the easy way out.

### 9. Debug a Performance Issue

```
[File or endpoint] is slow. Profile it: measure execution time for each
major step, identify the bottleneck, and propose a fix. Implement the
fix and show the before/after timing.
```

**When to use it:** When something is visibly slow. Claude will add timing measurements, identify the bottleneck, and fix it. Works best when you can point to a specific file or endpoint, not "the app is slow."

### 10. Investigate a Dependency Conflict

```
I'm getting [error/warning] related to [package]. Check package.json
and lock file for version conflicts. Resolve the conflict with minimal
changes. Do not upgrade major versions unless necessary.
```

**When to use it:** Dependency hell. The "minimal changes" and "no major upgrades" instructions prevent Claude from doing a wholesale upgrade that introduces new problems.

## Test Prompts

### 11. Add Unit Tests

```
Write unit tests for [file path]. Cover: happy path, edge cases (empty
input, null values, boundary conditions), and error cases. Use [testing
framework]. Mock external dependencies. Target 90%+ coverage for this file.
```

**When to use it:** Any file that lacks tests. Claude will read the file, understand the logic, and write thorough tests. The explicit coverage target prevents lazy tests.

### 12. Add Integration Tests

```
Write integration tests for the [feature/flow]. Test the full path from
[entry point] to [end result], hitting real [database/API/service] in a
test environment. Set up fixtures, run the test, tear down. Use [framework].
```

**When to use it:** After building a feature that spans multiple files or services. Integration tests catch the bugs unit tests miss.

### 13. Add End-to-End Tests

```
Write E2E tests for [user flow] using Playwright. Test: [step 1],
[step 2], [step 3]. Run headless. Assert on visible page content,
not implementation details. Use data-testid attributes for selectors.
```

**When to use it:** After deploying a feature that has user-facing interactions. E2E tests are expensive to maintain, so only add them for critical user flows.

### 14. Generate Test Data

```
Create a test data factory in [path] for [model]. Include functions to
generate: a single valid record, a batch of N records, and records with
specific overrides. Use [faker/custom] for realistic data. Follow the
schema in [model file].
```

**When to use it:** When your tests need realistic data and you're tired of hand-writing fixtures.

### 15. Audit Test Coverage

```
Run the test suite with coverage reporting. Identify files under 80%
coverage that contain business logic (ignore config files, types, and
constants). For the 3 lowest-coverage files, add tests to bring them
above 80%.
```

**When to use it:** Periodic coverage check. The "ignore config files" instruction keeps Claude focused on files that actually matter.

## Refactor Prompts

### 16. Extract Duplicated Logic

```
Scan [directory] for duplicated code. Extract shared logic into utility
functions in [utils path]. Update all call sites to use the new utilities.
Run tests to verify nothing broke.
```

**When to use it:** After a build phase where Claude (or you) copy-pasted similar code across multiple files. Regular deduplication prevents maintenance nightmares.

### 17. Split a Large File

```
[File path] is [X] lines. Split it into smaller modules by responsibility.
Each new file should have a clear, single purpose. Update all imports
across the codebase. Run tests.
```

**When to use it:** When any file exceeds 300-400 lines. Claude will identify natural separation points and handle the import rewiring.

### 18. Modernize Legacy Code

```
Refactor [file/module] from [old pattern] to [new pattern]. Examples:
callbacks to async/await, class components to hooks, var to const/let.
Do not change behavior. Run existing tests to verify parity.
```

**When to use it:** Incremental modernization of legacy codebases. The "do not change behavior" instruction is critical: this is a refactor, not a rewrite.

### 19. Improve Type Safety

```
Review [directory] and add TypeScript types where they're missing or
using `any`. Create interfaces in [types file] for all data shapes.
Replace `any` with specific types. Do not change runtime behavior.
```

**When to use it:** Tightening up a TypeScript codebase that accumulated `any` types during rapid development.

### 20. Optimize Database Queries

```
Review the database queries in [directory/file]. Identify N+1 queries,
missing indexes, and unnecessary data fetching. Fix each issue. Show
the query plan before and after for the top 3 slowest queries.
```

**When to use it:** When database performance degrades. Claude will add indexes, batch queries, and select only needed columns.

## Deploy Prompts

### 21. Set Up CI/CD

```
Create a GitHub Actions workflow in .github/workflows/ that:
- Runs on push to main and on pull requests
- Installs dependencies
- Runs linting
- Runs tests
- Builds the project
- Deploys to [platform] on main branch pushes only
Use [Node/Python/etc] version [X]. Cache dependencies.
```

**When to use it:** Setting up CI/CD for any project. Adjust the platform and language as needed.

### 22. Dockerize the Application

```
Create a Dockerfile and docker-compose.yml for this project. Multi-stage
build. Production image should be minimal (alpine-based). Include the
database service in docker-compose. Add a .dockerignore. Verify the
container builds and runs.
```

**When to use it:** Containerizing any application. Claude handles the multi-stage build correctly and will test the image.

### 23. Set Up Environment Configuration

```
Review all hardcoded values in [directory] that should be environment
variables. Create a .env.example with all required variables and
descriptions. Update the code to read from process.env. Add validation
that fails fast if required variables are missing.
```

**When to use it:** Before first deployment, or when cleaning up hardcoded values. The .env.example + validation pattern prevents "it works on my machine" issues.

### 24. Create a Production Readiness Checklist

```
Audit this project for production readiness. Check: error handling,
input validation, rate limiting, logging, health check endpoint,
graceful shutdown, environment variable management, CORS configuration,
and security headers. List what's missing and implement each fix.
```

**When to use it:** Before deploying anything public-facing. Claude acts as a pre-deployment reviewer.

### 25. Generate Release Notes

```
Read the git log since [tag/commit]. Write release notes grouped by:
Features, Bug Fixes, Breaking Changes. Use clear, non-technical
language for the Features section. Include the relevant PR/commit
reference for each item.
```

**When to use it:** Before any release. Claude reads the commit history and generates human-readable release notes.
