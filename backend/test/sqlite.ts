// Node's built-in SQLite behind the same tiny interface the Durable Object SQL API exposes.
import { DatabaseSync } from "node:sqlite";
import type { Sql } from "../src/ledger";

export function memorySql(): Sql {
  const db = new DatabaseSync(":memory:");
  return {
    exec(query: string, ...binds: unknown[]) {
      const stmt = db.prepare(query);
      if (/^\s*(SELECT|WITH)/i.test(query) || /RETURNING/i.test(query)) {
        return stmt.all(...(binds as never[])) as Record<string, unknown>[];
      }
      stmt.run(...(binds as never[]));
      return [];
    },
  };
}
