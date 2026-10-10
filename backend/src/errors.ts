// Every developer-facing error has the same envelope: what happened, how to fix it, where to read more.
export type ErrorCode =
  | "DRAPE_BAD_REQUEST"
  | "DRAPE_BAD_KEY"
  | "DRAPE_UNAUTHORIZED"
  | "DRAPE_DOMAIN_NOT_ALLOWED"
  | "DRAPE_PRODUCT_NOT_FOUND"
  | "DRAPE_SESSION_NOT_FOUND"
  | "DRAPE_JOB_NOT_FOUND"
  | "DRAPE_IMAGE_INVALID"
  | "DRAPE_IMAGE_TOO_LARGE"
  | "DRAPE_CATEGORY_UNSUPPORTED"
  | "DRAPE_PHOTO_MISSING"
  | "DRAPE_BUDGET_EXHAUSTED"
  | "DRAPE_NOT_FOUND"
  | "DRAPE_INTERNAL";

const DOCS = "https://github.com/Ramy888/YouCamNewSkin-Drape#errors";

export class DrapeError extends Error {
  constructor(
    public code: ErrorCode,
    public status: number,
    message: string,
    public fix: string,
  ) {
    super(message);
  }
}

export function errorResponse(e: unknown, requestId: string, headers: HeadersInit = {}): Response {
  const err =
    e instanceof DrapeError
      ? e
      : new DrapeError("DRAPE_INTERNAL", 500, "Something went wrong on our side.", "Try again; if it keeps failing, report the request_id.");
  if (!(e instanceof DrapeError)) console.error(JSON.stringify({ level: "error", request_id: requestId, error: String(e), stack: (e as Error)?.stack }));
  return Response.json(
    { error: { code: err.code, message: err.message, fix: err.fix, docs_url: `${DOCS}-${err.code.toLowerCase()}`, request_id: requestId } },
    { status: err.status, headers },
  );
}

export const bad = (message: string, fix: string) => new DrapeError("DRAPE_BAD_REQUEST", 400, message, fix);
