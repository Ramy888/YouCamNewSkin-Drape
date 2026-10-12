// Responsive tour: store (live) + Drape buyer flow and seller console (local) at phone / tablet / desktop sizes.
// Usage: start `wrangler dev --port 8788` in backend/ with SELLER_SECRET:sk_e2e_only, then `node tools/responsive/tour.mjs [phone|tablet|landscape]`.
// Screenshots land next to this file (gitignored). cdp.mjs comes from IgnyteDuChallenge/scripts/demo-video with a `mobile` flag added.
import { launch, sleep } from "./cdp.mjs";
const OUT = new URL(".", import.meta.url).pathname;
const APP = process.env.APP ?? "http://localhost:8788";
const STORE = "https://noor-modest.ramy-comm.workers.dev/";
const sizes = [
  { name: "phone", width: 390, height: 844, mobile: true },
  { name: "tablet", width: 820, height: 1180, mobile: true },
  { name: "landscape", width: 1180, height: 820, mobile: true },
];
const only = process.argv[2];
let port = 9350;
for (const sz of sizes.filter((s) => !only || s.name === only)) {
  const b = await launch({ ...sz, scale: 1, port: port++ });
  const snap = async (n) => { await sleep(700); await b.shot(`${OUT}${sz.name}_${n}.png`); };
  const scrollShots = async (n, times = 2) => { await snap(n + "_0"); for (let i = 1; i <= times; i++) { await b.wheel(sz.height * 0.8, { x: sz.width / 2, y: sz.height / 2 }); await snap(`${n}_${i}`); } };
  const pageOverflow = async () => b.evaluate("document.documentElement.scrollWidth - window.innerWidth");
  try {
    await b.goto(STORE, 4000);
    console.log(sz.name, "store horizontal overflow px:", await pageOverflow());
    await scrollShots("store", 2);
    await b.goto(`${APP}/app/`, 7000);
    await b.evaluate("document.querySelector('flt-semantics-placeholder')?.click()");
    await sleep(800);
    await snap("landing");
    await b.click("Try with the sample person"); await sleep(3500);
    await scrollShots("reveal", 2);
    await b.click("Shop your colours"); await sleep(2500);
    await scrollShots("shop", 1);
    await b.click("See it on me", { nth: 0 }); await sleep(4500);
    await scrollShots("compare", 2);
    await b.click("Complete the look"); await sleep(4500);
    await scrollShots("look", 2);
    await b.click("العربية"); await sleep(1500);
    await b.wheel(-5000, { x: sz.width / 2, y: sz.height / 2 }); await snap("look_ar");
    await b.goto(`${APP}/app/?s=1#/seller`, 7000);
    await b.evaluate("document.querySelector('flt-semantics-placeholder')?.click()");
    await sleep(800);
    await snap("seller_signin");
    const f = await b.find("Secret key"); await b.clickAt(f); await sleep(300); await b.type("sk_e2e_only");
    await b.click("Sign in", { exact: true }); await sleep(2500);
    await scrollShots("seller", 1);
    await b.click("Classic satin abaya"); await sleep(1500);
    await scrollShots("seller_edit", 3);
  } catch (e) { console.error(sz.name, "FAILED:", e.message); }
  b.close();
}
