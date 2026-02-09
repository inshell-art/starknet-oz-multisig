#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
NETWORK="${NETWORK:-}"
LANE="${LANE:-}"
RUN_ID="${RUN_ID:-}"
CHECKS_INPUT="${CHECKS_INPUT:-}"
POLICY_TEMPLATE="${POLICY_TEMPLATE:-}"
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

if [[ -z "$POLICY_TEMPLATE" ]]; then
  if [[ -f "$ROOT_DIR/ops/policy/${NETWORK}.policy.json" ]]; then
    POLICY_TEMPLATE="$ROOT_DIR/ops/policy/${NETWORK}.policy.json"
  elif [[ -f "$ROOT_DIR/ops/policy/policy.template.json" ]]; then
    POLICY_TEMPLATE="$ROOT_DIR/ops/policy/policy.template.json"
  fi
fi

if [[ -z "$POLICY_TEMPLATE" || ! -f "$POLICY_TEMPLATE" ]]; then
  echo "Missing policy template: $POLICY_TEMPLATE" >&2
  exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$ROOT_DIR/artifacts/$NETWORK/current/checks"
fi
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/checks.${RUN_ID}.json"

export NETWORK LANE RUN_ID CHECKS_INPUT POLICY_TEMPLATE OUT_FILE

python3 - <<'PY'
import json
import os
from datetime import datetime, timezone
from pathlib import Path

network = os.environ["NETWORK"]
lane = os.environ["LANE"]
run_id = os.environ["RUN_ID"]
checks_input = os.environ.get("CHECKS_INPUT")
policy_path = Path(os.environ["POLICY_TEMPLATE"])

created_at = datetime.now(timezone.utc).isoformat()

policy = json.loads(policy_path.read_text())
lanes = policy.get("lanes", {})
if lane not in lanes:
    raise SystemExit(f"lane '{lane}' not defined in policy")

required = lanes.get(lane, {}).get("required_checks")
if required is None:
    required = policy.get("lane_defaults", {}).get("required_checks", [])

if checks_input:
    data = json.loads(Path(checks_input).read_text())
else:
    data = {
        "checks_version": "1",
        "network": network,
        "lane": lane,
        "required_checks": required,
        "checks": [{"name": name, "status": "pending", "details": "not evaluated"} for name in required],
        "status": "pending",
        "generated_at": created_at,
        "notes": "Plan/check placeholder. Populate required checks before approval/apply.",
    }

if "checks_version" not in data:
    data["checks_version"] = "1"
if "network" not in data:
    data["network"] = network
if "lane" not in data:
    data["lane"] = lane
if "generated_at" not in data:
    data["generated_at"] = created_at
if "required_checks" not in data:
    data["required_checks"] = required

if data["network"] != network:
    raise SystemExit("checks network mismatch")
if data["lane"] != lane:
    raise SystemExit("checks lane mismatch")

# Ensure all required checks exist
existing = {c.get("name") for c in data.get("checks", []) if isinstance(c, dict)}
for name in required:
    if name not in existing:
        data.setdefault("checks", []).append({"name": name, "status": "pending", "details": "not evaluated"})

if "status" not in data:
    data["status"] = "pending"

Path(os.environ["OUT_FILE"]).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
print(f"Wrote checks: {os.environ['OUT_FILE']}")

if os.environ.get("GITHUB_OUTPUT"):
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as fh:
        fh.write(f"checks_path={os.environ['OUT_FILE']}\n")
PY
