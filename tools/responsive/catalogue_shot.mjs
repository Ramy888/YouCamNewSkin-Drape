// Screenshot Drape's catalogue (all stores, search, store filter) for the sample person. Usage: node catalogue_shot.mjs [w h name]
import { fileURLToPath } from "node:url";
import { launch, sleep } from "./cdp.mjs";
const [w, h, name] = [Number(process.argv[2] ?? 1180), Number(process.argv[3] ?? 820), process.argv[4] ?? "catalogue"];
const OUT = fileURLToPath(new URL(".", import.meta.url));
const b = await launch({ width: w, height: h, mobile: w < 1000, port: 9390 });
try {
  await b.goto("https://drape.ramy-comm.workers.dev/app/?c=" + Date.now(), 8000);
  await b.click("Try with the sample person"); await sleep(3500);
  await b.wheel(3000, { x: w / 2, y: h / 2 }); await sleep(800);
  await b.click("Shop your colours"); await sleep(3000);
  await b.shot(`${OUT}${name}.png`);
} catch (e) { console.error("FAILED:", e.message); }
b.close();
