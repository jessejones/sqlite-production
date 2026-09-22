# Backups

Production SQLite databases need automated, tested backups.

## Online Backup API

SQLite's Online Backup API creates a consistent snapshot of a live database and can copy it incrementally.

Documentation: [Online Backup API](https://sqlite.org/backup.html)

## `VACUUM INTO`

```sql
VACUUM INTO 'backup.db';
```

`VACUUM INTO` creates a compact database copy and is useful when a full snapshot is appropriate.

Documentation: [`VACUUM INTO`](https://sqlite.org/lang_vacuum.html#vacuuminto)

## Avoid Naive Live Copies

An active WAL-mode database can involve:

```text
app.db
app.db-wal
app.db-shm
```

Do not assume copying only `app.db` while the database is active captures the current state. Prefer SQLite-aware backup mechanisms.

Documentation: [WAL](https://sqlite.org/wal.html)

## Production Checklist

- automate backups
- store backups separately from the database host
- define retention
- monitor backup failures
- periodically restore a backup
- verify restored data
