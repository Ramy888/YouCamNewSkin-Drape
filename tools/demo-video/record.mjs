// Records the Drape demo in headless Chrome against production, with the sample person only (0 YouCam units).
// The store button opens Drape in a new tab (window.opener is kept, so "Add the look to cart" reaches the store's bag);
// each tab is recorded as its own segment and the segments are joined in order.
// Run: node tools/demo-video/record.mjs  → out/drape-demo-silent.mp4 + out/cues.json (times in the joined video).
// The seller console beat signs in with the view-only judge key from backend/.dev.vars, off camera.
import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { attach, launch, pages, sleep } from "./cdp.mjs";

const DRAPE = "https://drape.ramy-comm.workers.dev";
const STORE = "https://noor-modest.ramy-comm.workers.dev/";
const DIR = fileURLToPath(new URL("./out/", import.meta.url));
const VIEW = { width: 1440, height: 900, scale: 4 / 3 };
const judgeKey = readFileSync(fileURLToPath(new URL("../../backend/.dev.vars", import.meta.url)), "utf8").match(/^JUDGE_SELLER_KEY=(.*)$/m)[1].trim();
rmSync(DIR, { recursive: true, force: true }); mkdirSync(DIR, { recursive: true });

const cues = [];
const segments = [];
let base = 0; // length of the segments already finished
let cur = null; // { tab, t0 }
const begin = async (tab) => { await tab.ensureCursor(); await tab.startRec(); cur = { tab, t0: tab.mark() }; };
const cue = (text) => { const at = base + cur.tab.mark() - cur.t0; cues.push({ at, text }); console.log(at.toFixed(1), text); };
const end = async () => {
  const { frames, end: stop } = await cur.tab.stopRec();
  const n = segments.length, dir = `${DIR}seg${n}/`;
  mkdirSync(dir + "frames", { recursive: true });
  // frames → constant 30 fps: each slot shows the newest frame captured by then
  const FPS = 30, start = cur.t0, slots = Math.ceil((stop - start) * FPS);
  const list = []; let j = 0; const written = new Map();
  for (let s = 0; s < slots; s++) {
    const t = start + s / FPS;
    while (j + 1 < frames.length && frames[j + 1].t <= t) j++;
    if (!written.has(j)) { const name = `frames/${String(j).padStart(5, "0")}.jpg`; writeFileSync(dir + name, Buffer.from(frames[j].data, "base64")); written.set(j, name); }
    list.push(`file '${written.get(j)}'`, `duration ${(1 / FPS).toFixed(6)}`);
  }
  list.push(list[list.length - 2]);
  writeFileSync(dir + "list.txt", list.join("\n") + "\n");
  execFileSync("ffmpeg", ["-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", "list.txt", "-vf", "scale=1920:1200,format=yuv420p",
    "-r", "30", "-c:v", "libx264", "-crf", "18", "seg.mp4"], { cwd: dir });
  segments.push(`seg${n}/seg.mp4`);
  base += slots / FPS;
  cur = null;
};

// Flutter: enable semantics so buttons can be found, then wait until a label shows
const semantics = (tab) => tab.evaluate("document.querySelector('flt-semantics-placeholder')?.click()");
const waitFor = async (tab, text, ms = 15000) => { for (let i = 0; i < ms / 250; i++) { if (await tab.find(text)) return; await sleep(250); } throw new Error("never showed: " + text); };
const look = async (tab, x, y, ms) => { await tab.moveTo({ x, y }); await sleep(ms); };
// scroll until the label is on screen (Flutter builds list items lazily)
const scrollTo = async (tab, text, step = 260) => {
  for (let i = 0; i < 25; i++) {
    const p = await tab.find(text);
    if (p && p.y > 100 && p.y < VIEW.height - 30) return p;
    await tab.wheel(p && p.y <= 120 ? -step : step); await sleep(450);
  }
  throw new Error("could not scroll to: " + text);
};

