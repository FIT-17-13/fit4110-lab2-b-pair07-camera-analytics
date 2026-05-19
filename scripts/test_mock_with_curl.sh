#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:4010}"
AUTH_HEADER="Authorization: Bearer test-token"

echo "[Lab02] Testing Prism mock server at $BASE_URL"
echo

echo "[1/5] Happy path: GET /health"
curl -i "$BASE_URL/health"
echo "
---"

echo "[2/5] Happy path: GET /camera-events/recent"
curl -i "$BASE_URL/camera-events/recent" -H "$AUTH_HEADER"
echo "
---"

echo "[3/5] Happy path: POST /camera-events"
curl -i -X POST "$BASE_URL/camera-events" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "eventType": "camera.motion.detected",
    "eventId": "0196fb3d-4ad7-7d1e-9f49-5d5148d2babc",
    "occurredAt": "2026-05-10T08:00:00Z",
    "cameraId": "CAM-007",
    "sourceService": "camera-stream",
    "correlationId": "0196fb3d-4ad7-7d1e-9f49-5d5148d2b000",
    "detectionId": "0196fb3d-4ad7-7d1e-9f49-5d5148d2b111",
    "motionType": "HUMAN",
    "imageRef": "https://cdn.campus.local/camera/CAM-007/frame-001.jpg",
    "confidence": 0.92
  }'
echo "
---"

echo "[4/5] Happy path: GET /camera-events/{eventId}"
curl -i "$BASE_URL/camera-events/0196fb3d-4ad7-7d1e-9f49-5d5148d2babc" -H "$AUTH_HEADER"
echo "
---"

echo "[5/5] Error case: POST /camera-events invalid payload"
curl -i -X POST "$BASE_URL/camera-events" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{ "eventType": 12345 }'
echo
