# Performance Tuning

Start with the baseline:

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 5000;
```

Then investigate, roughly in this order:

1. queries and query plans
2. indexes
3. transaction duration
4. write frequency/contention
5. optional SQLite settings

## Run `PRAGMA optimize`

```sql
PRAGMA optimize;
```

Use it periodically and after meaningful schema/index changes so SQLite can maintain useful planner statistics without requiring applications to manually manage `ANALYZE` in most cases.

Documentation: [PRAGMA optimize](https://sqlite.org/pragma.html#pragma_optimize), [ANALYZE](https://sqlite.org/lang_analyze.html)

## Optional: Larger Page Cache

```sql
PRAGMA cache_size = -65536;
```

Approximately 64 MiB. This can help when a useful working set fits in SQLite's page cache, but increases memory usage.

Documentation: [cache_size](https://sqlite.org/pragma.html#pragma_cache_size)

## Optional: Memory-Mapped I/O

```sql
PRAGMA mmap_size = 268435456;
```

Requests up to 256 MiB of memory-mapped database I/O. Benchmark it; larger values are not automatically faster.

Documentation: [Memory-Mapped I/O](https://sqlite.org/mmap.html), [mmap_size](https://sqlite.org/pragma.html#pragma_mmap_size)

## Optional: In-Memory Temporary Storage

```sql
PRAGMA temp_store = MEMORY;
```

May help workloads that create substantial temporary data, at the cost of memory.

Documentation: [temp_store](https://sqlite.org/pragma.html#pragma_temp_store)

## Avoid Unsafe Benchmark Settings

Do not copy settings such as:

```sql
PRAGMA synchronous = OFF;
```

into production solely because they improve benchmark throughput. Durability-related PRAGMAs change failure behavior.

Documentation: [synchronous](https://sqlite.org/pragma.html#pragma_synchronous)

## Benchmark the Real Workload

Measure with:

- realistic database sizes
- representative queries
- realistic read/write ratios
- realistic connection concurrency
- the production filesystem/storage class

Optimize the application workload, not a synthetic PRAGMA benchmark.
