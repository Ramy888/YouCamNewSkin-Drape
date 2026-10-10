import { describe, expect, it, vi } from "vitest";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
const here = (rel: string) => join(__dirname, rel);
import { signSession, verifySession } from "../src/auth";
import { sniff, stripJpegMetadata, validateImage } from "../src/images";
import { earringAsset, earringPayload, LiveYouCam, mapTaskError, replayTryonPath, resultUrl, YouCamError } from "../src/youcam";

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
const uploadInit = () => json({ status: 200, data: { files: [{ file_id: "f1", requests: [{ url: "https://put.example/x", method: "PUT", headers: {} }] }] } });

function fakeFetch(steps: Array<Response | ((url: string) => Response)>) {
  const calls: string[] = [];
  const f = vi.fn(async (input: RequestInfo | URL) => {
    const url = String(input);
    calls.push(url);
    const next = steps.shift();
    if (!next) throw new Error(`unexpected fetch ${url}`);
    return typeof next === "function" ? next(url) : next;
  });
  return { f: f as unknown as typeof fetch, calls };
}
const noSleep = async () => {};

describe("live adapter", () => {
  it("uploads, creates the task, polls and downloads the result image", async () => {
    const { f, calls } = fakeFetch([
      uploadInit(),
      new Response(null, { status: 200 }),
      json({ data: { task_id: "t1" } }),
      json({ data: { task_status: "running" } }),
      json({ data: { task_status: "success", results: { url: "https://cdn.example/out.jpg" } } }),
      new Response(new Uint8Array([1, 2, 3])),
    ]);
    const yc = new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep });
    const id = await yc.upload("cloth-v4", { bytes: new Uint8Array([9]), type: "image/jpeg", name: "a.jpg" });
    const out = await yc.run("cloth-v4", { src_file_id: id });
    expect(id).toBe("f1");
    expect(out.image).toEqual(new Uint8Array([1, 2, 3]));
    expect(calls[0]).toMatch(/\/file\/cloth-v4$/);
    expect(calls[2]).toMatch(/\/task\/cloth-v4$/);
  });

  it("falls back to the generic /file endpoint when the per-task one is 404", async () => {
    const { f, calls } = fakeFetch([new Response("nope", { status: 404 }), uploadInit(), new Response(null, { status: 200 })]);
    await new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep }).upload("makeup-vto", { bytes: new Uint8Array([1]), type: "image/jpeg", name: "a" });
    expect(calls[1]).toMatch(/\/file$/);
  });

  it("maps the recorded error_face_angle_downward response to retake advice (not retryable)", async () => {
    const recorded = { status: 200, data: { error: "error_face_angle_downward", error_message: "The face is tilted too far downward", results: null, task_status: "error" } };
    const { f } = fakeFetch([json({ data: { task_id: "t" } }), json(recorded)]);
    const err = await new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep }).run("skin-tone-analysis", {}).catch((e) => e);
    expect(err).toBeInstanceOf(YouCamError);
    expect(err.kind).toBe("user_photo");
    expect(err.userMessage).toMatch(/chin/);
    expect(err.retryable).toBe(false);
  });

  it.each([
    ["error_multi_person", "user_photo", /one person/i],
    ["error_pose", "user_photo", /facing the camera/i],
    ["error_nsfw_content_detected", "rejected", /can't be used/],
    ["error_something_new", "upstream", /service/],
  ])("maps %s", (code, kind, msg) => {
    const e = mapTaskError(code);
    expect(e.kind).toBe(kind);
    expect(e.userMessage).toMatch(msg);
  });

  it("maps 401 to auth, 429 to rate_limit, non-JSON to upstream", async () => {
    for (const [res, kind] of [[new Response("x", { status: 401 }), "auth"], [new Response("x", { status: 429 }), "rate_limit"], [new Response("<html>"), "upstream"]] as const) {
      const { f } = fakeFetch([res]);
      const e = await new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep }).run("cloth-v4", {}).catch((x) => x);
      expect(e.kind).toBe(kind);
    }
  });

  it("times out at the deadline instead of polling forever", async () => {
    let t = 0;
    vi.spyOn(Date, "now").mockImplementation(() => (t += 50_000));
    const { f } = fakeFetch([json({ data: { task_id: "t" } }), ...Array.from({ length: 10 }, () => json({ data: { task_status: "running" } }))]);
    const e = await new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep, deadlineMs: 120_000 }).run("cloth-v4", {}).catch((x) => x);
    vi.restoreAllMocks();
    expect(e.kind).toBe("timeout");
  });

  it("treats a task-create reply without task_id as an upstream error", async () => {
    const { f } = fakeFetch([json({ data: {} })]);
    const e = await new LiveYouCam({ apiKey: "k", fetch: f, sleep: noSleep }).run("cloth-v4", {}).catch((x) => x);
    expect(e.youcamCode).toBe("task_create_shape");
  });

  it("reads result urls from object or array shapes", () => {
    expect(resultUrl({ url: "a" })).toBe("a");
    expect(resultUrl([{ url: "b" }])).toBe("b");
    expect(resultUrl(null)).toBeUndefined();
  });
});

