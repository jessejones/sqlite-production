#!/usr/bin/env bash

set -euo pipefail

DB_PATH="${1:-}"

if [ -z "$DB_PATH" ]; then
  echo "Usage: $0 <database-path>"
  exit 1
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Error: sqlite3 is not installed or not in PATH."
  exit 1
fi

DB_DIR="$(dirname "$DB_PATH")"

if [ "$DB_DIR" != "." ]; then
  mkdir -p "$DB_DIR"
fi

echo "Initializing SQLite database: $DB_PATH"

JOURNAL_MODE="$(
  sqlite3 "$DB_PATH" <<'SQL'
PRAGMA journal_mode = WAL;
SQL
)"

# SQLite returns "wal". tr keeps this compatible with macOS Bash 3.2.
JOURNAL_MODE_NORMALIZED="$(printf '%s' "$JOURNAL_MODE" | tr '[:upper:]' '[:lower:]')"

if [ "$JOURNAL_MODE_NORMALIZED" != "wal" ]; then
  echo "Error: failed to enable WAL mode (got: $JOURNAL_MODE)"
  exit 1
fi

sqlite3 "$DB_PATH" <<'SQL'
PRAGMA foreign_keys = ON;
PRAGMA synchronous = NORMAL;
PRAGMA busy_timeout = 5000;
PRAGMA optimize;
SQL

INTEGRITY="$(sqlite3 "$DB_PATH" "PRAGMA quick_check;")"

if [ "$INTEGRITY" != "ok" ]; then
  echo "Error: database integrity check failed:"
  echo "$INTEGRITY"
  exit 1
fi

echo
echo "SQLite database ready."
echo
echo "Database:"
echo "  $DB_PATH"
echo
echo "Persistent settings:"
echo "  journal_mode = $(sqlite3 "$DB_PATH" "PRAGMA journal_mode;")"
echo
echo "Recommended connection settings:"
echo "  foreign_keys = ON"
echo "  synchronous = NORMAL"
echo "  busy_timeout = 5000"
echo
echo "Integrity check:"
echo "  $INTEGRITY"