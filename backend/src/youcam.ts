// YouCam adapter. Two modes behind one interface:
//   replay (default): recorded responses and images, zero network calls, zero units.
//   live: upload -> PUT bytes -> create task -> poll until success/error, then download the result bytes
//         (YouCam deletes results after 24h, so callers copy them to our storage).
// Error codes from YouCam are mapped to buyer-facing advice; nothing is swallowed.
import personaReading from "../public/persona/color_tones.json";

export const BASE_DEFAULT = "https://yce-api-01.makeupar.com/s2s/v2.0";

export type YouCamTask = "skin-tone-analysis" | "cloth-v4" | "makeup-vto" | "2d-vto/earring" | "fabric";

export interface Upload { bytes: Uint8Array; type: string; name: string }

export interface TaskOutcome {
  /** Raw `data` object from the final poll. */
  data: Record<string, unknown>;
  /** Result image bytes when the task returns an image. */
  image?: Uint8Array;
}

export class YouCamError extends Error {
  constructor(
    public kind: "user_photo" | "rejected" | "auth" | "rate_limit" | "upstream" | "timeout",
    public youcamCode: string,
    public userMessage: string,
    public retryable: boolean,
  ) {
    super(`${kind}: ${youcamCode}`);
  }
}

// YouCam error code -> what the buyer should do. Unknown codes fall through to a generic retake message.
const PHOTO_ADVICE: Record<string, string> = {
  error_face_angle_downward: "Lift your chin a little and look straight at the camera.",
  error_face_angle_upward: "Lower your chin a little and look straight at the camera.",
  error_face_angle: "Face the camera straight on.",
  error_no_face: "We couldn't find a face. Move closer and face the camera.",
  error_face_too_small: "Move closer so your face fills the oval.",
  error_multi_person: "Only one person should be in the photo.",
  error_pose: "Stand facing the camera with your arms slightly away from your body.",
  error_lighting: "Find softer, even light and try again.",
  error_face_parsing: "We couldn't see your ears to place the earrings. That's fine: your metal still shows in the look.",
};

export function mapTaskError(code: string, message?: string): YouCamError {
  if (code === "error_nsfw_content_detected") {
    return new YouCamError("rejected", code, "This photo can't be used. Please choose a different one.", false);
  }
  // Earring VTO reports covered ears as a bare numeric code plus "earlobe alignment not confident."
  if (message && /earlobe/i.test(message)) code = "error_face_parsing";
  const advice = PHOTO_ADVICE[code] ?? (code.startsWith("error_face") ? "Face the camera straight on in even light." : undefined);
  if (advice) return new YouCamError("user_photo", code, advice, false);
  return new YouCamError("upstream", code, message ? `The try-on service said: ${message}` : "The try-on service couldn't process this photo.", true);
}

function mapHttpError(status: number, body: string): YouCamError {
  if (status === 401 || status === 403) return new YouCamError("auth", `http_${status}`, "Live try-on is paused. Showing the demo look instead.", false);
  if (status === 429) return new YouCamError("rate_limit", "http_429", "The try-on service is busy. Try again in a minute.", true);
  return new YouCamError("upstream", `http_${status}`, "The try-on service is having trouble. Try again shortly.", true);
}

export interface LiveConfig {
  apiKey: string;
  base?: string;
  fetch?: typeof fetch;
  sleep?: (ms: number) => Promise<void>;
  /** Overall deadline for one task, in ms. */
  deadlineMs?: number;
}

export class LiveYouCam {
  private f: typeof fetch;
  private base: string;
  private sleep: (ms: number) => Promise<void>;
  constructor(private cfg: LiveConfig) {
    // Bind the global: calling an unbound `fetch` as a method throws "Illegal invocation" in Workers.
    this.f = cfg.fetch ?? ((input, init) => fetch(input, init));
    this.base = cfg.base ?? BASE_DEFAULT;
    this.sleep = cfg.sleep ?? ((ms) => new Promise((r) => setTimeout(r, ms)));
  }

  private headers() {
    return { Authorization: `Bearer ${this.cfg.apiKey}`, "Content-Type": "application/json" };
  }

  private async json(res: Response): Promise<Record<string, unknown>> {
    const text = await res.text();
    if (!res.ok) throw mapHttpError(res.status, text);
    try {
      return JSON.parse(text) as Record<string, unknown>;
    } catch {
      throw new YouCamError("upstream", "non_json", "The try-on service sent an unexpected reply.", true);
    }
  }

