// DrapeState: the one Durable Object that owns all state (stores, products, sessions, jobs, unit ledger).
// A single instance means every unit reservation is serialised; SQLite storage keeps it durable.
//
//  app ──POST /v1/sessions/me/jobs──▶ createJob ──replay──▶ done immediately (0 units)
//                                        │
//                                        └─live──▶ ledger.reserve ──▶ queued ──alarm──▶ runLiveJob
//                                                     │ BudgetError                     ├ success → commit, copy image to R2
//                                                     ▼                                 ├ photo/rejected/upstream → release
//                                              done as labelled sample                  └ timeout → stuck (kept reserved)
import { DurableObject } from "cloudflare:workers";
import { bearer, hashKey, signSession, verifySession, visitorId } from "./auth";
import { bad, DrapeError, errorResponse } from "./errors";
import { randomId, sha256Hex, stripJpegMetadata, validateImage } from "./images";
import { BudgetError, Ledger, migrateLedger, type JobType, type Sql, UNIT_COST } from "./ledger";
import { linkKeys, validLink } from "./links";
import { buildPalette, verdictFor, type Palette } from "./palette";
import rules from "./palette-rules.json";
import { earringAsset, earringPayload, LiveYouCam, type Metal, PERSONA_READING, REPLAY_MAKEUP, replayEarringPath, replayTryonPath, type ColorTonesColor, YouCamError } from "./youcam";

export interface Env {
  DRAPE: DurableObjectNamespace<DrapeState>;
  FILES: R2Bucket;
  ASSETS: Fetcher;
  YOUCAM_MODE?: string;
  YOUCAM_API_KEY?: string;
  YOUCAM_API_BASE?: string;
  YOUCAM_LIVE_BUDGET?: string;
  DAILY_UNIT_CAP?: string;
  FACES_PER_VISITOR_PER_DAY?: string;
  FORCE_REPLAY?: string;
  JUDGE_CODE?: string;
  SESSION_SECRET?: string;
  SELLER_SECRET?: string;
  DEMO_PUBLISHABLE_KEY?: string;
  ALLOWED_ORIGINS?: string;
  PUBLIC_ORIGIN?: string;
}

type Category = "upper_body" | "lower_body" | "full_body" | "outer";
const CATEGORIES: Category[] = ["upper_body", "lower_body", "full_body", "outer"];
const SESSION_TTL_MS = 24 * 3600 * 1000;

interface Colorway { id: string; name: string; hex: string; image: string }
interface Product { id: string; storeId: string; name: string; category: Category; price: number; currency: string; colorways: Colorway[]; links?: string[]; status: string }
interface SessionRow {
  id: string; store_id: string; store_origin: string; visitor: string; persona: number; live: number;
  face_key: string | null; body_key: string | null; reading: string | null; override: string | null;
  created_at: number; expires_at: number;
}

/** Bump when SEED_PRODUCTS changes so deployed stores pick up the new seed catalogue. */
const SEED_VERSION = "4";
const SEED_PRODUCTS: Omit<Product, "storeId" | "status">[] = [
  {
    id: "abaya-classic",
    name: "Classic satin abaya",
    category: "full_body",
    price: 890,
    currency: "EGP",
    colorways: [
      { id: "black", name: "Black", hex: "#1c1c1e", image: "/catalog/abaya-classic_black.jpg" },
      { id: "emerald", name: "Emerald", hex: "#1f7a55", image: "/catalog/abaya-classic_emerald.jpg" },
      { id: "lavender", name: "Lavender", hex: "#b7a6d8", image: "/catalog/abaya-classic_lavender.jpg" },
    ],
    links: ["https://noor-modest.ramy-comm.workers.dev/"],
  },
  {
    id: "kaftan-coat",
    name: "Woven kaftan coat",
    category: "outer",
    price: 1450,
    currency: "EGP",
    colorways: [
      { id: "saffron", name: "Saffron", hex: "#deaa4b", image: "/catalog/kaftan-coat_saffron.jpg" },
      { id: "aqua", name: "Aqua", hex: "#4ab8b5", image: "/catalog/kaftan-coat_aqua.jpg" },
      { id: "blush", name: "Blush pink", hex: "#ed9ece", image: "/catalog/kaftan-coat_blush.jpg" },
    ],
  },
];

