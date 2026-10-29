---
description: Create a new API endpoint with full test coverage
---
<!-- new-endpoint.md: chapter 5 (ch05:344-363), verbatim from the book. Goes in your project as .claude/commands/new-endpoint.md. Run it as: /new-endpoint POST /api/users/settings - accepts user preferences object, stores in Supabase -->

Create a new API endpoint based on the user's description.

## Steps
1. Create the route file in `app/api/` following existing patterns
2. Add input validation using Zod schemas
3. Implement the handler with proper error handling
4. Create types in `types/` if needed
5. Write unit tests covering:
   - Happy path with valid input
   - Invalid input returns 400
   - Missing auth returns 401
   - Server error returns 500
6. Run the tests and fix any failures
7. Update the API documentation in docs/api.md
