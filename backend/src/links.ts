// Store listing links: a seller attaches the URLs where a product is sold (their shop, a marketplace listing).
// The extension sends only the page address; we match it against these links. No page content is read.
//
//   https://www.Shop.com/products/abaya/?utm=x#top ──▶ "url:shop.com/products/abaya"
//   https://www.amazon.ae/Some-Title/dp/B0ABCDEF12?th=1 ──▶ "url:amazon.ae/some-title/dp/b0abcdef12" + "amazon:B0ABCDEF12"

const ASIN = /\/(?:dp|gp\/product)\/([A-Z0-9]{10})(?:[/?]|$)/i;

/** Every key a page URL can be matched on. Throws on anything that is not an http(s) URL. */
export function linkKeys(raw: string): string[] {
  const u = new URL(raw.trim());
  if (u.protocol !== "https:" && u.protocol !== "http:") throw new Error(`not a web address: ${raw}`);
  const host = u.hostname.toLowerCase().replace(/^www\./, "");
  const path = u.pathname.replace(/\/+$/, "").toLowerCase();
  const keys = [`url:${host}${path}`];
  const asin = ASIN.exec(u.pathname);
  if (asin && /(^|\.)amazon\.[a-z.]+$/.test(host)) keys.push(`amazon:${asin[1].toUpperCase()}`);
  return keys;
}

export function validLink(raw: string): boolean {
  try {
    linkKeys(raw);
    return true;
  } catch {
    return false;
  }
}
