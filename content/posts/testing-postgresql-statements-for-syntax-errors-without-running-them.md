+++
title = "Testing PostgreSQL statements for syntax errors without running them"
description = "Testing PostgreSQL statements for syntax errors without running them"
date = 2021-06-03
+++

```sql
DO $TEST$ BEGIN RETURN;
    -- <Your code here>
END; $TEST$;
```

The easiest way to test most SQL queries is to run them. Feedback is immediate. It's easy to rapidly iterate on results until the query returns what you're looking for.

Sometimes you may only want to give your query a dry run. Maybe you're developing an insert statement that you'd rather not run every time to test. Maybe you're working on a parameterized query and don't want to think about test data. You should be able to test if your query is valid just as quickly as you test simple `SELECT` queries.

The simple trick is to surround your statement in a short circuited [anonymous code block](https://www.postgresql.org/docs/13/sql-do.html). This allows the query parser to read the full block of code as if it were to execute, without actually executing it. An immediate `RETURN` statement stops any of your code from executing.

Let's test it out:

```sql
DO $TEST$ BEGIN RETURN;
  INSERT INO users (id, email) VALUES ($1, $2);
END; $TEST$;

-- Query 1 ERROR: ERROR:  syntax error at or near "INO"
-- LINE 2:   INSERT INO users (id, email) VALUES ($1, $2);
--                  ^
```

Here we are able to check an insert statement for syntax errors. We didn't need to worry about side effects from testing our statement. We also didn't have to supply it with example parameters. Instead the parser helpfully pointed out our error.

Now that we know what's wrong, let's see what happens when our syntax is correct:

```sql
DO $TEST$ BEGIN RETURN;
  INSERT INTO accounts (id, email) VALUES ($1, $2);
END; $TEST$;

-- Query 1 OK: DO
```

The `OK: DO` result returned informs us that our statement executed without a hitch. What it doesn't know is that only the `RETURN` statement at the head executed. While the rest of our syntax was correct, none of it actually ran.

Full credit goes to [Rinat Mukhatrov](https://github.com/rin-nas) for sharing this technique on [StackOverflow](https://stackoverflow.com/questions/8271606/postgresql-syntax-check-without-running-the-query/60525009#60525009). He uses this technique in his [`is_sql`](https://github.com/rin-nas/postgresql-patterns-library/blob/master/functions/is_sql.sql) function, one of many in his [`postgres-patterns-library`](https://github.com/rin-nas/postgresql-patterns-library).
