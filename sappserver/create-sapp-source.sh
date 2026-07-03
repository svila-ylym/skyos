#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$ROOT/repo"
VALIDATE_ONLY=0
NO_SAMPLES=0
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
Usage: ./create-sapp-source.sh [--repo PATH] [--keep-pool] [--no-samples] [--validate-only]

Builds or validates a SkyOS SAPP repository using binary SPK packages.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="${2:?missing --repo value}"
      shift 2
      ;;
    --keep-pool|--no-samples)
      NO_SAMPLES=1
      shift
      ;;
    --validate-only)
      VALIDATE_ONLY=1
      shift
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
if [ "$VALIDATE_ONLY" -eq 1 ]; then
  exec "${PYTHON_BIN[@]}" "$ROOT/spk.py" validate --repo "$REPO"
fi

if [ "$NO_SAMPLES" -eq 1 ]; then
  exec "${PYTHON_BIN[@]}" "$ROOT/spk.py" index --repo "$REPO" --no-samples
fi
exec "${PYTHON_BIN[@]}" "$ROOT/spk.py" index --repo "$REPO"
