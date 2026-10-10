// Worker entry: API and health go to the DrapeState Durable Object; everything else is static assets
// (buyer app under /app/, embed script under /embed/, the sample store under /store/).
import { DrapeState, type Env } from "./state";

export { DrapeState };

function stub(env: Env) {
  return env.DRAPE.get(env.DRAPE.idFromName("main"));
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);
    if (url.pathname === "/health" || url.pathname.startsWith("/v1/")) {
      const fwd = new Request(req);
      fwd.headers.set("x-drape-origin", url.origin);
      const res = await stub(env).fetch(fwd);
      // Catalogue reads are public data: let any store page read them (no credentials involved).
      if (req.method === "GET" && (url.pathname === "/v1/catalog" || url.pathname === "/v1/lookup" || url.pathname.startsWith("/v1/products/"))) {
        const out = new Response(res.body, res);
        out.headers.set("access-control-allow-origin", "*");
        return out;
      }
      return res;
    }
    if (url.pathname === "/") return Response.redirect(`${url.origin}/store/`, 302);
    return env.ASSETS.fetch(req);
  },

  async scheduled(_event: ScheduledController, env: Env, ctx: ExecutionContext): Promise<void> {
    ctx.waitUntil(
      stub(env)
        .fetch(new Request("https://internal/internal/sweep", { method: "POST" }))
        .then(async (r) => console.log(JSON.stringify({ level: "info", event: "sweep", status: r.status, body: await r.text() }))),
    );
  },
} satisfies ExportedHandler<Env>;
