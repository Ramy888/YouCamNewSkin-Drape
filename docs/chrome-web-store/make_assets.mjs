// Chrome Web Store screenshots (1280×800). Usage: node docs/chrome-web-store/make_assets.mjs <popupHarnessUrl>
// popupHarnessUrl serves extension/popup.html with a stub `chrome.tabs` (the popup itself can't be opened headless).
import { fileURLToPath } from "node:url";
import { launch, sleep } from "../../tools/responsive/cdp.mjs";
const OUT = fileURLToPath(new URL("./assets/raw_", import.meta.url));
const popup = process.argv[2];
const b = await launch({ width: 1280, height: 800, port: 9395 });
const shot = async (path) => { await b.evaluate("document.getElementById('rec-cursor')?.remove(); document.getElementById('rec-ripple')?.remove()"); await b.shot(path); };
try {
  await b.goto("https://noor-modest.ramy-comm.workers.dev/?s=1", 4000); await shot(`${OUT}store.png`);
  await b.goto(popup, 3000); await shot(`${OUT}popup.png`);
  await b.goto("https://drape.ramy-comm.workers.dev/app/?s=" + Date.now(), 8000);
  await b.click("Try with the sample person"); await sleep(4000); await shot(`${OUT}colours.png`);
  await b.wheel(3000, { x: 640, y: 400 }); await sleep(800);
  await b.click("Shop your colours"); await sleep(3000); await shot(`${OUT}catalogue.png`);
  await b.click("See it on me", { nth: 0 }); await sleep(6000); await shot(`${OUT}compare.png`);
} catch (e) { console.error("FAILED:", e.message); }
b.close();
