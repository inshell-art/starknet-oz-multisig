#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
NETWORK="${NETWORK:-}"
LANE="${LANE:-}"
RUN_ID="${RUN_ID:-}"
INTENT_INPUT="${INTENT_INPUT:-}"
OUT_DIR="${OUT_DIR:-}"

if [[ -z "$NETWORK" || -z "$LANE" ]]; then
  echo "Missing NETWORK or LANE env vars." >&2
  exit 1
fi

if [[ -z "$RUN_ID" ]]; then
  if [[ -n "${GITHUB_RUN_ID:-}" ]]; then
    RUN_ID="$GITHUB_RUN_ID"
  else
    RUN_ID=$(date -u +%Y%m%dT%H%M%SZ)
  fi
fi

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$ROOT_DIR/artifacts/$NETWORK/current/intents"
fi
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/intent.${RUN_ID}.json"

export NETWORK LANE RUN_ID INTENT_INPUT OUT_FILE

python3 - <<'PY'
import json
import os
from datetime import datetime, timezone
from pathlib import Path

network = os.environ["NETWORK"]
lane = os.environ["LANE"]
run_id = os.environ["RUN_ID"]
intent_input = os.environ.get("INTENT_INPUT")

created_at = datetime.now(timezone.utc).isoformat()

if intent_input:
    data = json.loads(Path(intent_input).read_text())
else:
    data = {
        "intent_version": "1",
        "network": network,
        "lane": lane,
        "ops": [],
        "description": "Plan placeholder. Populate ops before approval/apply.",
        "created_at": created_at,
    }

# Fill defaults + validate
if "intent_version" not in data:
    data["intent_version"] = "1"
if "network" not in data:
    data["network"] = network
if "lane" not in data:
    data["lane"] = lane
if "created_at" not in data:
    data["created_at"] = created_at

if data["network"] != network:
    raise SystemExit("intent network mismatch")
if data["lane"] != lane:
    raise SystemExit("intent lane mismatch")

Path(os.environ["OUT_FILE"]).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
print(f"Wrote intent: {os.environ['OUT_FILE']}")

if os.environ.get("GITHUB_OUTPUT"):
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as fh:
        fh.write(f"intent_path={os.environ['OUT_FILE']}\n")
PY