export class DrapeState extends DurableObject<Env> {
  private sql: Sql;
  private ledger: Ledger;
  /** Origin the Worker was reached on (set per request); used when PUBLIC_ORIGIN isn't configured. */
  private selfOrigin = "";

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env);
    const raw = ctx.storage.sql;
    this.sql = { exec: (q, ...b) => raw.exec(q, ...b).toArray() as Record<string, unknown>[] };
    ctx.blockConcurrencyWhile(async () => this.migrate());
    this.ledger = new Ledger(this.sql, {
      budget: Number(env.YOUCAM_LIVE_BUDGET ?? 0),
      dailyCap: Number(env.DAILY_UNIT_CAP ?? 120),
      facesPerVisitorPerDay: Number(env.FACES_PER_VISITOR_PER_DAY ?? 1),
    });
  }

  private migrate() {
    migrateLedger(this.sql);
    this.sql.exec(`CREATE TABLE IF NOT EXISTS stores (id TEXT PRIMARY KEY, name TEXT, pk TEXT UNIQUE, sk_hash TEXT, origins TEXT)`);
    this.sql.exec(`CREATE TABLE IF NOT EXISTS products (id TEXT PRIMARY KEY, store_id TEXT, data TEXT, status TEXT, updated_at INTEGER)`);
    this.sql.exec(`CREATE TABLE IF NOT EXISTS sessions (id TEXT PRIMARY KEY, store_id TEXT, store_origin TEXT, visitor TEXT, persona INTEGER,
      live INTEGER, face_key TEXT, body_key TEXT, reading TEXT, override TEXT, created_at INTEGER, expires_at INTEGER)`);
    this.sql.exec(`CREATE TABLE IF NOT EXISTS jobs (id TEXT PRIMARY KEY, session_id TEXT, type TEXT, params TEXT, dedupe TEXT,
      status TEXT, result TEXT, error TEXT, ledger_id TEXT, created_at INTEGER, updated_at INTEGER)`);
    this.sql.exec(`CREATE INDEX IF NOT EXISTS jobs_session ON jobs(session_id)`);
    this.sql.exec(`CREATE TABLE IF NOT EXISTS kv (k TEXT PRIMARY KEY, v TEXT)`);
  }

  // ---------- configuration ----------

  private origins(): string[] {
    const list = (this.env.ALLOWED_ORIGINS ?? "").split(",").map((s) => s.trim()).filter(Boolean);
    const self = this.env.PUBLIC_ORIGIN ?? this.selfOrigin;
    if (self) list.push(self);
    return [...new Set(list)];
  }

  private async demoStore() {
    const pk = this.env.DEMO_PUBLISHABLE_KEY ?? "pk_demo_drape";
    const skHash = this.env.SELLER_SECRET ? await hashKey(this.env.SELLER_SECRET) : null;
    this.sql.exec(
      `INSERT INTO stores (id, name, pk, sk_hash, origins) VALUES ('demo', 'Noor Modest (demo store)', ?, ?, ?)
       ON CONFLICT(id) DO UPDATE SET pk = excluded.pk, sk_hash = excluded.sk_hash, origins = excluded.origins`,
      pk, skHash, JSON.stringify(this.origins()),
    );
    if (this.kv("seed_version") !== SEED_VERSION) {
      for (const p of SEED_PRODUCTS) {
        this.sql.exec(`INSERT INTO products (id, store_id, data, status, updated_at) VALUES (?, 'demo', ?, 'published', ?)
          ON CONFLICT(id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at`, p.id, JSON.stringify(p), Date.now());
      }
      this.setKv("seed_version", SEED_VERSION);
    }
  }

  private forcedReplay(): boolean {
    if (this.env.FORCE_REPLAY === "1") return true;
    const until = Number(this.kv("force_replay_until") ?? 0);
    return until > Date.now();
  }

  private liveAvailable(): boolean {
    return this.env.YOUCAM_MODE === "live" && !!this.env.YOUCAM_API_KEY && Number(this.env.YOUCAM_LIVE_BUDGET ?? 0) > 0 && !this.forcedReplay();
  }

  private kv(k: string): string | undefined {
    return this.sql.exec(`SELECT v FROM kv WHERE k = ?`, k)[0]?.v as string | undefined;
  }
  private setKv(k: string, v: string) {
    this.sql.exec(`INSERT INTO kv (k, v) VALUES (?, ?) ON CONFLICT(k) DO UPDATE SET v = excluded.v`, k, v);
  }

  // ---------- HTTP ----------

  async fetch(req: Request): Promise<Response> {
    const requestId = req.headers.get("cf-ray") ?? randomId("req_", 8);
    this.selfOrigin = req.headers.get("x-drape-origin") ?? this.selfOrigin;
    try {
      await this.demoStore();
      const res = await this.route(req, new URL(req.url));
      res.headers.set("x-request-id", requestId);
      return res;
    } catch (e) {
      return errorResponse(e, requestId);
    }
  }

  private async route(req: Request, url: URL): Promise<Response> {
    const p = url.pathname;
    const m = req.method;
    if (p === "/health") return this.health();
    if (p === "/internal/sweep" && m === "POST") return Response.json(await this.sweep());
    if (p === "/v1/catalog" && m === "GET") return this.catalog(url);
    if (p === "/v1/lookup" && m === "GET") return this.lookup(url);
    let mm = p.match(/^\/v1\/products\/([a-z0-9-]+)$/);
    if (mm && m === "GET") return Response.json({ product: this.product(mm[1], true) });
    if (p === "/v1/products" && m === "POST") return this.upsertProduct(req);
    mm = p.match(/^\/v1\/products\/([a-z0-9-]+)\/colorways\/([a-z0-9-]+)\/image$/);
    if (mm && m === "PUT") return this.uploadColorwayImage(req, mm[1], mm[2]);
    if (p === "/v1/sessions" && m === "POST") return this.createSession(req);
    if (p === "/v1/sessions/me" && m === "GET") return Response.json(await this.sessionView(await this.session(req)));
    if (p === "/v1/sessions/me" && m === "DELETE") return Response.json(await this.deleteSession(await this.session(req)));
    if (p === "/v1/sessions/me/photos" && m === "POST") return this.uploadPhoto(req, url);
    if (p === "/v1/sessions/me/jobs" && m === "POST") return this.createJob(req);
    if (p === "/v1/sessions/me/palette" && m === "POST") return this.paletteOverride(req);
    mm = p.match(/^\/v1\/jobs\/(job_[0-9a-f]+)$/);
    if (mm && m === "GET") return this.getJob(req, mm[1]);
    mm = p.match(/^\/v1\/files\/((?:cat|u|r)\/[A-Za-z0-9_\-/.]+)$/);
    if (mm && m === "GET") return this.file(mm[1]);
    if (p === "/v1/admin/ledger" && m === "GET") { await this.seller(req); return Response.json({ ...this.ledger.summary(), stuckEntries: this.ledger.stuck() }); }
    if (p === "/v1/admin/products" && m === "GET") {
      await this.seller(req);
      const rows = this.sql.exec(`SELECT id FROM products WHERE store_id = 'demo' ORDER BY id`);
      return Response.json({ products: rows.map((r) => this.product(String(r.id), false)) });
    }
    if (p === "/v1/admin/reconcile" && m === "POST") return this.reconcile(req);
    throw new DrapeError("DRAPE_NOT_FOUND", 404, `No endpoint ${m} ${p}.`, "Check the API reference in the README.");
  }

  private async health(): Promise<Response> {
    let replayAssets = false;
    try {
      replayAssets = (await this.env.ASSETS.fetch(new Request("https://assets.local/persona/color_tones.json"))).ok;
    } catch { replayAssets = false; }
    const summary = this.ledger.summary();
    const live = this.liveAvailable();
    return Response.json({
      ok: replayAssets,
      mode: live ? "live" : "replay",
      liveKeyPresent: !!this.env.YOUCAM_API_KEY,
      forcedReplay: this.forcedReplay(),
      units: summary,
      replayAssets,
      rulesVersion: rules.version,
    }, { status: replayAssets ? 200 : 503 });
  }

  // ---------- products ----------

  private store(pk: string | null) {
    const row = this.sql.exec(`SELECT * FROM stores WHERE pk = ?`, pk ?? "")[0];
    if (!row) throw new DrapeError("DRAPE_BAD_KEY", 401, "That publishable key doesn't match any store.", "Use the data-drape-key value from your Drape seller console.");
    return { id: String(row.id), name: String(row.name), origins: JSON.parse(String(row.origins)) as string[] };
  }

  private product(id: string, publishedOnly: boolean): Product {
    const row = this.sql.exec(`SELECT * FROM products WHERE id = ?`, id)[0];
    if (!row || (publishedOnly && row.status !== "published")) {
      throw new DrapeError("DRAPE_PRODUCT_NOT_FOUND", 404, `No published product "${id}".`, "Check data-drape-product matches a product id in your seller console.");
    }
    return { ...(JSON.parse(String(row.data)) as Product), storeId: String(row.store_id), status: String(row.status) };
  }

  private catalog(url: URL): Response {
    const store = this.store(url.searchParams.get("key"));
    const rows = this.sql.exec(`SELECT id FROM products WHERE store_id = ? AND status = 'published' ORDER BY id`, store.id);
    return Response.json({ store: { id: store.id, name: store.name }, products: rows.map((r) => this.product(String(r.id), true)) });
  }

  /** Match a page address against products' listing links (extension door). Only the address is used. */
  private lookup(url: URL): Response {
    let wanted: string[];
    try { wanted = linkKeys(url.searchParams.get("url") ?? ""); }
    catch { throw bad("url must be a web address.", "Send ?url=https://…"); }
    const rows = this.sql.exec(`SELECT p.id, s.pk, s.name FROM products p JOIN stores s ON s.id = p.store_id WHERE p.status = 'published' ORDER BY p.id`);
    for (const r of rows) {
      const product = this.product(String(r.id), true);
      const keys = new Set((product.links ?? []).flatMap((l) => { try { return linkKeys(l); } catch { return []; } }));
      if (wanted.some((k) => keys.has(k))) {
        return Response.json({ product: { id: product.id, name: product.name, colorways: product.colorways.map((c) => ({ id: c.id, name: c.name, hex: c.hex })) }, store: { name: String(r.name), key: String(r.pk) } });
      }
    }
    throw new DrapeError("DRAPE_PRODUCT_NOT_FOUND", 404, "This product isn't on Drape yet.", "Ask the seller to add it to Drape with this page's link.");
  }

  private async seller(req: Request) {
    const key = bearer(req);
    const row = this.sql.exec(`SELECT sk_hash FROM stores WHERE id = 'demo'`)[0];
    if (!key || !row?.sk_hash || (await hashKey(key)) !== row.sk_hash) {
      throw new DrapeError("DRAPE_UNAUTHORIZED", 401, "Seller key missing or wrong.", "Sign in to the seller console with the secret key you were issued.");
    }
  }

  private async upsertProduct(req: Request): Promise<Response> {
    await this.seller(req);
    const body = (await req.json().catch(() => null)) as Partial<Product> | null;
    if (!body?.id || !/^[a-z0-9-]{3,40}$/.test(body.id)) throw bad("Product id must be 3–40 lowercase letters, digits or dashes.", 'Send {"id":"abaya-classic", ...}.');
    if (!body.name || body.name.length > 80) throw bad("Product name is required (max 80 characters).", "Send a name.");
    if (!body.category || !CATEGORIES.includes(body.category)) {
      throw new DrapeError("DRAPE_CATEGORY_UNSUPPORTED", 400, `Category must be one of ${CATEGORIES.join(", ")}.`, "Pick the garment category that matches the photo.");
    }
    const colorways = (body.colorways ?? []).map((c) => {
      if (!c.id || !/^[a-z0-9-]{2,30}$/.test(c.id) || !/^#[0-9a-f]{6}$/i.test(c.hex ?? "")) throw bad(`Colorway "${c.id}" needs an id and a #rrggbb hex.`, "Fix the colorway.");
      return { id: c.id, name: (c.name ?? c.id).slice(0, 40), hex: c.hex.toLowerCase(), image: c.image ?? "" };
    });
    if (colorways.length === 0) throw bad("Add at least one colorway.", "Send colorways: [{id, name, hex}].");
    const links = (body.links ?? []).map(String).filter((l) => l.trim());
    if (links.length > 10 || links.some((l) => !validLink(l))) throw bad("links must be up to 10 web addresses (https://…).", "Paste the product page URL from each store where you sell it.");
    let existing: Product | undefined;
    try { existing = this.product(body.id, false); } catch { existing = undefined; }
    for (const c of colorways) c.image = existing?.colorways.find((x) => x.id === c.id)?.image ?? c.image;
    const product: Omit<Product, "storeId" | "status"> = {
      id: body.id, name: body.name, category: body.category, price: Number(body.price ?? 0), currency: body.currency ?? "EGP", colorways, links,
    };
    const status = body.status === "draft" || body.status === "disabled" ? body.status : "published";
    this.sql.exec(`INSERT INTO products (id, store_id, data, status, updated_at) VALUES (?, 'demo', ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET data = excluded.data, status = excluded.status, updated_at = excluded.updated_at`,
      product.id, JSON.stringify(product), status, Date.now());
    return Response.json({ product: this.product(product.id, false) });
  }

  private async uploadColorwayImage(req: Request, pid: string, cid: string): Promise<Response> {
    await this.seller(req);
    const product = this.product(pid, false);
    const cw = product.colorways.find((c) => c.id === cid);
    if (!cw) throw bad(`Product ${pid} has no colorway ${cid}.`, "Create the colorway first.");
    const bytes = new Uint8Array(await req.arrayBuffer());
    const type = validateImage(bytes);
    const key = `cat/${pid}/${cid}-${randomId("", 6)}.${type === "image/png" ? "png" : "jpg"}`;
    await this.env.FILES.put(key, stripJpegMetadata(bytes), { httpMetadata: { contentType: type } });
    cw.image = `/v1/files/${key}`;
    const { storeId: _s, status, ...data } = product;
    this.sql.exec(`UPDATE products SET data = ?, updated_at = ? WHERE id = ?`, JSON.stringify(data), Date.now(), pid);
    return Response.json({ product: this.product(pid, false), status });
  }

  private async file(key: string): Promise<Response> {
    const obj = await this.env.FILES.get(key);
    if (!obj) throw new DrapeError("DRAPE_NOT_FOUND", 404, "That file doesn't exist or has expired.", "Files you upload are deleted after 24 hours.");
    const h = new Headers();
    obj.writeHttpMetadata(h);
    h.set("cache-control", key.startsWith("cat/") ? "public, max-age=3600" : "private, no-store");
    return new Response(obj.body, { headers: h });
  }

  // ---------- sessions ----------

  private async createSession(req: Request): Promise<Response> {
    const body = (await req.json().catch(() => ({}))) as { key?: string; storeOrigin?: string; persona?: boolean; judgeCode?: string };
    const store = this.store(body.key ?? null);
    const origin = body.storeOrigin ?? this.env.PUBLIC_ORIGIN ?? this.selfOrigin;
    if (!store.origins.includes(origin)) {
      throw new DrapeError("DRAPE_DOMAIN_NOT_ALLOWED", 403, `${origin || "This site"} is not on the store's allowed list.`, "Add your shop's origin (https://your-shop.com) in the seller console.");
    }
    const persona = !!body.persona;
    const judgeOk = !this.env.JUDGE_CODE || body.judgeCode === this.env.JUDGE_CODE;
    const live = !persona && judgeOk && this.liveAvailable();
    const id = randomId("ses_");
    const now = Date.now();
    const visitor = await visitorId(req, this.env.SESSION_SECRET ?? "dev");
    this.sql.exec(`INSERT INTO sessions (id, store_id, store_origin, visitor, persona, live, created_at, expires_at) VALUES (?,?,?,?,?,?,?,?)`,
      id, store.id, origin, visitor, persona ? 1 : 0, live ? 1 : 0, now, now + SESSION_TTL_MS);
    const token = await signSession(this.secret(), id, now + SESSION_TTL_MS);
    return Response.json({ token, session: await this.sessionView(this.sessionRow(id)) }, { status: 201 });
  }

  private secret(): string {
    if (this.env.SESSION_SECRET) return this.env.SESSION_SECRET;
    if (this.env.YOUCAM_MODE === "live") throw new DrapeError("DRAPE_INTERNAL", 500, "Server misconfigured.", "Set SESSION_SECRET.");
    return "dev-only-session-secret";
  }

  private sessionRow(id: string): SessionRow {
    const row = this.sql.exec(`SELECT * FROM sessions WHERE id = ?`, id)[0] as unknown as SessionRow | undefined;
    if (!row || row.expires_at < Date.now()) throw new DrapeError("DRAPE_SESSION_NOT_FOUND", 404, "This session has ended.", "Start again from the product page.");
    return row;
  }

  private async session(req: Request): Promise<SessionRow> {
    return this.sessionRow(await verifySession(this.secret(), bearer(req)));
  }

  private palette(s: SessionRow): Palette | null {
    if (!s.reading) return null;
    return buildPalette(JSON.parse(s.reading) as ColorTonesColor, (s.override ?? undefined) as "warmer" | "cooler" | undefined);
  }

  private async sessionView(s: SessionRow) {
    const palette = this.palette(s);
    const products = this.sql.exec(`SELECT id FROM products WHERE store_id = ? AND status = 'published' ORDER BY id`, s.store_id)
      .map((r) => this.product(String(r.id), true))
      .map((p) => ({
        ...p,
        colorways: p.colorways.map((c) => ({ ...c, ...(palette ? verdictFor(palette, c.hex) : {}) })),
      }));
    const jobs = this.sql.exec(`SELECT id FROM jobs WHERE session_id = ? ORDER BY created_at`, s.id).map((r) => this.jobView(String(r.id)));
    return {
      id: s.id,
      persona: !!s.persona,
      mode: s.live && this.liveAvailable() ? "live" : "replay",
      storeOrigin: s.store_origin,
      expiresAt: s.expires_at,
      photos: {
        face: s.persona ? "/persona/face.jpg" : s.face_key ? `/v1/files/${s.face_key}` : null,
        body: s.persona ? "/persona/body.jpg" : s.body_key ? `/v1/files/${s.body_key}` : null,
      },
      reading: s.reading ? JSON.parse(s.reading) : null,
      palette,
      override: s.override,
      products,
      jobs,
    };
  }

  private async uploadPhoto(req: Request, url: URL): Promise<Response> {
    const s = await this.session(req);
    const kind = url.searchParams.get("kind");
    if (kind !== "face" && kind !== "body") throw bad("kind must be face or body.", "Call /v1/sessions/me/photos?kind=face.");
    if (s.persona) throw bad("The sample person already has photos.", "Start a session without persona to use your own photo.");
    const bytes = new Uint8Array(await req.arrayBuffer());
    const type = validateImage(bytes);
    const clean = stripJpegMetadata(bytes);
    const key = `u/${s.id}/${kind}-${randomId("", 8)}.${type === "image/png" ? "png" : "jpg"}`;
    await this.env.FILES.put(key, clean, { httpMetadata: { contentType: type }, customMetadata: { sha256: await sha256Hex(clean) } });
    const old = kind === "face" ? s.face_key : s.body_key;
    if (old) await this.env.FILES.delete(old);
    this.sql.exec(`UPDATE sessions SET ${kind === "face" ? "face_key" : "body_key"} = ? WHERE id = ?`, key, s.id);
    if (kind === "face") this.sql.exec(`UPDATE sessions SET reading = NULL, override = NULL WHERE id = ?`, s.id);
    return Response.json({ session: await this.sessionView(this.sessionRow(s.id)) }, { status: 201 });
  }

  private async paletteOverride(req: Request): Promise<Response> {
    const s = await this.session(req);
    const body = (await req.json().catch(() => ({}))) as { override?: string | null };
    const o = body.override ?? null;
    if (o !== null && o !== "warmer" && o !== "cooler") throw bad("override must be warmer, cooler or null.", 'Send {"override":"warmer"}.');
    if (!s.reading) throw bad("Read your colours first.", "Run a color_reading job before adjusting it.");
    this.sql.exec(`UPDATE sessions SET override = ? WHERE id = ?`, o, s.id);
    return Response.json({ session: await this.sessionView(this.sessionRow(s.id)) });
  }

  private async deleteSession(s: SessionRow) {
    await this.purgeSession(s.id);
    return { deleted: true };
  }

  private async purgeSession(id: string) {
    for (const prefix of [`u/${id}/`, `r/${id}/`]) {
      let cursor: string | undefined;
      do {
        const list = await this.env.FILES.list({ prefix, cursor });
        if (list.objects.length) await this.env.FILES.delete(list.objects.map((o) => o.key));
        cursor = list.truncated ? list.cursor : undefined;
      } while (cursor);
    }
    this.sql.exec(`DELETE FROM jobs WHERE session_id = ?`, id);
    this.sql.exec(`DELETE FROM sessions WHERE id = ?`, id);
  }

  async sweep() {
    const expired = this.sql.exec(`SELECT id FROM sessions WHERE expires_at < ?`, Date.now());
    for (const r of expired) await this.purgeSession(String(r.id));
    return { purged: expired.length };
  }

  // ---------- jobs ----------

  private jobView(id: string) {
    const r = this.sql.exec(`SELECT * FROM jobs WHERE id = ?`, id)[0];
    if (!r) throw new DrapeError("DRAPE_JOB_NOT_FOUND", 404, "No such job.", "Use the jobId returned when you created the job.");
    return {
      id: String(r.id), type: String(r.type), status: String(r.status),
      params: JSON.parse(String(r.params)),
      result: r.result ? JSON.parse(String(r.result)) : null,
      error: r.error ? JSON.parse(String(r.error)) : null,
      createdAt: Number(r.created_at), updatedAt: Number(r.updated_at),
    };
  }

  private async getJob(req: Request, id: string): Promise<Response> {
    const s = await this.session(req);
    const r = this.sql.exec(`SELECT session_id FROM jobs WHERE id = ?`, id)[0];
    if (!r || r.session_id !== s.id) throw new DrapeError("DRAPE_JOB_NOT_FOUND", 404, "No such job in this session.", "Use a jobId from this session.");
    return Response.json({ job: this.jobView(id), session: await this.sessionView(this.sessionRow(s.id)) });
  }

  private async createJob(req: Request): Promise<Response> {
    const s = await this.session(req);
    const body = (await req.json().catch(() => ({}))) as { type?: string; productId?: string; colorwayId?: string };
    const type = body.type as JobType;
    if (!type || !(type in UNIT_COST)) throw bad("type must be color_reading, tryon, makeup or jewelry.", 'Send {"type":"tryon","productId":"…","colorwayId":"…"}.');
    const params: Record<string, string> = {};
    if (type === "tryon") {
      const p = this.product(body.productId ?? "", true);
      const cw = p.colorways.find((c) => c.id === body.colorwayId);
      if (!cw) throw bad(`Product ${p.id} has no colorway ${body.colorwayId}.`, "Pick one of the product's colorways.");
      params.productId = p.id; params.colorwayId = cw.id; params.category = p.category;
    }
    if ((type === "makeup" || type === "jewelry") && !s.reading) throw bad("Read your colours first.", `Run a color_reading job before ${type}.`);
    if (type === "jewelry") params.metal = this.palette(s)!.metal;
    const live = !!s.live && this.liveAvailable();
    if (live && !s.persona) {
      if ((type === "color_reading" || type === "makeup" || type === "jewelry") && !s.face_key) throw new DrapeError("DRAPE_PHOTO_MISSING", 400, "We need your face photo first.", "Upload it with kind=face.");
      if (type === "tryon" && !s.body_key) throw new DrapeError("DRAPE_PHOTO_MISSING", 400, "We need a full-body photo for the try-on.", "Upload it with kind=body.");
    }
    // Same session + same inputs + same rules = same job. A double tap joins the existing job instead of paying twice.
    const photoKey = type === "tryon" ? s.body_key : s.face_key;
    const dedupe = await sha256Hex([s.id, type, photoKey ?? "persona", JSON.stringify(params), type === "makeup" ? s.reading + "|" + s.override : "", rules.version, live ? "live" : "replay"].join("|"));
    const existing = this.sql.exec(`SELECT id FROM jobs WHERE dedupe = ? AND status != 'error'`, dedupe)[0];
    if (existing) return Response.json({ job: this.jobView(String(existing.id)), joined: true });

    const id = randomId("job_", 12);
    const now = Date.now();
    this.sql.exec(`INSERT INTO jobs (id, session_id, type, params, dedupe, status, created_at, updated_at) VALUES (?,?,?,?,?,?,?,?)`,
      id, s.id, type, JSON.stringify(params), dedupe, "queued", now, now);

    if (!live) {
      await this.completeReplay(id, s, type, params, s.persona ? undefined : "replay");
    } else {
      try {
        this.ledger.reserve(id, type, s.visitor);
        this.sql.exec(`UPDATE jobs SET ledger_id = ? WHERE id = ?`, id, id);
        await this.ctx.storage.setAlarm(Date.now());
      } catch (e) {
        if (!(e instanceof BudgetError)) throw e;
        await this.completeReplay(id, s, type, params, e.reason === "visitor" ? "visitor_limit" : "limit");
      }
    }
    return Response.json({ job: this.jobView(id) }, { status: 202 });
  }

  private finish(id: string, status: "done" | "error", result: unknown, error?: unknown) {
    this.sql.exec(`UPDATE jobs SET status = ?, result = ?, error = ?, updated_at = ? WHERE id = ?`,
      status, result ? JSON.stringify(result) : null, error ? JSON.stringify(error) : null, Date.now(), id);
  }

  /** Replay: recorded results, 0 units. `sample` explains why a real user sees the sample person. */
  private async completeReplay(id: string, s: SessionRow, type: JobType, params: Record<string, string>, sample?: "replay" | "limit" | "visitor_limit") {
    const note = sample === "limit" ? "Live try-on limit reached today. Showing the sample look."
      : sample === "visitor_limit" ? "You've used today's live colour reading. Showing the sample look."
      : sample === "replay" ? "Demo mode: showing the sample person's result."
      : undefined;
    if (type === "color_reading") {
      this.sql.exec(`UPDATE sessions SET reading = ?, override = NULL WHERE id = ?`, JSON.stringify(PERSONA_READING), s.id);
      this.finish(id, "done", { reading: PERSONA_READING, sample: !!sample, note });
      return;
    }
    if (type === "tryon") {
      const rec = await this.recorded(replayTryonPath(params.productId, params.colorwayId));
      if (!rec) {
        this.finish(id, "error", null, { kind: "unavailable", message: "No recorded try-on for this colour yet.", retryable: false });
        return;
      }
      this.finish(id, "done", { image: rec, sample: !!sample, note });
      return;
    }
    if (type === "jewelry") {
      const metal = params.metal as Metal;
      const rec = await this.recorded(replayEarringPath(metal));
      if (rec) this.finish(id, "done", { image: rec, metal, sample: !!sample, note });
      else this.finish(id, "error", null, { kind: "unavailable", message: "Earring preview isn't available in demo mode yet.", retryable: false, metal });
      return;
    }
    const makeup = await this.recorded(REPLAY_MAKEUP);
    if (makeup) {
      this.finish(id, "done", { image: makeup, lip: this.palette(this.sessionRow(s.id))?.lip ?? null, sample: !!sample, note });
      return;
    }
    // No recorded makeup render yet: the look card shows the lip shade swatch instead.
    this.finish(id, "error", null, { kind: "unavailable", message: "Makeup preview isn't available in demo mode yet.", retryable: false });
  }

  /** A replay result exists only if its recorded file is deployed in public/. */
  private async recorded(path: string): Promise<string | null> {
    try {
      const res = await this.env.ASSETS.fetch(new Request(`https://assets.local${path}`, { method: "HEAD" }));
      return res.ok ? path : null;
    } catch {
      return null;
    }
  }

  async alarm() {
    const queued = this.sql.exec(`SELECT id FROM jobs WHERE status = 'queued' AND ledger_id IS NOT NULL ORDER BY created_at LIMIT 6`);
    await Promise.all(queued.map((r) => this.runLiveJob(String(r.id))));
    if (this.sql.exec(`SELECT 1 FROM jobs WHERE status = 'queued' AND ledger_id IS NOT NULL LIMIT 1`).length) {
      await this.ctx.storage.setAlarm(Date.now() + 1000);
    }
  }

  private async bytesOf(path: string): Promise<{ bytes: Uint8Array; type: string }> {
    if (path.startsWith("/v1/files/")) {
      const obj = await this.env.FILES.get(path.slice("/v1/files/".length));
      if (!obj) throw new YouCamError("upstream", "missing_file", "A photo for this step has expired. Upload it again.", false);
      return { bytes: new Uint8Array(await obj.arrayBuffer()), type: obj.httpMetadata?.contentType ?? "image/jpeg" };
    }
    const res = await this.env.ASSETS.fetch(new Request(`https://assets.local${path}`));
    if (!res.ok) throw new YouCamError("upstream", "missing_asset", "A catalogue image is missing.", false);
    return { bytes: new Uint8Array(await res.arrayBuffer()), type: res.headers.get("content-type") ?? "image/jpeg" };
  }

  private async runLiveJob(id: string) {
    const job = this.jobView(id);
    this.sql.exec(`UPDATE jobs SET status = 'running', updated_at = ? WHERE id = ?`, Date.now(), id);
    let s: SessionRow;
    try { s = this.sessionRow(String(this.sql.exec(`SELECT session_id FROM jobs WHERE id = ?`, id)[0].session_id)); }
    catch { this.ledger.release(id); return; }
    const yc = new LiveYouCam({ apiKey: this.env.YOUCAM_API_KEY!, base: this.env.YOUCAM_API_BASE });
    const started = Date.now();
    try {
      let result: Record<string, unknown>;
      if (job.type === "color_reading") {
        const face = await this.bytesOf(`/v1/files/${s.face_key}`);
        const fileId = await yc.upload("skin-tone-analysis", { ...face, name: "face.jpg" });
        const out = await yc.run("skin-tone-analysis", { src_file_id: fileId });
        const color = (out.data.results as { color?: ColorTonesColor })?.color;
        if (!color?.skin_color) throw new YouCamError("upstream", "no_color", "We couldn't read your colours. Try a clearer photo.", true);
        this.sql.exec(`UPDATE sessions SET reading = ?, override = NULL WHERE id = ?`, JSON.stringify(color), s.id);
        result = { reading: color, quality: (out.data.results as { face_quality?: unknown })?.face_quality ?? null };
      } else if (job.type === "tryon") {
        const p = this.product(job.params.productId, true);
        const cw = p.colorways.find((c) => c.id === job.params.colorwayId)!;
        const [body, garment] = await Promise.all([this.bytesOf(`/v1/files/${s.body_key}`), this.bytesOf(cw.image)]);
        const [src, ref] = await Promise.all([
          yc.upload("cloth-v4", { ...body, name: "body.jpg" }),
          yc.upload("cloth-v4", { ...garment, name: "garment.jpg" }),
        ]);
        const out = await yc.run("cloth-v4", { src_file_id: src, ref_file_id: ref, garment_category: job.params.category });
        result = { image: await this.saveResult(s.id, out.image) };
      } else if (job.type === "jewelry") {
        const metal = job.params.metal as Metal;
        const [face, earring] = await Promise.all([this.bytesOf(`/v1/files/${s.face_key}`), this.bytesOf(earringAsset(metal))]);
        const [src, ref] = await Promise.all([
          yc.upload("2d-vto/earring", { ...face, name: "face.jpg" }),
          yc.upload("2d-vto/earring", { ...earring, name: "earring.jpg" }),
        ]);
        const out = await yc.run("2d-vto/earring", earringPayload(src, ref));
        result = { image: await this.saveResult(s.id, out.image), metal };
      } else {
        const palette = this.palette(s)!;
        const face = await this.bytesOf(`/v1/files/${s.face_key}`);
        const fileId = await yc.upload("makeup-vto", { ...face, name: "face.jpg" });
        const out = await yc.run("makeup-vto", {
          src_file_id: fileId, version: "1.0",
          effects: [{ category: "lip_color", shape: { name: "original" }, style: { type: "full" }, palettes: [{ color: palette.lip.hex, texture: "matte", colorIntensity: 70 }] }],
        });
        result = { image: await this.saveResult(s.id, out.image), lip: palette.lip };
      }
      this.ledger.commit(id);
      this.setKv("upstream_failures", "0");
      this.finish(id, "done", result);
      console.log(JSON.stringify({ level: "info", event: "job_done", job: id, type: job.type, ms: Date.now() - started, units: UNIT_COST[job.type as JobType] }));
    } catch (e) {
      const err = e instanceof YouCamError ? e : new YouCamError("upstream", "internal", "Something went wrong. Try again.", true);
      if (!(e instanceof YouCamError)) console.error(JSON.stringify({ level: "error", event: "job_crash", job: id, type: job.type, error: String(e), stack: (e as Error)?.stack }));
      if (err.kind === "timeout") this.ledger.markStuck(id); // YouCam may still finish and charge; keep it reserved
      else this.ledger.release(id);
      if (err.kind === "auth" || err.kind === "upstream" || err.kind === "rate_limit") this.noteUpstreamFailure(err.kind === "auth");
      this.finish(id, "error", null, { kind: err.kind, code: err.youcamCode, message: err.userMessage, retryable: err.retryable });
      console.log(JSON.stringify({ level: "warn", event: "job_error", job: id, type: job.type, kind: err.kind, code: err.youcamCode, ms: Date.now() - started }));
    }
  }

  private async saveResult(sessionId: string, image?: Uint8Array): Promise<string> {
    if (!image) throw new YouCamError("upstream", "no_image", "The try-on finished without an image. Try again.", true);
    const key = `r/${sessionId}/${randomId("", 8)}.jpg`;
    await this.env.FILES.put(key, image, { httpMetadata: { contentType: "image/jpeg" } });
    return `/v1/files/${key}`;
  }

  /** Three upstream failures in a row (or one auth failure) switch the whole app to replay for 30 minutes. */
  private noteUpstreamFailure(auth: boolean) {
    const n = Number(this.kv("upstream_failures") ?? 0) + 1;
    this.setKv("upstream_failures", String(n));
    if (auth || n >= 3) {
      this.setKv("force_replay_until", String(Date.now() + 30 * 60 * 1000));
      console.log(JSON.stringify({ level: "error", event: "force_replay", reason: auth ? "auth" : "upstream_errors" }));
    }
  }

  private async reconcile(req: Request): Promise<Response> {
    await this.seller(req);
    const body = (await req.json().catch(() => ({}))) as { id?: string; outcome?: string };
    if (!body.id || (body.outcome !== "charged" && body.outcome !== "not_charged")) throw bad("Send {id, outcome: charged|not_charged}.", "Check the YouCam console for that task.");
    const ok = body.outcome === "charged" ? this.ledger.commit(body.id) : this.ledger.release(body.id);
    return Response.json({ ok, ledger: this.ledger.summary() });
  }
}
