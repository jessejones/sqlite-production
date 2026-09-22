# Litestream

[Litestream](https://litestream.io/) continuously replicates SQLite databases to external storage.

It is a useful option for production SQLite deployments that need:

- continuous off-host replication
- disaster recovery
- point-in-time recovery
- S3-compatible object storage
- replication without application-level backup code

Litestream runs alongside the application and monitors the SQLite database for changes.

## When to Use Litestream

Litestream is particularly useful for single-server deployments where SQLite lives on fast local storage.

A common architecture is:

```text
Application
    │
    ▼
SQLite
(local disk)
    │
    ▼
Litestream
    │
    ▼
Object Storage
(S3 / S3-compatible / GCS / Azure / etc.)
```

The application continues reading and writing the local SQLite database. Litestream handles replication separately.

This preserves one of SQLite's main advantages: database operations remain local rather than becoming network requests.

## Install

Follow the current installation instructions:

https://litestream.io/install/

Verify the installation:

```bash
litestream version
```

## Quick Start

A simple replication command looks like:

```bash
litestream replicate app.db s3://my-bucket/my-app
```

Litestream continues running and replicates database changes to the configured destination.

For production deployments, prefer a configuration file and run Litestream as a long-running service.

Official documentation:

https://litestream.io/reference/replicate/

## Configuration

A minimal configuration can look like:

```yaml
dbs:
  - path: /var/lib/my-app/app.db
    replica:
      url: s3://my-bucket/my-app
```

Then start replication:

```bash
litestream replicate
```

Keep credentials outside the configuration file when possible. Use environment variables, IAM roles, workload identities, or the credential mechanism provided by your storage provider.

See:

https://litestream.io/reference/config/

## S3-Compatible Storage

Litestream can work with S3-compatible object storage in addition to Amazon S3.

This makes it suitable for deployments using compatible object-storage providers.

Configuration varies by provider. Follow Litestream's current replica and configuration documentation for endpoint, region, credentials, and path settings.

See:

- https://litestream.io/guides/s3/
- https://litestream.io/reference/config/

## Restore

Restore the latest available database to a new file:

```bash
litestream restore \
  -o restored.db \
  s3://my-bucket/my-app
```

Verify the restored database:

```bash
sqlite3 restored.db "PRAGMA quick_check;"
```

Expected output:

```text
ok
```

Litestream can also perform an integrity check as part of the restore:

```bash
litestream restore \
  -integrity-check quick \
  -o restored.db \
  s3://my-bucket/my-app
```

See:

https://litestream.io/reference/restore/

## Point-in-Time Recovery

When the required history is available, Litestream can restore the database to an earlier point in time.

Example:

```bash
litestream restore \
  -timestamp 2026-09-22T12:00:00Z \
  -o restored.db \
  s3://my-bucket/my-app
```

Point-in-time recovery is useful for recovering from application-level problems such as accidental deletes or bad writes that were successfully replicated.

See the current restore documentation for supported recovery options:

https://litestream.io/reference/restore/

## Local Testing

You can test Litestream without cloud storage by using a local file replica.

Start replication:

```bash
litestream replicate \
  app.db \
  file://$PWD/litestream-replica
```

In another terminal, write some data:

```bash
sqlite3 app.db \
  "CREATE TABLE IF NOT EXISTS test (
    id INTEGER PRIMARY KEY,
    value TEXT NOT NULL
  );"

sqlite3 app.db \
  "INSERT INTO test (value) VALUES ('hello');"
```

After Litestream has replicated the change, stop the replication process.

Restore into a different database:

```bash
litestream restore \
  -o restored.db \
  file://$PWD/litestream-replica
```

Verify the data:

```bash
sqlite3 restored.db "SELECT * FROM test;"
```

The restored database should contain the inserted row.

Local file replicas are useful for testing the workflow, but they do not provide protection from host or disk failure.

## Production Recommendations

### Replicate off-host

Store production replicas separately from the machine containing the primary database.

A replica on the same disk does not protect against disk or host failure.

### Protect credentials

Do not commit storage credentials to Git.

Prefer:

- environment variables
- IAM roles
- workload identities
- secrets management

### Monitor replication

Monitor Litestream so replication failures do not go unnoticed.

A backup system that stopped replicating days ago provides a false sense of protection.

### Test restores

Replication is only half of the backup strategy.

Periodically restore into a separate database:

```bash
litestream restore \
  -integrity-check quick \
  -o restore-test.db \
  s3://my-bucket/my-app
```

Then verify the restored database and, ideally, run application-level checks against it.

## Litestream vs. SQLite Backups

Litestream complements SQLite's built-in backup mechanisms.

| Method | Best For |
| --- | --- |
| Online Backup API | Application-controlled snapshots |
| `VACUUM INTO` | Manual or scheduled compact snapshots |
| Litestream | Continuous off-host replication and recovery |

Using Litestream does not prevent you from also creating periodic independent snapshots.

For important databases, multiple recovery mechanisms can provide additional protection.

## Further Reading

Litestream:

- [Documentation](https://litestream.io/)
- [Installation](https://litestream.io/install/)
- [Configuration](https://litestream.io/reference/config/)
- [Replication](https://litestream.io/reference/replicate/)
- [Restore](https://litestream.io/reference/restore/)

SQLite:

- [Write-Ahead Logging](https://sqlite.org/wal.html)
- [Online Backup API](https://sqlite.org/backup.html)
- [`VACUUM INTO`](https://sqlite.org/lang_vacuum.html#vacuuminto)