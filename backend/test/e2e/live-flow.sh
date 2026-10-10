#!/usr/bin/env bash
# End-to-end test of LIVE mode against the local mock YouCam (no key, no units).
# Starts the mock and `wrangler dev` with live settings, then walks a real-photo session:
# face upload -> colour reading -> body upload -> try-on -> makeup -> earrings, plus error and cap cases.
set -euo pipefail
cd "$(dirname "$0")/../.."
MOCK=9999 PORT=8799
B="http://localhost:$PORT"
pass=0; fail=0
check() { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1)); else echo "  FAIL $1: expected [$3] got [$2]"; fail=$((fail+1)); fi; }
js() { node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{const j=JSON.parse(d);console.log(eval(process.argv[1]))})" "$1"; }

node test/e2e/mock-youcam.mjs $MOCK > /tmp/drape-mock.log 2>&1 & MOCK_PID=$!
npx wrangler dev --port $PORT --persist-to /tmp/drape-e2e-state \
  --var YOUCAM_MODE:live --var YOUCAM_LIVE_BUDGET:30 --var YOUCAM_API_KEY:test-key \
  --var YOUCAM_API_BASE:http://localhost:$MOCK/s2s/v2.0 --var FACES_PER_VISITOR_PER_DAY:1 \
  --var SESSION_SECRET:e2e-only-secret --var SELLER_SECRET:sk_e2e_only > /tmp/drape-e2e.log 2>&1 & DEV_PID=$!
trap 'kill $MOCK_PID $DEV_PID 2>/dev/null; rm -rf /tmp/drape-e2e-state' EXIT
for i in $(seq 1 60); do curl -sf "$B/health" >/dev/null && break; sleep 1; done

echo "health"
check "mode is live" "$(curl -s $B/health | js 'j.mode')" "live"

T=$(curl -s -X POST $B/v1/sessions -H 'content-type: application/json' -d '{"key":"pk_demo_drape"}' | js 'j.token')
H="authorization: Bearer $T"
poll() { for i in $(seq 1 40); do s=$(curl -s "$B/v1/jobs/$1" -H "$H" | js 'j.job.status'); [ "$s" = done ] || [ "$s" = error ] && { echo $s; return; }; sleep 1; done; echo timeout; }
job() { curl -s -X POST $B/v1/sessions/me/jobs -H "$H" -H 'content-type: application/json' -d "$1" | js 'j.job.id'; }

echo "photos"
check "reading before face photo is refused" "$(curl -s -X POST $B/v1/sessions/me/jobs -H "$H" -H 'content-type: application/json' -d '{"type":"color_reading"}' | js 'j.error.code')" "DRAPE_PHOTO_MISSING"
check "face upload" "$(curl -s -X POST "$B/v1/sessions/me/photos?kind=face" -H "$H" --data-binary @public/persona/face.jpg | js 'j.session.photos.face!==null')" "true"

echo "colour reading (20 units)"
J=$(job '{"type":"color_reading"}'); check "reading done" "$(poll $J)" "done"
check "palette warm from the live reading" "$(curl -s $B/v1/sessions/me -H "$H" | js 'j.palette.undertone')" "warm"
check "20 units committed" "$(curl -s $B/health | js 'j.units.committed')" "20"

echo "try-on (2 units)"
check "try-on before body photo is refused" "$(curl -s -X POST $B/v1/sessions/me/jobs -H "$H" -H 'content-type: application/json' -d '{"type":"tryon","productId":"abaya-classic","colorwayId":"emerald"}' | js 'j.error.code')" "DRAPE_PHOTO_MISSING"
curl -s -X POST "$B/v1/sessions/me/photos?kind=body" -H "$H" --data-binary @public/persona/body.jpg > /dev/null
J=$(job '{"type":"tryon","productId":"abaya-classic","colorwayId":"emerald"}'); check "try-on done" "$(poll $J)" "done"
IMG=$(curl -s "$B/v1/jobs/$J" -H "$H" | js 'j.job.result.image')
check "result copied to our storage" "$(curl -s -o /dev/null -w '%{http_code}' "$B$IMG")" "200"
J2=$(job '{"type":"tryon","productId":"abaya-classic","colorwayId":"emerald"}'); check "double tap joins the same job" "$J2" "$J"

echo "makeup + earrings (1 + 1 units)"
J=$(job '{"type":"makeup"}'); check "makeup done" "$(poll $J)" "done"
J=$(job '{"type":"jewelry"}'); check "earrings done" "$(poll $J)" "done"
check "metal is gold" "$(curl -s "$B/v1/jobs/$J" -H "$H" | js 'j.job.result.metal')" "gold"
check "24 units committed" "$(curl -s $B/health | js 'j.units.committed')" "24"

echo "errors"
printf 'MULTI' | cat public/persona/body.jpg - > /tmp/drape-multi.jpg
curl -s -X POST "$B/v1/sessions/me/photos?kind=body" -H "$H" --data-binary @/tmp/drape-multi.jpg > /dev/null
J=$(job '{"type":"tryon","productId":"abaya-classic","colorwayId":"black"}'); check "YouCam photo error surfaces" "$(poll $J)" "error"
check "error code kept for the app" "$(curl -s "$B/v1/jobs/$J" -H "$H" | js 'j.job.error.code')" "error_multi_person"
check "buyer gets retake advice" "$(curl -s "$B/v1/jobs/$J" -H "$H" | js '/one person/i.test(j.job.error.message)')" "true"
check "failed task released its units" "$(curl -s $B/health | js 'j.units.used')" "24"

echo "limits"
curl -s -X POST "$B/v1/sessions/me/photos?kind=body" -H "$H" --data-binary @public/persona/body.jpg > /dev/null
J=$(job '{"type":"tryon","productId":"abaya-classic","colorwayId":"black"}'); poll $J > /dev/null
J=$(job '{"type":"tryon","productId":"abaya-classic","colorwayId":"lavender"}'); poll $J > /dev/null
check "28 of 30 units used" "$(curl -s $B/health | js 'j.units.used')" "28"
T2=$(curl -s -X POST $B/v1/sessions -H 'content-type: application/json' -d '{"key":"pk_demo_drape"}' | js 'j.token')
curl -s -X POST "$B/v1/sessions/me/photos?kind=face" -H "authorization: Bearer $T2" --data-binary @public/persona/face.jpg > /dev/null
J=$(curl -s -X POST $B/v1/sessions/me/jobs -H "authorization: Bearer $T2" -H 'content-type: application/json' -d '{"type":"color_reading"}' | js 'j.job.id')
check "a face reading past the budget falls back to the labelled sample" "$(curl -s "$B/v1/jobs/$J" -H "authorization: Bearer $T2" | js 'j.job.result.sample')" "true"

echo "delete"
check "delete session" "$(curl -s -X DELETE $B/v1/sessions/me -H "$H" | js 'j.deleted')" "true"
check "result file gone" "$(curl -s -o /dev/null -w '%{http_code}' "$B$IMG")" "404"

echo "mock saw the generic /file upload and these task types:"
curl -s localhost:$MOCK/calls | node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{const c=JSON.parse(d);console.log('  ',[...new Set(c.filter(x=>x.startsWith('POST /s2s/v2.0/task/')))].join(', '))})"
echo "passed $pass, failed $fail"
[ $fail -eq 0 ]
