// Upload checks that run before any YouCam call: real image type (magic bytes), size, and metadata removal.
// The app resizes and re-encodes on the device (which also applies EXIF orientation); here we only verify
// and strip what could leak (GPS, camera serials) from JPEGs.
import { DrapeError } from "./errors";

export const MAX_BYTES = 10 * 1024 * 1024;

export type ImageType = "image/jpeg" | "image/png";

export function sniff(bytes: Uint8Array): ImageType | null {
  if (bytes.length > 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) return "image/jpeg";
  const png = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  if (bytes.length > 8 && png.every((b, i) => bytes[i] === b)) return "image/png";
  return null;
}

export function validateImage(bytes: Uint8Array): ImageType {
  if (bytes.length === 0) {
    throw new DrapeError("DRAPE_IMAGE_INVALID", 400, "The photo is empty.", "Send the image bytes as the request body.");
  }
  if (bytes.length > MAX_BYTES) {
    throw new DrapeError("DRAPE_IMAGE_TOO_LARGE", 413, "The photo is larger than 10 MB.", "Resize it so the long side is at most 1920 px.");
  }
  const type = sniff(bytes);
  if (!type) {
    throw new DrapeError("DRAPE_IMAGE_INVALID", 415, "The file is not a JPEG or PNG image.", "Upload a JPEG or PNG photo.");
  }
  return type;
}

/** Remove APP1..APP15 (EXIF, XMP, ICC extras) and COM segments from a JPEG. Image data is untouched. */
export function stripJpegMetadata(bytes: Uint8Array): Uint8Array {
  if (sniff(bytes) !== "image/jpeg") return bytes;
  const out: Uint8Array[] = [bytes.subarray(0, 2)];
  let i = 2;
  while (i + 4 <= bytes.length) {
    if (bytes[i] !== 0xff) return bytes; // malformed: keep the original rather than corrupt it
    const marker = bytes[i + 1];
    if (marker === 0xda) {
      out.push(bytes.subarray(i)); // start of scan: copy the rest verbatim
      break;
    }
    const len = (bytes[i + 2] << 8) | bytes[i + 3];
    if (len < 2 || i + 2 + len > bytes.length) return bytes;
    const isAppN = marker >= 0xe1 && marker <= 0xef;
    const isComment = marker === 0xfe;
    if (!isAppN && !isComment) out.push(bytes.subarray(i, i + 2 + len));
    i += 2 + len;
  }
  const total = out.reduce((n, p) => n + p.length, 0);
  const merged = new Uint8Array(total);
  let o = 0;
  for (const p of out) { merged.set(p, o); o += p.length; }
  return merged;
}

export async function sha256Hex(data: Uint8Array | string): Promise<string> {
  const buf = typeof data === "string" ? new TextEncoder().encode(data) : data;
  const digest = await crypto.subtle.digest("SHA-256", buf);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function randomId(prefix: string, bytes = 16): string {
  const b = crypto.getRandomValues(new Uint8Array(bytes));
  return prefix + [...b].map((x) => x.toString(16).padStart(2, "0")).join("");
}
