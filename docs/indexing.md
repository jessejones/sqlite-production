# Indexing and Query Performance

PRAGMA tuning cannot compensate for inefficient queries or missing indexes.

## Inspect Important Queries

Use:

```sql
EXPLAIN QUERY PLAN
SELECT ...;
```

Look for unexpected full-table scans and confirm important queries use appropriate indexes.

`EXPLAIN QUERY PLAN` is a debugging tool; its output format is not an application API.

Documentation: [EXPLAIN QUERY PLAN](https://sqlite.org/eqp.html)

## Index for the Workload

Indexes are commonly useful for columns involved in:

- `WHERE`
- joins
- `ORDER BY`
- uniqueness constraints

Queries filtering on multiple columns may benefit from multi-column indexes.

Avoid indexing every column. Each index consumes storage and adds work to inserts, updates, and deletes.

Documentation: [Query Planning](https://sqlite.org/queryplanner.html), [CREATE INDEX](https://sqlite.org/lang_createindex.html)

## Keep Planner Statistics Useful

Run periodically and after meaningful schema/index changes:

```sql
PRAGMA optimize;
```

SQLite recommends `PRAGMA optimize` as the normal way for applications to keep query-planner statistics useful.

Documentation: [PRAGMA optimize](https://sqlite.org/pragma.html#pragma_optimize), [ANALYZE](https://sqlite.org/lang_analyze.html)
