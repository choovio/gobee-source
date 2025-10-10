# Copyright (c) CHOOVIO Inc.
# SPDX-License-Identifier: Apache-2.0

# Unified multi-stage builder for all Magistrala services via ARG SVC.
# Auto-locates service entrypoint under these roots:
#   ./cmd/${SVC}
#   ./third_party/supermq/cmd/${SVC}
#   ./third_party/supermq-contrib/cmd/${SVC}
#   ./third_party/certs/cmd/${SVC}
#
# Usage (example):
#   docker build -f Dockerfile --build-arg SVC=users -t gobee-users:sbx-local .

ARG GO_VERSION=1.22
FROM golang:${GO_VERSION}-alpine AS builder

ARG SVC
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

RUN apk add --no-cache git ca-certificates bash

WORKDIR /src
COPY . .

# --- Auto-locate the service main package
RUN set -euo pipefail; \
    if [ -z "${SVC:-}" ]; then echo "ERROR: ARG SVC is required (e.g., users)" >&2; exit 1; fi; \
    roots="./cmd ./third_party/supermq/cmd ./third_party/supermq-contrib/cmd ./third_party/certs/cmd"; \
    found=""; \
    for r in $roots; do \
      if [ -f "${r}/${SVC}/main.go" ]; then found="${r}/${SVC}"; break; fi; \
    done; \
    if [ -z "$found" ]; then echo "ERROR: could not locate main.go for SVC='${SVC}' under expected roots" >&2; exit 2; fi; \
    echo ">> building ${SVC} from ${found}"; \
    cd "$found"; \
    go mod tidy || true; \
    go build -trimpath -ldflags "-s -w" -o "/out/${SVC}"

# Minimal runtime
FROM gcr.io/distroless/static:nonroot
ARG SVC
USER nonroot:nonroot
COPY --from=builder "/out/${SVC}" "/usr/local/bin/${SVC}"
ENTRYPOINT ["/usr/local/bin/${SVC}"]
