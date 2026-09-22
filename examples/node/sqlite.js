// Minimal SQLite production connection example using better-sqlite3.

import { DatabaseSync } from "node:sqlite";

const db = new DatabaseSync("example.db", {
  timeout: 5000,
});

try {
  // Persistent database setting.
  db.exec("PRAGMA journal_mode = WAL");

  // Connection settings.
  db.exec(`
    PRAGMA foreign_keys = ON;
    PRAGMA synchronous = NORMAL;
    PRAGMA busy_timeout = 5000;
  `);

  const getPragma = (name) =>
    db.prepare(`PRAGMA ${name}`).get();

  console.log({
    journalMode: getPragma("journal_mode").journal_mode,
    foreignKeys: getPragma("foreign_keys").foreign_keys,
    synchronous: getPragma("synchronous").synchronous,
    busyTimeoutMs: getPragma("busy_timeout").timeout,
  });
} finally {
  db.close();
}