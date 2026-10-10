// A local stand-in for the YouCam API, so the live code path (upload -> PUT -> task -> poll -> download)
// can be exercised end to end without a key and without spending units.
// Usage: node test/e2e/mock-youcam.mjs [port]
// A source photo whose bytes contain the text "MULTI" makes the task fail with error_multi_person.
import { createServer } from "node:http";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const port = Number(process.argv[2] ?? 9999);
const pub = join(import.meta.dirname, "..", "..", "public");
const reading = JSON.parse(readFileSync(join(pub, "persona", "color_tones.json"), "utf8")).data.results;
const uploads = new Map(); // file_id -> bytes
const tasks = new Map(); // task_id -> { task, payload }
let n = 0;
const calls = [];

const json = (res, status, body) => {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
};
const read = (req) => new Promise((ok) => { const c = []; req.on("data", (d) => c.push(d)); req.on("end", () => ok(Buffer.concat(c))); });

createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${port}`);
  const p = url.pathname;
  calls.push(`${req.method} ${p}`);
  if (p === "/calls") return json(res, 200, calls);
  if (req.headers.authorization !== "Bearer test-key" && !p.startsWith("/put/") && !p.startsWith("/img/")) return json(res, 401, { error: "InvalidAccessToken" });

  if (req.method === "POST" && p === "/s2s/v2.0/file") {
    const id = `file_${++n}`;
    return json(res, 200, { status: 200, data: { files: [{ file_id: id, requests: [{ url: `http://localhost:${port}/put/${id}`, method: "PUT", headers: {} }] }] } });
  }
  if (req.method === "POST" && p.startsWith("/s2s/v2.0/file/")) return json(res, 404, { error: "not found" }); // force the generic endpoint
  if (req.method === "PUT" && p.startsWith("/put/")) {
    uploads.set(p.slice(5), await read(req));
    res.writeHead(200).end();
    return;
  }
  let m = p.match(/^\/s2s\/v2\.0\/task\/(.+)$/);
  if (req.method === "POST" && m && !/\/task_\d+$/.test(p)) {
    const payload = JSON.parse((await read(req)).toString());
    const id = `task_${++n}`;
    tasks.set(id, { task: m[1], payload });
    return json(res, 200, { status: 200, data: { task_id: id } });
  }
  m = p.match(/^\/s2s\/v2\.0\/task\/(.+)\/(task_\d+)$/);
  if (req.method === "GET" && m) {
    const t = tasks.get(m[2]);
    if (!t) return json(res, 404, { error: "InvalidTaskId" });
    const src = uploads.get(t.payload.src_file_id);
    if (src && src.includes("MULTI")) {
      return json(res, 200, { status: 200, data: { task_status: "error", error: "error_multi_person", error_message: "More than one person", results: null } });
    }
    if (t.task === "skin-tone-analysis") return json(res, 200, { status: 200, data: { task_status: "success", results: reading } });
    return json(res, 200, { status: 200, data: { task_status: "success", results: { url: `http://localhost:${port}/img/${t.task.replace("/", "_")}.jpg` } } });
  }
  if (req.method === "GET" && p.startsWith("/img/")) {
    res.writeHead(200, { "content-type": "image/jpeg" });
    res.end(readFileSync(join(pub, "persona", "face.jpg")));
    return;
  }
  json(res, 404, { error: `mock has no ${req.method} ${p}` });
}).listen(port, () => console.log(`mock YouCam on :${port}`));
