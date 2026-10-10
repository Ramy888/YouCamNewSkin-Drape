import { beforeEach, describe, expect, it } from "vitest";
import { BudgetError, Ledger, migrateLedger, type Sql } from "../src/ledger";
import { memorySql } from "./sqlite";

let sql: Sql;
let now: number;
const make = (budget = 100, dailyCap = 60, faces = 1) =>
  new Ledger(sql, { budget, dailyCap, facesPerVisitorPerDay: faces }, () => now);

beforeEach(() => {
  sql = memorySql();
  migrateLedger(sql);
  now = Date.UTC(2026, 10, 5, 12);
});

const reason = (fn: () => unknown) => {
  try { fn(); } catch (e) { return (e as BudgetError).reason; }
  return "none";
};

describe("ledger", () => {
  it("blocks all spending when the live budget is 0", () => {
    expect(reason(() => make(0).reserve("j1", "tryon", "v1"))).toBe("disabled");
  });

  it("reserve counts against the budget before the call returns", () => {
    const l = make(10);
    l.reserve("j1", "tryon", "v1");
    expect(l.used()).toBe(2);
    expect(l.remaining()).toBe(8);
  });

  it("release gives units back, commit keeps them", () => {
    const l = make(10);
    l.reserve("a", "tryon", "v1");
    l.reserve("b", "tryon", "v1");
    l.release("a");
    l.commit("b");
    expect(l.used()).toBe(2);
    expect(l.summary()).toMatchObject({ committed: 2, released: 2, reserved: 0 });
  });

  it("a stuck (timed-out) task keeps its units until reconciled", () => {
    const l = make(10);
    l.reserve("a", "tryon", "v1");
    l.markStuck("a");
    expect(l.used()).toBe(2);
    expect(l.release("a")).toBe(true);
    expect(l.used()).toBe(0);
  });

  it("only allows legal state moves", () => {
    const l = make(10);
    l.reserve("a", "tryon", "v1");
    l.commit("a");
    expect(l.release("a")).toBe(false);
    expect(l.state("a")).toBe("committed");
    expect(l.commit("missing")).toBe(false);
  });

  it("at the cap, a burst of requests lets through exactly what fits", async () => {
    const l = make(5, 100, 99); // 5 units = two try-ons
    const results = await Promise.all(
      Array.from({ length: 10 }, (_, i) =>
        Promise.resolve().then(() => reason(() => l.reserve(`j${i}`, "tryon", `v${i}`))),
      ),
    );
    expect(results.filter((r) => r === "none")).toHaveLength(2);
    expect(results.filter((r) => r === "budget")).toHaveLength(8);
    expect(l.used()).toBe(4);
  });

  it("one new face reading per visitor per day", () => {
    const l = make(200, 200, 1);
    l.reserve("f1", "color_reading", "v1");
    expect(reason(() => l.reserve("f2", "color_reading", "v1"))).toBe("visitor");
    expect(reason(() => l.reserve("f3", "color_reading", "v2"))).toBe("none");
    now += 24 * 3600 * 1000;
    expect(reason(() => l.reserve("f4", "color_reading", "v1"))).toBe("none");
  });

  it("a released face reading does not use up the visitor's daily face", () => {
    const l = make(200, 200, 1);
    l.reserve("f1", "color_reading", "v1");
    l.release("f1");
    expect(reason(() => l.reserve("f2", "color_reading", "v1"))).toBe("none");
  });

  it("enforces the daily cap across visitors and resets the next day", () => {
    const l = make(100, 4, 9);
    l.reserve("a", "tryon", "v1");
    l.reserve("b", "tryon", "v2");
    expect(reason(() => l.reserve("c", "tryon", "v3"))).toBe("daily");
    now += 24 * 3600 * 1000;
    expect(reason(() => l.reserve("d", "tryon", "v3"))).toBe("none");
  });
});