describe("replay", () => {
  it("maps a product colorway to its recorded try-on path", () => {
    expect(replayTryonPath("abaya-classic", "emerald")).toBe("/persona/tryon_abaya-classic_emerald.jpg");
  });
  it("every recorded try-on path exists in public/persona", () => {
    for (const cw of ["black", "emerald"]) {
      expect(() => readFileSync(here(`../public/persona/tryon_abaya-classic_${cw}.jpg`))).not.toThrow();
    }
  });
  it("no replay fixture contains a remote result URL (they expire after 24h)", () => {
    const dirs = [here("../public/persona"), here("../../docs/derisk/fixtures")];
    for (const d of dirs) {
      for (const f of readdirSync(d).filter((x) => x.endsWith(".json"))) {
        expect(readFileSync(join(d, f), "utf8"), f).not.toMatch(/https?:\/\//);
      }
    }
  });
});

describe("earrings", () => {
  it("builds the 2D VTO payload with matching source and object names", () => {
    const p = earringPayload("src1", "ref1") as { ref_file_ids: string[]; source_info: { name: string }; object_infos: Array<{ name: string }> };
    expect(p.ref_file_ids).toEqual(["ref1"]);
    expect(p.source_info.name).toBe("src1");
    expect(p.object_infos[0].name).toBe("ref1");
  });
  it("has a catalogue earring image for every palette metal", () => {
    for (const m of ["gold", "silver", "rose gold"] as const) {
      expect(() => readFileSync(here(`../public${earringAsset(m)}`))).not.toThrow();
    }
  });
  it("tells the buyer covered ears are fine", () => {
    expect(mapTaskError("error_face_parsing").userMessage).toMatch(/ears/);
  });
});

describe("images", () => {
  const jpeg = (segments: number[][]) => new Uint8Array([0xff, 0xd8, ...segments.flat(), 0xff, 0xda, 0x00, 0x02, 0x11, 0x22, 0xff, 0xd9]);
  const seg = (marker: number, payload: number[]) => [0xff, marker, 0, payload.length + 2, ...payload];

  it("detects JPEG and PNG by magic bytes and rejects other files", () => {
    expect(sniff(jpeg([]))).toBe("image/jpeg");
    expect(sniff(new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0]))).toBe("image/png");
    expect(() => validateImage(new TextEncoder().encode("GIF89a....."))).toThrow(/not a JPEG or PNG/);
    expect(() => validateImage(new Uint8Array())).toThrow(/empty/);
  });

  it("strips EXIF (APP1) and comments but keeps JFIF (APP0) and image data", () => {
    const app0 = seg(0xe0, [0x4a, 0x46]);
    const exif = seg(0xe1, [0x45, 0x78, 0x69, 0x66, 0x47, 0x50, 0x53]); // "Exif" + "GPS"
    const com = seg(0xfe, [0x68, 0x69]);
    const out = stripJpegMetadata(jpeg([app0, exif, com]));
    expect(out).toEqual(jpeg([app0]));
  });

  it("leaves a malformed JPEG untouched rather than corrupting it", () => {
    const broken = new Uint8Array([0xff, 0xd8, 0x00, 0x01, 0x02, 0x03]);
    expect(stripJpegMetadata(broken)).toBe(broken);
  });
});

describe("session tokens", () => {
  it("round-trips, and rejects tampered or expired tokens", async () => {
    const t = await signSession("s3cret", "ses_1", Date.now() + 60_000);
    expect(await verifySession("s3cret", t)).toBe("ses_1");
    await expect(verifySession("other", t)).rejects.toThrow(/expired|missing/);
    await expect(verifySession("s3cret", t.replace("ses_1", "ses_2"))).rejects.toThrow();
    const old = await signSession("s3cret", "ses_1", Date.now() - 1);
    await expect(verifySession("s3cret", old)).rejects.toThrow();
    await expect(verifySession("s3cret", null)).rejects.toThrow();
  });
});