const store = await launch({ ...VIEW, port: 9391 });
let drape;
try {
  // 1. The store page and its button
  await store.goto(STORE, 4500);
  await begin(store);
  cue("store");
  await look(store, 560, 420, 2500);
  await look(store, 1000, 300, 2500);
  const btn = await store.evaluate(`(() => { const b = document.getElementById('drapeBtn'); b.scrollIntoView({block:'center', behavior:'smooth'}); return true })()`);
  await sleep(1200);
  const p = await store.evaluate(`(() => { const r = document.getElementById('drapeBtn').getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2 } })()`);
  cue("button");
  await look(store, p.x, p.y, 2500);
  await store.clickAt(p); await sleep(500);
  await end();

  // 2. Drape opens in a new tab
  let t;
  for (let i = 0; i < 40 && !t; i++) { t = (await pages(store.port)).find((x) => x.url.includes("/app/")); if (!t) await sleep(250); }
  if (!t) throw new Error("Drape did not open in a new tab");
  drape = await attach(t, VIEW);
  await sleep(7000); await semantics(drape); await waitFor(drape, "Try with the sample person");
  await begin(drape);
  cue("landing");
  await look(drape, 900, 330, 2500);
  await drape.click("Try with the sample person", { expect: "Your colours" }); await sleep(3500);
  cue("colours");
  await look(drape, 560, 420, 3000); await look(drape, 920, 420, 3000);
  await scrollTo(drape, "Shop your colours"); await sleep(600);
  cue("palette");
  await look(drape, 600, 330, 3000); await look(drape, 600, 500, 3000);
  await drape.click("Shop your colours", { expect: "Sorted by what suits you" }); await sleep(3000);
  cue("shop");
  await look(drape, 1050, 385, 2500); await look(drape, 1050, 500, 2500);
  await drape.click("See it on me", { expect: "Same piece, two colours" }); await sleep(5000);
  cue("compare");
  await look(drape, 520, 520, 3500); await look(drape, 980, 520, 3500);
  await scrollTo(drape, "Complete the look"); await sleep(800);
  await look(drape, 520, 450, 1500);
  await drape.click("Complete the look", { expect: "Your look" }); await sleep(5000);
  cue("look");
  await look(drape, 450, 400, 2500); await look(drape, 740, 330, 3000); await look(drape, 740, 560, 2500);
  await scrollTo(drape, "Add the look to cart"); await sleep(1200);
  cue("cart");
  await drape.click("Add the look to cart", { expect: "Added to your cart at the store" }); await sleep(2500);
  await end();

  // 3. Back on the store tab: the bag opened with the look in it
  await sleep(800);
  await begin(store);
  cue("bag");
  await look(store, 1250, 400, 3500); await look(store, 1250, 330, 2500);
  await end();

  // 4. Not sold yet: back to the shop off camera
  for (let i = 0; i < 4 && !(await drape.find("Sorted by what suits you")); i++) { await drape.click("Back"); await sleep(2500); }
  await waitFor(drape, "Sorted by what suits you");
  await begin(drape);
  cue("everyday");
  await scrollTo(drape, "None of these colours"); await sleep(1000);
  await look(drape, 900, 420, 2500);
  await drape.click("See it in", { expect: "not sold yet" }); await sleep(5500);
  cue("notsold");
  await look(drape, 520, 520, 3500); await look(drape, 980, 520, 3000);
  await scrollTo(drape, "Ask the store"); await sleep(800);
  cue("ask");
  await drape.click("Ask the store", { gone: true }); await sleep(3500);
  await end();

  // 5. Seller console, signed in off camera with the view-only judge key
  await drape.evaluate(`sessionStorage.setItem('drape.sellerKey', ${JSON.stringify(judgeKey)})`);
  await drape.goto(`${DRAPE}/app/#/seller`, 7000); await semantics(drape);
  await waitFor(drape, "Colour demand", 20000);
  await scrollTo(drape, "Colour demand"); await sleep(1500);
  await begin(drape);
  cue("seller");
  await look(drape, 700, 400, 3500); await drape.wheel(300); await sleep(1500); await look(drape, 900, 500, 3500);
  await end();

  // 6. Drape's own catalogue across stores, then Arabic
  await drape.evaluate("sessionStorage.clear()"); // a fresh Drape catalogue session, not the store's
  await drape.goto(`${DRAPE}/app/`, 7000); await semantics(drape);
  await drape.click("Try with the sample person", { expect: "Your colours" }); await sleep(2500);
  await scrollTo(drape, "Shop your colours");
  await drape.click("Shop your colours", { expect: "Sorted by what suits you" }); await sleep(2500);
  await begin(drape);
  cue("catalogue");
  await look(drape, 560, 245, 2500); await look(drape, 620, 245, 2000);
  await scrollTo(drape, "Woven kaftan coat"); await sleep(800);
  const layla = await drape.find("Sold by Layla");
  if (layla) await look(drape, layla.x, layla.y, 3000);
  await look(drape, 1000, 500, 2000);
  cue("arabic");
  await drape.click("العربية"); await sleep(4500);
  await look(drape, 700, 400, 3000);
  cue("close");
  await sleep(6000);
  await end();
} catch (e) {
  console.error("FAILED:", e.message);
  await (cur?.tab ?? drape ?? store).shot(DIR + "fail.png");
  store.close(); process.exit(1);
}
store.close();

writeFileSync(DIR + "segments.txt", segments.map((s) => `file '${s}'`).join("\n") + "\n");
execFileSync("ffmpeg", ["-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", "segments.txt", "-c", "copy", "drape-demo-silent.mp4"], { cwd: DIR });
writeFileSync(DIR + "cues.json", JSON.stringify(cues, null, 1));
console.log(`length ${base.toFixed(1)} s, ${cues.length} cues → ${DIR}drape-demo-silent.mp4`);
