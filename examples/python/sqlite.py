"""Minimal SQLite production connection example using Python's standard library."""

import sqlite3
from pathlib import Path

DB_PATH = Path("example.db")


def connect(path: str | Path) -> sqlite3.Connection:
    connection = sqlite3.connect(
        path,
        timeout=5.0,
    )

    # Persistent database setting.
    connection.execute("PRAGMA journal_mode = WAL")

    # Connection settings.
    connection.execute("PRAGMA foreign_keys = ON")
    connection.execute("PRAGMA synchronous = NORMAL")
    connection.execute("PRAGMA busy_timeout = 5000")

    return connection


if __name__ == "__main__":
    db = connect(DB_PATH)

    try:
        settings = {
            "journal_mode": db.execute(
                "PRAGMA journal_mode"
            ).fetchone()[0],
            "foreign_keys": db.execute(
                "PRAGMA foreign_keys"
            ).fetchone()[0],
            "synchronous": db.execute(
                "PRAGMA synchronous"
            ).fetchone()[0],
            "busy_timeout_ms": db.execute(
                "PRAGMA busy_timeout"
            ).fetchone()[0],
        }

        for key, value in settings.items():
            print(f"{key}: {value}")
    finally:
        db.close()
