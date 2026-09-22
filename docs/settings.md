# Production Settings

## Recommended Baseline

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 5000;
```

## `journal_mode = WAL`

**Addresses:** reader/writer contention.

WAL allows readers and a writer to operate concurrently. SQLite still serializes writes, so WAL does not provide multiple simultaneous writers.

WAL mode persists with the database after it is successfully enabled.

Documentation: [WAL](https://sqlite.org/wal.html), [journal_mode](https://sqlite.org/pragma.html#pragma_journal_mode)

## `synchronous = NORMAL`

**Addresses:** filesystem synchronization overhead during commits.

In WAL mode, `NORMAL` reduces synchronization work compared with `FULL` and is a good performance/durability balance for many applications.

**Tradeoff:** database consistency is preserved, but recently committed transactions can be lost after power loss or an operating-system crash. Use `FULL` when that durability guarantee is required.

Documentation: [synchronous](https://sqlite.org/pragma.html#pragma_synchronous)

## `foreign_keys = ON`

**Addresses:** relational integrity.

Explicitly enable foreign-key enforcement on application connections rather than depending on library, build, or future SQLite defaults.

Documentation: [Foreign Keys](https://sqlite.org/foreignkeys.html), [foreign_keys](https://sqlite.org/pragma.html#pragma_foreign_keys)

## `busy_timeout = 5000`

**Addresses:** short-lived lock contention.

A busy timeout lets SQLite wait for a conflicting lock to clear instead of immediately returning `SQLITE_BUSY`. Five seconds is a reasonable starting point, not a universal requirement.

It does not fix long transactions or sustained write saturation.

Documentation: [busy_timeout](https://sqlite.org/pragma.html#pragma_busy_timeout)

## Optional Settings

These can help specific workloads but should be benchmarked.

### `cache_size`

```sql
PRAGMA cache_size = -65536;
```

A negative value is an approximate KiB target. `-65536` is approximately 64 MiB. A larger page cache can reduce reads at the cost of memory.

Documentation: [cache_size](https://sqlite.org/pragma.html#pragma_cache_size)

### `mmap_size`

```sql
PRAGMA mmap_size = 268435456;
```

Requests up to 256 MiB of memory-mapped I/O, subject to SQLite and platform limits. Some read-heavy workloads benefit; others do not.

Documentation: [Memory-Mapped I/O](https://sqlite.org/mmap.html), [mmap_size](https://sqlite.org/pragma.html#pragma_mmap_size)

### `temp_store = MEMORY`

```sql
PRAGMA temp_store = MEMORY;
```

Keeps eligible temporary structures in memory. This may help sort/temp-heavy workloads at the cost of additional memory.

Documentation: [temp_store](https://sqlite.org/pragma.html#pragma_temp_store)