  async upload(task: YouCamTask, file: Upload): Promise<string> {
    const body = JSON.stringify({ files: [{ content_type: file.type, file_name: file.name, file_size: file.bytes.length }] });
    let res = await this.f(`${this.base}/file/${task}`, { method: "POST", headers: this.headers(), body });
    if (res.status === 404) res = await this.f(`${this.base}/file`, { method: "POST", headers: this.headers(), body });
    const j = await this.json(res);
    const f0 = (j.data as { files?: Array<{ file_id?: string; requests?: Array<{ url?: string; method?: string; headers?: Record<string, string> }> }> })?.files?.[0];
    const req = f0?.requests?.[0];
    if (!f0?.file_id || !req?.url) throw new YouCamError("upstream", "upload_init_shape", "The try-on service sent an unexpected reply.", true);
    const put = await this.f(req.url, { method: req.method ?? "PUT", headers: req.headers ?? {}, body: file.bytes });
    if (!put.ok) throw new YouCamError("upstream", `upload_put_${put.status}`, "Uploading your photo failed. Try again.", true);
    return f0.file_id;
  }

  async run(task: YouCamTask, payload: Record<string, unknown>): Promise<TaskOutcome> {
    const created = await this.json(await this.f(`${this.base}/task/${task}`, { method: "POST", headers: this.headers(), body: JSON.stringify(payload) }));
    const taskId = (created.data as { task_id?: string })?.task_id;
    if (!taskId) throw new YouCamError("upstream", "task_create_shape", "The try-on service sent an unexpected reply.", true);
    const deadline = Date.now() + (this.cfg.deadlineMs ?? 120_000);
    for (let i = 0; Date.now() < deadline; i++) {
      await this.sleep(i < 10 ? 3000 : 6000);
      const polled = await this.json(await this.f(`${this.base}/task/${task}/${taskId}`, { headers: this.headers() }));
      const data = (polled.data ?? {}) as Record<string, unknown>;
      const status = data.task_status;
      if (status === "error") throw mapTaskError(String(data.error ?? "error_unknown"), data.error_message as string | undefined);
      if (status === "success") {
        const url = resultUrl(data.results);
        if (!url) return { data };
        const img = await this.f(url);
        if (!img.ok) throw new YouCamError("upstream", `result_download_${img.status}`, "We couldn't fetch the result. Try again.", true);
        return { data, image: new Uint8Array(await img.arrayBuffer()) };
      }
    }
    throw new YouCamError("timeout", "poll_deadline", "This is taking too long. Try again.", true);
  }
}

export function resultUrl(results: unknown): string | undefined {
  if (results && typeof results === "object" && !Array.isArray(results)) {
    const u = (results as { url?: unknown }).url;
    return typeof u === "string" ? u : undefined;
  }
  if (Array.isArray(results) && results[0] && typeof results[0] === "object") {
    const u = (results[0] as { url?: unknown }).url;
    return typeof u === "string" ? u : undefined;
  }
  return undefined;
}

// ---------- replay ----------

export interface ColorTonesColor {
  skin_color: string;
  hair_color?: string;
  eye_color?: string;
  lip_color?: string;
  eyebrow_color?: string;
  hair_color_name?: string;
  eye_color_name?: string;
}

export const PERSONA_READING: ColorTonesColor = personaReading.data.results.color;

/** Where a recorded persona try-on for a product colorway lives in public/ (it may not exist yet). */
export function replayTryonPath(productId: string, colorwayId: string): string {
  return `/persona/tryon_${productId}_${colorwayId}.jpg`;
}

export const REPLAY_MAKEUP = "/persona/makeup.jpg";

export type Metal = "gold" | "silver" | "rose gold";
const METAL_FILE: Record<Metal, string> = { gold: "gold", silver: "silver", "rose gold": "rose-gold" };

/** Catalogue earring image for a palette metal. */
export function earringAsset(metal: Metal): string {
  return `/catalog/jewelry/earring_${METAL_FILE[metal]}.jpg`;
}

/** Where a recorded persona earring render for a metal lives in public/ (it may not exist yet). */
export function replayEarringPath(metal: Metal): string {
  return `/persona/earring_${METAL_FILE[metal]}.jpg`;
}

/** 2D jewellery VTO payload: one earring on the face photo, background removed by the engine. */
export function earringPayload(srcFileId: string, refFileId: string): Record<string, unknown> {
  return {
    src_file_id: srcFileId,
    ref_file_ids: [refFileId],
    source_info: { name: srcFileId },
    object_infos: [{ name: refFileId, parameter: { earring_need_remove_background: true, earring_occluded_type: 0 } }],
  };
}
