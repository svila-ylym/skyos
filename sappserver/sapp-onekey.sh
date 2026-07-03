#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$ROOT/repo"
BIND_ADDRESS="127.0.0.1"
PORT="8080"
MODE="server"
PYTHON_BIN=()

detect_python() {
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN=(python3)
  elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN=(python)
  elif command -v py >/dev/null 2>&1; then
    PYTHON_BIN=(py -3)
  else
    echo "python3 or python is required." >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF'
Usage: ./sapp-onekey.sh [server|validate] [--repo PATH] [--bind ADDRESS] [--port PORT]

Modes:
  server    Generate/validate repo, then start the single-port SAPP server
  validate  Generate/validate repo and exit

Default URLs:
  http://127.0.0.1:8080/       public package list
  http://127.0.0.1:8080/admin  management panel
EOF
}

if [ "$#" -gt 0 ]; then
  case "$1" in
    server|panel|source)
      MODE="server"
      shift
      ;;
    validate)
      MODE="validate"
      shift
      ;;
  esac
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="${2:?missing --repo value}"
      shift 2
      ;;
    --bind)
      BIND_ADDRESS="${2:?missing --bind value}"
      shift 2
      ;;
    --port|--source-port|--panel-port)
      PORT="${2:?missing port value}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

detect_python

echo "[1/2] Building SAPP repository index..."
"${PYTHON_BIN[@]}" "$ROOT/spk.py" index --repo "$REPO"

echo "[2/2] Validating SAPP repository..."
"${PYTHON_BIN[@]}" "$ROOT/spk.py" validate --repo "$REPO"

if [ "$MODE" = "validate" ]; then
  echo "Done."
  exit 0
fi

echo "Open: http://$BIND_ADDRESS:$PORT/"
echo "Admin: http://$BIND_ADDRESS:$PORT/admin"
exec "${PYTHON_BIN[@]}" "$ROOT/sapp_manage_server.py" --repo "$REPO" --bind "$BIND_ADDRESS" --port "$PORT"
