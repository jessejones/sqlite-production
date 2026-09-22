# Concurrency

SQLite supports multiple concurrent readers but serializes writes.

## Use WAL for Reader/Writer Concurrency

```sql
PRAGMA journal_mode = WAL;
```

WAL allows readers to continue while a writer is active. It does **not** create multiple simultaneous writers.

Documentation: [Write-Ahead Logging](https://sqlite.org/wal.html)

## Keep Write Transactions Short

Avoid holding a write transaction open while doing unrelated work.

Bad:

```text
BEGIN
→ network request
→ expensive computation
→ write rows
COMMIT
```

Better:

```text
network request
→ expensive computation
→ BEGIN
→ write rows
→ COMMIT
```

Short transactions reduce lock duration and contention.

## Allow Brief Contention to Resolve

```sql
PRAGMA busy_timeout = 5000;
```

A busy timeout helps when two operations briefly compete for a lock. It is not a substitute for fixing long write transactions or sustained write saturation.

Documentation: [busy_timeout](https://sqlite.org/pragma.html#pragma_busy_timeout)

## Understand WAL Checkpoints

WAL changes are periodically checkpointed into the main database. SQLite automatically checkpoints by default.

Long-running readers can prevent a checkpoint from completing and allow the WAL file to grow. Start with automatic checkpointing; tune it only when measurement shows a need.

Documentation: [WAL checkpointing](https://sqlite.org/wal.html), [wal_checkpoint](https://sqlite.org/pragma.html#pragma_wal_checkpoint)

## Keep WAL on One Host

WAL depends on shared memory between processes and is intended for processes on the same host. Do not place a WAL database on a network filesystem for access by different machines.

Documentation: [WAL disadvantages](https://sqlite.org/wal.html#advantages)
