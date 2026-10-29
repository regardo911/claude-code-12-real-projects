-- readonly-user.sql: chapter 6 (ch06:144-149), verbatim from the book. Run it as an admin on Postgres.
-- Replace mydb with your database name and 'secure-password' with a real password before you run it.
CREATE USER claude_readonly WITH PASSWORD 'secure-password';
GRANT CONNECT ON DATABASE mydb TO claude_readonly;
GRANT USAGE ON SCHEMA public TO claude_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO claude_readonly;
