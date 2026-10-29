---
description: Create a new database table with migration, types, and CRUD operations
---
<!-- new-table.md: chapter 5 (ch05:301-336), verbatim from the book. Goes in your project as .claude/commands/new-table.md. Run it as: /new-table products: name (text, not null), price (integer, not null), category (text), active (boolean, default true) -->

The user will provide a table name and a list of columns.

## Steps

1. Create a new Supabase migration file in `supabase/migrations/` with a
   timestamp prefix (format: YYYYMMDDHHMMSS_create_[table_name].sql).
   Include the columns the user specified plus standard fields:
   id (uuid, primary key, default gen_random_uuid()),
   created_at (timestamptz, default now()),
   updated_at (timestamptz, default now()).

2. Create a TypeScript type definition in `types/database/[table_name].ts`
   that matches the table schema exactly. Export it as a named export.

3. Create a data access module in `lib/db/[table_name].ts` with these
   functions: create, getById, getAll, update, delete. Each function
   must use parameterized queries and return typed results.

4. Create tests in `__tests__/db/[table_name].test.ts` covering:
   - Create with valid data
   - Create with missing required fields (should throw)
   - GetById with existing and non-existing ID
   - Update with valid data
   - Delete

5. Run the migration against the local database: npx supabase db push

6. Run the tests: npx vitest run __tests__/db/[table_name].test.ts

7. If any test fails, fix the issue and re-run.
