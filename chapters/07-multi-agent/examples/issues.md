<!-- An example from the book (ch07:158-176), not output of this repo. The Reviewer writes this file as reviews/issues.md. -->

# Code Review Issues

## Critical (must fix before ship)
1. **No error handling on API timeout.** src/index.js line 34 calls fetch()
   with no timeout. If OSV is down, the CLI hangs forever.
   Fix: Add AbortController with 10-second timeout.

2. **Package name not validated.** User can pass empty string or special
   characters. src/index.js line 12 passes input directly to API.
   Fix: Validate format matches npm package naming rules before API call.

## Minor (should fix)
3. **Exit code is always 0.** Even when vulnerabilities are found, process
   exits with code 0. Convention is exit 1 if vulns found (for CI usage).

## Suggestions (optional)
4. Consider adding --json flag for machine-readable output.
