// Drape extension popup. Uses only the active tab's address (granted by activeTab when you click the icon);
// it never reads or changes the page itself. The address is matched against links sellers added to Drape.
const DRAPE = "https://drape.ramy-comm.workers.dev";
const main = document.getElementById("main");

function render(html) { main.innerHTML = html; }
function esc(s) { return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])); }

async function run() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  const pageUrl = tab && tab.url;
  if (!pageUrl || !/^https?:/.test(pageUrl)) {
    render("<h1>Open a product page</h1><p>Drape works on shop product pages.</p>");
    return;
  }
  let res;
  try {
    res = await fetch(`${DRAPE}/v1/lookup?url=${encodeURIComponent(pageUrl)}`);
  } catch {
    render("<h1>Drape is offline</h1><p>Check your connection and try again.</p>");
    return;
  }
  if (res.status === 404) {
    render("<h1>Not on Drape yet</h1><p>This product hasn't been added to Drape. Ask the seller to add it, then click again.</p>");
    return;
  }
  if (!res.ok) {
    render("<h1>Something went wrong</h1><p>Try again in a moment.</p>");
    return;
  }
  const { product, store } = await res.json();
  const chips = product.colorways.map((c) => `<span class="chip"><span class="dot" style="background:${esc(c.hex)}"></span>${esc(c.name)}</span>`).join("");
  render(`<h1>${esc(product.name)}</h1><p>From ${esc(store.name)}. See which colour suits your face, on your own body.</p>
    <div class="chips">${chips}</div><button id="go">Try on with Drape</button>
    <small>Opens Drape in a new tab. Only this page's address was used.</small>`);
  document.getElementById("go").addEventListener("click", () => {
    const q = new URLSearchParams({ pk: store.key, product: product.id, lang: navigator.language.startsWith("ar") ? "ar" : "en" });
    chrome.tabs.create({ url: `${DRAPE}/app/#/start?${q}` });
    window.close();
  });
}

run();
