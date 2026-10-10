// Session tokens (HMAC-signed, short-lived) and key checks.
// Buyers get a token per session; the seller console uses a secret key compared by hash.
import { DrapeError } from "./errors";
import { sha256Hex } from "./images";

const enc = new TextEncoder();
const b64url = (b: Uint8Array) => btoa(String.fromCharCode(...b)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

async function hmac(secret: string, msg: string): Promise<string> {
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  return b64url(new Uint8Array(await crypto.subtle.sign("HMAC", key, enc.encode(msg))));
}

export async function signSession(secret: string, sessionId: string, expiresAt: number): Promise<string> {
  const body = `${sessionId}.${expiresAt}`;
  return `${body}.${await hmac(secret, body)}`;
}

/** Returns the session id when the token is valid and unexpired. Constant-time compare on the signature. */
export async function verifySession(secret: string, token: string | null, now = Date.now()): Promise<string> {
  const unauthorized = new DrapeError("DRAPE_UNAUTHORIZED", 401, "This session is missing or has expired.", "Start again from the product page.");
  if (!token) throw unauthorized;
  const parts = token.split(".");
  if (parts.length !== 3) throw unauthorized;
  const [sid, exp, sig] = parts;
  const expected = await hmac(secret, `${sid}.${exp}`);
  if (expected.length !== sig.length) throw unauthorized;
  let diff = 0;
  for (let i = 0; i < sig.length; i++) diff |= expected.charCodeAt(i) ^ sig.charCodeAt(i);
  if (diff !== 0 || !(Number(exp) > now)) throw unauthorized;
  return sid;
}

export function bearer(req: Request): string | null {
  const h = req.headers.get("authorization");
  return h?.startsWith("Bearer ") ? h.slice(7).trim() : null;
}

export async function hashKey(key: string): Promise<string> {
  return sha256Hex(`drape-key:${key}`);
}

/** One visitor per IP + user agent + UTC day; salted so the raw IP is never stored. */
export async function visitorId(req: Request, salt: string, now = Date.now()): Promise<string> {
  const ip = req.headers.get("cf-connecting-ip") ?? "local";
  const ua = req.headers.get("user-agent") ?? "";
  return (await sha256Hex(`${salt}|${ip}|${ua}|${new Date(now).toISOString().slice(0, 10)}`)).slice(0, 32);
}
