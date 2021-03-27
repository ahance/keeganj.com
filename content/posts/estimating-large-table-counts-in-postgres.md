+++
title = "Estimating Large Table Counts In Postgres"
description = "How do you find how many items are in a table without COUNT(*)?"
aliases = ["/articles/estimating-large-table-counts-in-postgres"]
date = 2019-02-26
+++

## For the Want of a `COUNT`

Today I found myself with the problem of executing a `COUNT` query with a simple `WHERE` clause on a large table. The user wanted to get an idea of how many rows were of a particular type, but wanted to do so within the course of a page load. The result didn't have to be exact, but it did have to give a rough idea of how large the _real_ number of rows in the result were. The `COUNT` query was taking over a minute to execute (which is well past the threshold of what I wanted in the flow of a web request), so I decided to investigate ways of getting a "close enough" answer in less time.

There's a few different ways to approach a problem like this, but many of those approaches involve some level of pre-calculation or caching (such as materialized views or using sequences). I didn't want to give such a simple query the overhead of an external process, and I'm usually averse to database triggers when they aren't standard in a database already. I needed a way to estimate the result of my query entirely within a single request flow.

## (Ab)using `EXPLAIN`

After some googling I came across [this excellent article by Citus Data](https://www.citusdata.com/blog/2016/10/12/count-performance), which goes over strategies for efficently calculating and estimating counts on large tables. If your use case is in any way different than mine, I would suggest consulting that article first for a solution that better fits your needs. In it they cite an old trick for getting a rough estimate of the outcome of a query: Parsing the output of the `EXPLAIN` command.

For those not familiar, `EXPLAIN` is PostgreSQL's way of letting you know how it plans to execute your query. By itself it's an excellent tool for debugging long running queries and finding ways of speeding them up. Without adding the keyword `ANALYZE`, it doesn't actually perform your query, it only exposes how it _plans_ to get the result. PostgreSQL uses a set of [clever techniques](https://www.postgresql.org/docs/10/row-estimation-examples.html) to estimate the impact of an action before it performs it, which is necessary for the query to be executed efficiently. 

This is great for us, since it means that a highly supported and optomized portion of PostgreSQL is already doing the work of estimating the cost of each part of our query. We just need to glean the number of rows it thinks will be returned:

```sql
CREATE FUNCTION count_estimate(query text) RETURNS integer AS $$
DECLARE
    rec   record;
    rows  integer;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN rows IS NOT NULL;
    END LOOP;

    RETURN rows;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
```

_[Credit to Mike Fuhr](https://www.postgresql.org/message-id/20050810133157.GA46247@winnie.fuhr.org) for authoring and posting this to the PostgreSQL mailing list._

Note that in order to use this function we need to pass in our query as text. Depending on how you invoke your SQL queries, that may put an upper limit on how complex of a query you want to feed into this function. Given that the resulting estimate will vary more widely the more complex your query is, being constrained to small and simple queries could be a good thing.

## Testing the Happy Path

Using a table of about 52 million rows, I ran a benchmark to see how much of a difference using estimates would make. (All row numbers below have been slightly fuzzed but ratios have been preserved).

```sql
-- Control
SELECT COUNT(*) FROM large_table WHERE condition; 
```

Running the above returns a count of 52,652,307 rows in 1m:24s. Longer than I'd want to wait around for a result, but it's a big table.

```sql
-- Experimental
SELECT count_estimate(
  'SELECT * FROM large_table WHERE condition'
); 
```

Running this returns a count of 52,234,432 rows in only took 0.081s. That's _much_ faster:

- Difference in result:     **0.8%**
- Difference in runtime:    **103,704%**

1037 times the speed in exchange for about a 1% loss in accuracy sounds like a good deal to me.

## Potential Pitfalls

But wait, it's not all sunshine and roses. While most of the tests I performed on large tables behaved similarly, there was one case where this form of table estimation did not shine: Shrinking tables.

Let's take a look at a small table on my system that's been emptied out for this test:

```sql
SELECT count(*) FROM small_table;
-- Result: 0

SELECT count_estimate(
  'SELECT * FROM small_table'
); 
-- Result: 960
```

Wow, that's way off! What happened to my 1% accuracy margin? 

Maybe it's just an issue with a table with 0 rows. What would happen if I were to add 10 rows to my empty table? Would my estimate change?

```sql
INSERT INTO small_table (,,,) VALUES (,,,), (,,,), ...

SELECT count(*) FROM small_table;
-- Result: 10 

SELECT count_estimate(
  'SELECT * FROM small_table'
); 
-- Result: 960
```

Hmm, no change. Where does 960 come from? Let's go back to that list of [clever techniques](https://www.postgresql.org/docs/10/row-estimation-examples.html) in the PostgreSQL docs...

> The number of pages and rows is looked up in pg_class... These numbers are current as of the last VACUUM or ANALYZE on the table. The planner then fetches the actual current number of pages in the table (this is a cheap operation, not requiring a table scan). If that is different from relpages then reltuples is scaled accordingly to arrive at a current number-of-rows estimate.

OK, so what happens if call `VACUUM` beforehand?

```sql
VACUUM small_table;

SELECT count(*) FROM small_table;
-- 10

SELECT count_estimate(
  'SELECT * FROM small_table'
); 
-- 10
```

That's more like it.

Turns out 960 is the number of rows this table had since the last time it was `VACUUM`ed. This wouldn't have been a problem if the table grew steadily, but since it was cleared right before testing PostgreSQL didn't get the chance to clean up enough for the estimate to be accurate.

While this may seem like an edge case, I believe it's worth knowing about if you want your estimate to be up to date. Particularly if the table your estimating has a chance of going to zero rows.

While we could just `VACUUM` before performing our query, I don't know that doing this automatically every time we want an estimate is the best use of PostgreSQL's resources.

## Summary

- If you have a massive table and that does have rows regularly added or deleted in significant quantities, using the above `count_estimate` function could save you a lot of time and resources.
- **But** if your table has rows added and/or deleted in quantities you would care to see reflected quickly in an estimate and you'd rather not manually `VACUUM`, use another technique.

```sql
-- count_estimate.sql

CREATE FUNCTION count_estimate(query text) RETURNS integer AS $$
DECLARE
  rec   record;
  rows  integer;
BEGIN
  FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
    rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
    EXIT WHEN rows IS NOT NULL;
  END LOOP;
  RETURN rows;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

-- Testing --

-- Control
SELECT COUNT(*) FROM large_table WHERE condition; 
-- 52,652,307 -- 1m:24s

-- Experimental
SELECT count_estimate(
  'SELECT * FROM large_table WHERE condition'
); 
-- 52,234,432 -- 0m:00.081s

-- 0.8%      difference in result
-- 103,704%  difference in runtime
```

### Further Reading

- ["Faster PostgreSQL Counting" - citusdata.com](https://www.citusdata.com/blog/2016/10/12/count-performance#dup_counts_estimated_filtered)
- ["Row Estimation Examples" - postgresql.org](https://www.postgresql.org/docs/10/row-estimation-examples.html)
- ["Re: \*\*SPAM\*\* Faster count(*)?" - postgresql.org](https://www.postgresql.org/message-id/20050810133157.GA46247@winnie.fuhr.org)