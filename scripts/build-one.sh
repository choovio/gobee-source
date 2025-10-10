#!/bin/sh
set -euo pipefail
SVC="${1:-}"; [ -z "$SVC" ] && { echo "missing SVC" >&2; exit 2; }

case "$SVC" in
  users|domains|http|ws|mqtt|coap) cd third_party/supermq ;;
  lora|opcua)                      cd third_party/supermq-contrib ;;
  certs)                           cd third_party/certs ;;
  bootstrap|provision|readers|writers|rules|alarms|reports) cd . ;;
  *) echo "Unknown service: $SVC" >&2; exit 10 ;;
esac

# Prefer Make target if present; else build ./cmd/<svc>
if [ -f Makefile ] && grep -qE "^$SVC:" Makefile; then
  make "$SVC"
  BIN="build/$SVC"
else
  [ -d "cmd/$SVC" ] || { echo "No Make target or cmd/$SVC in $(pwd)" >&2; exit 11; }
  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o "build/$SVC" "./cmd/$SVC"
  BIN="build/$SVC"
fi

command -v upx >/dev/null 2>&1 && upx "$BIN" || true
mkdir -p /exe && mv "$BIN" /exe
