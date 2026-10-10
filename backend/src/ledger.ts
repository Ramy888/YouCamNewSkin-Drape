// Unit ledger: every paid YouCam call reserves units first, then commits on success or releases on error.
// A task that times out keeps its reservation ("stuck") until it is reconciled, because YouCam may still
// finish it and charge us. Runs inside one Durable Object, so each method is a single synchronous
// transaction: two requests can never both pass the cap.
//
//   reserve ──▶ [reserved] ──success──▶ [committed]
//                   │──error────▶ [released]
//                   └──timeout──▶ [stuck] ──reconcile──▶ committed | released

export interface Sql {
  exec(query: string, ...binds: unknown[]): Record<string, unknown>[];
}

export type Entry = "reserved" | "committed" | "released" | "stuck";

export interface Limits {
  /** Total units the live app may spend (YOUCAM_LIVE_BUDGET). 0 means live spending is off. */
  budget: number;
  /** Units per UTC day across all visitors. */
  dailyCap: number;
  /** New face readings (colour reading jobs) per visitor per UTC day. */
  facesPerVisitorPerDay: number;
}

export class BudgetError extends Error {
  constructor(public reason: "budget" | "daily" | "visitor" | "disabled") {
    super(`unit spend blocked: ${reason}`);
  }
}

export const UNIT_COST = {
  color_reading: 20,
  tryon: 2,
  makeup: 1,
  jewelry: 1,
} as const;
export type JobType = keyof typeof UNIT_COST;

export function migrateLedger(sql: Sql): void {
  sql.exec(`CREATE TABLE IF NOT EXISTS ledger (
    id TEXT PRIMARY KEY,
    job_type TEXT NOT NULL,
    units INTEGER NOT NULL,
    state TEXT NOT NULL,
    visitor TEXT NOT NULL,
    day TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )`);
}

const today = (now: number) => new Date(now).toISOString().slice(0, 10);

export class Ledger {
  constructor(private sql: Sql, private limits: Limits, private clock: () => number = Date.now) {}

  /** Units that count against the budget: committed + reserved + stuck. */
  used(): number {
    const row = this.sql.exec(`SELECT COALESCE(SUM(units),0) AS u FROM ledger WHERE state != 'released'`)[0];
    return Number(row?.u ?? 0);
  }

  usedToday(): number {
    const row = this.sql.exec(
      `SELECT COALESCE(SUM(units),0) AS u FROM ledger WHERE state != 'released' AND day = ?`,
      today(this.clock()),
    )[0];
    return Number(row?.u ?? 0);
  }

  remaining(): number {
    return Math.max(0, this.limits.budget - this.used());
  }

  /** Reserve units for one paid call. Throws BudgetError when any limit would be crossed. */
  reserve(id: string, jobType: JobType, visitor: string): number {
    const units = UNIT_COST[jobType];
    const now = this.clock();
    if (this.limits.budget <= 0) throw new BudgetError("disabled");
    if (this.used() + units > this.limits.budget) throw new BudgetError("budget");
    if (this.usedToday() + units > this.limits.dailyCap) throw new BudgetError("daily");
    if (jobType === "color_reading") {
      const row = this.sql.exec(
        `SELECT COUNT(*) AS n FROM ledger WHERE visitor = ? AND day = ? AND job_type = 'color_reading' AND state != 'released'`,
        visitor,
        today(now),
      )[0];
      if (Number(row?.n ?? 0) >= this.limits.facesPerVisitorPerDay) throw new BudgetError("visitor");
    }
    this.sql.exec(
      `INSERT INTO ledger (id, job_type, units, state, visitor, day, created_at, updated_at) VALUES (?,?,?,?,?,?,?,?)`,
      id, jobType, units, "reserved", visitor, today(now), now, now,
    );
    return units;
  }

  private move(id: string, from: Entry[], to: Entry): boolean {
    const placeholders = from.map(() => "?").join(",");
    const before = this.sql.exec(`SELECT state FROM ledger WHERE id = ?`, id)[0];
    if (!before || !from.includes(before.state as Entry)) return false;
    this.sql.exec(
      `UPDATE ledger SET state = ?, updated_at = ? WHERE id = ? AND state IN (${placeholders})`,
      to, this.clock(), id, ...from,
    );
    return true;
  }

  commit(id: string): boolean { return this.move(id, ["reserved", "stuck"], "committed"); }
  release(id: string): boolean { return this.move(id, ["reserved", "stuck"], "released"); }
  markStuck(id: string): boolean { return this.move(id, ["reserved"], "stuck"); }

  state(id: string): Entry | undefined {
    return this.sql.exec(`SELECT state FROM ledger WHERE id = ?`, id)[0]?.state as Entry | undefined;
  }

  summary() {
    const rows = this.sql.exec(`SELECT state, COALESCE(SUM(units),0) AS u FROM ledger GROUP BY state`);
    const by: Record<string, number> = { reserved: 0, committed: 0, released: 0, stuck: 0 };
    for (const r of rows) by[String(r.state)] = Number(r.u);
    return { budget: this.limits.budget, used: this.used(), remaining: this.remaining(), usedToday: this.usedToday(), ...by };
  }
}
