"""Export every Arabic string in app/lib/l10n.dart, with its English, into a review sheet (CSV, opens in Excel/Sheets).

Usage (repo root): python3 docs/submission/export_arabic.py
"""
import csv, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
src = open(os.path.join(ROOT, "app", "lib", "l10n.dart"), encoding="utf-8").read()
STR = r"'((?:[^'\\]|\\.)*)'"
unq = lambda v: v.replace("\\'", "'").replace("\\$", "$")

# English for the server error codes the app translates: the backend's own buyer messages.
backend = open(os.path.join(ROOT, "backend", "src", "youcam.ts"), encoding="utf-8").read()
server_en = dict(re.findall(r'(\w+): "([^"]+)"', backend[backend.index("PHOTO_ADVICE"):backend.index("export function mapTaskError")]))

# ...and the API's error messages (one code can have several; the reviewer sees them all).
for f in os.listdir(os.path.join(ROOT, "backend", "src")):
    if f.endswith(".ts"):
        for code, msg in re.findall(r'DrapeError\(\s*"(DRAPE_\w+)",\s*\d+,\s*"([^"]+)"', open(os.path.join(ROOT, "backend", "src", f), encoding="utf-8").read()):
            server_en[code] = msg if code not in server_en else (server_en[code] if msg in server_en[code] else server_en[code] + " / " + msg)

for code, msg in re.findall(r'YouCamError\(\s*"\w+",\s*"(\w+)",\s*"([^"]+)"', backend):
    server_en.setdefault(code, msg)
# Messages built at runtime, written out by hand.
server_en.setdefault("http_401", "Live try-on is paused. Showing the demo look instead.")
server_en.setdefault("error_nsfw_content_detected", "This photo can't be used. Please choose a different one.")
server_en.setdefault("DRAPE_DOMAIN_NOT_ALLOWED", "<site> is not on the store's allowed list.")
server_en.setdefault("DRAPE_BUDGET_EXHAUSTED", "Today's live try-on limit is reached. Showing the sample look instead.")

rows, screen, fn = [], "general", ""
for line in src.splitlines():
    s = line.strip()
    f = re.match(r"String (\w+)\(", s)
    if f:
        fn = f.group(1)
    case = re.match(r"(?:'(\w+)'|_) => _\(\s*" + STR + r"\s*,\s*" + STR, s)
    if case:  # switch arms such as  'warm' => _('Warm undertone', '…')
        rows.append((screen, f"{fn}.{case.group(1) or 'other'}", unq(case.group(2)), unq(case.group(3))))
        continue
    if s.startswith("// ") and len(s) < 40 and not s.startswith("// The") and not s.startswith("// English"):
        screen = s[3:]
    m = re.search(r"(?:String(?:\s+get)?\s+)(\w+)[^=]*=>.*?_\(\s*" + STR + r"\s*,\s*" + STR, line)
    if m:
        rows.append((screen, m.group(1), unq(m.group(2)), unq(m.group(3))))
        continue
    m = re.match(r"\s*'(\w+)':\s*" + STR + ",", line)
    if m:
        code = m.group(1)
        en = server_en.get(code, "(server message for " + code + ")")
        rows.append(("error message", code, en, unq(m.group(2))))

# Multi-line _( '…', '…') calls are joined so they are not missed.
for m in re.finditer(r"String(?:\s+get)?\s+(\w+)[^;]*?=>\s*_\(\s*\n\s*" + STR + r",\s*\n\s*" + STR, src):
    rows.append(("general", m.group(1), unq(m.group(2)), unq(m.group(3))))

out = os.path.join(ROOT, "docs", "submission", "arabic-review.csv")
with open(out, "w", encoding="utf-8-sig", newline="") as f:  # BOM so Excel shows Arabic correctly
    w = csv.writer(f)
    w.writerow(["#", "Screen", "Key", "English", "Arabic (current)", "Suggested Arabic", "Comment"])
    for i, (scr, key, en, ar) in enumerate(rows, 1):
        w.writerow([i, scr, key, en, ar, "", ""])
print(f"{len(rows)} strings -> {os.path.relpath(out, ROOT)}")
