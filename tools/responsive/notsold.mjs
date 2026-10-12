// Walks the sample person into "not sold yet": Shop → See it in … → Compare → Ask the store. Usage: node notsold.mjs [width height]
import { fileURLToPath } from "node:url";
import { launch, sleep } from "./cdp.mjs";
const [w, h] = [Number(process.argv[2] ?? 1180), Number(process.argv[3] ?? 820)];
const OUT = fileURLToPath(new URL(".", import.meta.url));
const b = await launch({ width: w, height: h, mobile: w < 1000, port: 9370 });
try {
  await b.goto("http://localhost:8788/app/", 7000);
  await b.click("Try with the sample person"); await sleep(3500);
  await b.wheel(3000, { x: w / 2, y: h / 2 }); await sleep(800);
  await b.click("Shop your colours"); await sleep(2500);
  await b.wheel(2500, { x: w / 2, y: h / 2 }); await sleep(800);
  await b.shot(`${OUT}ns_shop.png`);
  await b.click("See it in"); await sleep(5000);
  await b.shot(`${OUT}ns_compare.png`);
  await b.click("Ask the store"); await sleep(2000);
  await b.wheel(2000, { x: w / 2, y: h / 2 }); await sleep(600);
  await b.shot(`${OUT}ns_asked.png`);
} catch (e) { console.error("FAILED:", e.message); }
b.close();
