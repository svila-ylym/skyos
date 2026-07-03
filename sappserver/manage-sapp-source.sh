#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$ROOT/repo"
BIND_ADDRESS="127.0.0.1"
PORT="8080"
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
Usage: ./manage-sapp-source.sh [--repo PATH] [--bind ADDRESS] [--port PORT]

Starts the single-port SAPP server. The public package list is / and the
management panel is /admin.
EOF
}

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
    --port)
      PORT="${2:?missing --port value}"
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
exec "${PYTHON_BIN[@]}" "$ROOT/sapp_manage_server.py" --repo "$REPO" --bind "$BIND_ADDRESS" --port "$PORT"
