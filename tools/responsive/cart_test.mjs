// End-to-end cart hand-off across two tabs (headless Chrome over CDP, no extensions):
//   store tab ── click "Try on with Drape" (real mouse click) ──▶ Drape opens in a NEW TAB
//   Drape tab ── sample person → Shop your colours → See it on me → Complete the look → Add the look to cart
//   store tab ◀── postMessage (opener) ── check the bag opened with the look and "Picked with Drape"
// Usage: node tools/responsive/cart_test.mjs [storeUrl]   (exit code 0 = pass)
import { spawn } from "node:child_process";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const STORE = process.argv[2] ?? "https://noor-modest.ramy-comm.workers.dev/";
const OUT = fileURLToPath(new URL(".", import.meta.url));
const PORT = 9380;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", [
  "--headless=new", `--remote-debugging-port=${PORT}`, `--user-data-dir=${mkdtempSync(join(tmpdir(), "drapecart-"))}`,
  "--window-size=1280,900", "--no-first-run", "about:blank",
], { stdio: "ignore" });

const pages = async () => {
  for (let i = 0; i < 50; i++) {
    try { return (await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json()).filter((t) => t.type === "page"); } catch { await sleep(200); }
  }
  throw new Error("chrome did not start");
};

async function connect(target) {
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => ws.addEventListener("open", r));
  let id = 0; const pending = new Map();
  ws.addEventListener("message", (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } });
  const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
  await send("Page.enable");
  await send("Emulation.setDeviceMetricsOverride", { width: 1280, height: 900, deviceScaleFactor: 1, mobile: false });
  const evaluate = async (expression) => (await send("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true })).result.result?.value;
  const mouseClick = async (x, y) => {
    await send("Input.dispatchMouseEvent", { type: "mouseMoved", x, y });
    await sleep(120);
    for (const type of ["mousePressed", "mouseReleased"]) { await send("Input.dispatchMouseEvent", { type, x, y, button: "left", clickCount: 1 }); await sleep(60); }
  };
  const labels = () => evaluate(`[...document.querySelectorAll('flt-semantics')].map(e => (e.getAttribute('aria-label') || '') + ' ' + (e.textContent || '')).join('|')`);
  const shot = async (name) => { const r = await send("Page.captureScreenshot", { format: "png" }); writeFileSync(join(OUT, name), Buffer.from(r.result.data, "base64")); };
  // Flutter: find the button whose label contains the text (scrolling until it's on screen), click it, and wait for the
  // next screen's marker text. If Flutter drops the synthetic press, activate the semantics node directly.
  const has = async (text) => (await labels()).includes(text);
  const find = (text) => evaluate(`(() => {
    const vis = (e) => { const b = e.getBoundingClientRect(); return b.width > 2 && b.height > 2 && b.top >= 0 && b.bottom <= innerHeight; };
    const label = (e) => (e.getAttribute('aria-label') || '') + ' ' + (e.textContent || '');
    const want = ${JSON.stringify(text)};
    // Innermost match only: a container's textContent includes every child's text, so it would steal the click.
    const all = [...document.querySelectorAll('flt-semantics')].filter((e) => label(e).includes(want) &&
      ![...e.querySelectorAll('flt-semantics')].some((c) => label(c).includes(want)));
    const pick = all.filter(vis)[0];
    if (!pick) return null;
    document.querySelectorAll('[data-tap]').forEach((e) => e.removeAttribute('data-tap')); pick.setAttribute('data-tap', '1');
    const b = pick.getBoundingClientRect(); return { x: b.x + b.width / 2, y: b.y + b.height / 2 };
  })()`);
  const tap = async (text, expect) => {
    let box = null;
    for (let i = 0; i < 30 && !(box = await find(text)); i++) {
      await send("Input.dispatchMouseEvent", { type: "mouseWheel", x: 640, y: 450, deltaX: 0, deltaY: 300 });
      await sleep(400);
    }
    if (!box) { await shot("cart_fail.png"); throw new Error(`not found on the Drape tab: ${text}`); }
    await mouseClick(box.x, box.y);
    for (let k = 0; k < 25; k++) { await sleep(200); if (await has(expect)) return; }
    await evaluate(`document.querySelector('[data-tap]')?.click()`);
    for (let k = 0; k < 40; k++) { await sleep(250); if (await has(expect)) return; }
    await shot("cart_fail.png");
    throw new Error(`"${text}" did not lead to "${expect}"`);
  };
  return { send, evaluate, mouseClick, shot, tap, close: () => ws.close() };
}

let ok = false;
try {
  const [first] = await pages();
  const store = await connect(first);
  await store.send("Page.navigate", { url: STORE });
  await sleep(4000);
  const btn = await store.evaluate(`(() => { const b = document.getElementById('drapeBtn'); b.scrollIntoView({block:'center'}); const r = b.getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2 }; })()`);
  await sleep(300);
  await store.mouseClick(btn.x, btn.y);

  let drapeTarget;
  for (let i = 0; i < 40 && !drapeTarget; i++) { drapeTarget = (await pages()).find((t) => t.url.includes("/app/")); if (!drapeTarget) await sleep(250); }
  if (!drapeTarget) throw new Error("Drape did not open in a new tab");
  console.log("Drape opened in a new tab:", drapeTarget.url.split("#")[0]);
  const drape = await connect(drapeTarget);
  await sleep(7000);
  console.log("opener kept:", await drape.evaluate("!!window.opener"));
  for (const [step, next] of [
    ["Try with the sample person", "Your colours"],
    ["See it on me:", "Same piece, two colours"],
    ["Complete the look", "Your look"],
    ["Add the look to cart", "Added to your cart at the store"],
  ]) {
    await drape.tap(step, next);
    console.log("ok:", step, "→", next);
    await sleep(1500);
  }
  await drape.shot("cart_drape.png");
  const drapeSays = await drape.evaluate(`[...document.querySelectorAll('flt-semantics')].map(e => e.getAttribute('aria-label') || e.textContent).join(' | ')`);
  console.log("Drape tab shows 'Added to your cart at the store':", /Added to your cart at the store/.test(drapeSays));

  await sleep(1000);
  const bag = await store.evaluate(`({ open: document.getElementById('cart').classList.contains('open'), count: document.getElementById('count').textContent, lines: document.getElementById("lines").innerText })`);
  await store.shot("cart_store.png");
  console.log("store bag:", JSON.stringify(bag));
  ok = bag.open && bag.count !== "0" && /Picked with Drape/.test(bag.lines);
} catch (e) {
  console.error("FAILED:", e.message);
} finally {
  chrome.kill();
}
console.log(ok ? "PASS: the look reached the store's bag" : "FAIL");
process.exit(ok ? 0 : 1);
