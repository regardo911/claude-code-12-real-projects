<!-- Chapter 5 (ch05:104, ch05:114-122, ch05:128-137), verbatim from the book. The co-location rule is one sentence in the chapter; the Component Layout heading above it is ours. Paste the blocks you agree with into your CLAUDE.md. -->

## Naming Conventions
- React components: PascalCase (UserProfile.tsx)
- Utility functions: camelCase (formatDate.ts)
- Constants: SCREAMING_SNAKE_CASE (MAX_RETRY_COUNT)
- Database columns: snake_case (created_at)
- API routes: kebab-case (/api/user-settings)
- Environment variables: prefixed with APP_ (APP_DATABASE_URL)

## Code Style
- Max function length: 30 lines. If longer, refactor into smaller functions.
- Max file length: 200 lines. If longer, split into modules.
- One component per file, named to match the file.
- Props interfaces defined in the same file, above the component.
- No inline styles. Use Tailwind classes exclusively.
- Prefer early returns over nested if/else blocks.
- Comments only for "why", never for "what". The code explains the what.

## Component Layout
- When creating React components, always co-locate the component, its types, its styles, and its test in the same directory using the pattern: ComponentName/index.tsx, ComponentName/types.ts, ComponentName/ComponentName.test.tsx.
