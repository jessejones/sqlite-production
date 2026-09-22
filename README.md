# SQLite Production

## Best Default Settings

For most server-side applications using SQLite, start with:

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 5000;
```

| Setting | Why |
| --- | --- |
| `journal_mode = WAL` | Improves reader/writer concurrency. |
| `synchronous = NORMAL` | Good WAL-mode performance/durability tradeoff for many applications. |
| `foreign_keys = ON` | Enforces relational integrity. |
| `busy_timeout = 5000` | Gives short-lived lock contention time to resolve. |

These are starting points, not universal requirements. Durability requirements and workload characteristics should drive final configuration.

Official documentation:

- [Write-Ahead Logging](https://sqlite.org/wal.html)
- [PRAGMA journal_mode](https://sqlite.org/pragma.html#pragma_journal_mode)
- [PRAGMA synchronous](https://sqlite.org/pragma.html#pragma_synchronous)
- [PRAGMA foreign_keys](https://sqlite.org/pragma.html#pragma_foreign_keys)
- [PRAGMA busy_timeout](https://sqlite.org/pragma.html#pragma_busy_timeout)

## What These Settings Address

### Write contention

SQLite supports multiple readers but serializes writes. WAL lets readers continue while a writer is active, but it does not create multiple simultaneous writers.

Keep write transactions short. Do network requests, file processing, and expensive computation outside the transaction whenever possible.

See [Concurrency](docs/concurrency.md).

### Query performance

Configuration cannot compensate for poor queries or missing indexes. Inspect important queries with:

```sql
EXPLAIN QUERY PLAN
SELECT ...;
```

See [Indexing and Query Performance](docs/indexing.md).

### Query-planner statistics

Run periodically, and especially after meaningful schema/index changes:

```sql
PRAGMA optimize;
```

SQLite recommends `PRAGMA optimize` as the normal way to keep planner statistics useful.

See [Performance Tuning](docs/tuning.md).

## Persistent vs. Connection Settings

Not every PRAGMA has the same lifetime.

`journal_mode = WAL` is persistent: once successfully enabled, the database remains in WAL mode across connections.

Application connections should explicitly configure settings such as:

```sql
PRAGMA foreign_keys = ON;
PRAGMA synchronous = NORMAL;
PRAGMA busy_timeout = 5000;
```

See [Production Settings](docs/settings.md).

## Initialize a Database

The included script creates a database, enables WAL, runs optimization and a quick integrity check, and reports the connection settings your application should apply:

```bash
./scripts/init-sqlite.sh app.db
```

Requirements: a POSIX-style shell and the `sqlite3` CLI.

The script intentionally does not pretend connection-scoped settings can all be permanently baked into the database.

## Optional Tuning

These settings can help some workloads but are deliberately **not** baseline defaults:

```sql
PRAGMA cache_size = -65536;
PRAGMA mmap_size = 268435456;
PRAGMA temp_store = MEMORY;
```

They trade memory or address space for potential performance gains. Benchmark before enabling them.

See [Performance Tuning](docs/tuning.md).

Official documentation:

- [PRAGMA cache_size](https://sqlite.org/pragma.html#pragma_cache_size)
- [Memory-Mapped I/O](https://sqlite.org/mmap.html)
- [PRAGMA temp_store](https://sqlite.org/pragma.html#pragma_temp_store)

## Durability

The baseline uses:

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
```

In WAL mode, `NORMAL` preserves database consistency, but a power loss or operating-system crash can lose recently committed transactions. If every acknowledged transaction must survive that class of failure, consider `synchronous = FULL` and review SQLite's durability documentation.

[PRAGMA synchronous](https://sqlite.org/pragma.html#pragma_synchronous)

## WAL Checkpoints

WAL writes changes to a separate log before checkpointing them into the main database. SQLite provides automatic checkpointing; its default automatic threshold is 1000 WAL pages.

Long-running readers can prevent a checkpoint from completing and allow the WAL to grow. Start with SQLite's automatic behavior and tune checkpointing only when measurement shows a reason.

- [WAL](https://sqlite.org/wal.html)
- [PRAGMA wal_checkpoint](https://sqlite.org/pragma.html#pragma_wal_checkpoint)

## Replication / Backups

For live databases, prefer SQLite-aware backup mechanisms rather than copying an active database file.

SQLite provides:

- [Online Backup API](https://sqlite.org/backup.html)
- [`VACUUM INTO`](https://sqlite.org/lang_vacuum.html#vacuuminto)

For continuous off-host replication, [Litestream](https://litestream.io/) can replicate SQLite databases to external storage and provide recovery from replicated history.

A common production setup is:

```text
Application → SQLite on local disk → Litestream → Object storage
```

This keeps application database operations local while maintaining an off-host recovery path.

See:


Do not assume copying only `app.db` while a WAL-mode database is active captures the current database state.

## Examples

Framework-independent concepts with concrete driver examples:

- [Python](examples/python/sqlite.py)
- [Node](examples/node/sqlite.py)


The SQLite settings themselves are not framework-specific.

## Production Checklist

- [ ] WAL enabled where appropriate
- [ ] Connection PRAGMAs configured on new connections
- [ ] Write transactions kept short
- [ ] Important queries indexed
- [ ] Important queries checked with `EXPLAIN QUERY PLAN`
- [ ] `PRAGMA optimize` run periodically
- [ ] WAL growth understood/monitored when relevant
- [ ] Off-host backups or replication configured
- [ ] Backup/replication failures monitored
- [ ] Restore procedure tested
- [ ] Optional tuning benchmarked against the real workload

## Guide


For SQLite behavior and configuration, use the [official SQLite documentation](https://sqlite.org/docs.html) as the source of truth.