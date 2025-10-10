# Copyright (c) Abstract Machines
# SPDX-License-Identifier: Apache-2.0

FROM golang:1.25.1-alpine AS builder
ARG SVC
ARG GOARCH
ARG GOARM
ARG VERSION
ARG COMMIT
ARG TIME

WORKDIR /go/src/github.com/absmach/magistrala
COPY . .
RUN apk update \
 && apk add --no-cache make upx git \
 && set -eux; \
    case "${SVC}" in \
      users|domains|http|ws|mqtt|coap)                         cd third_party/supermq ;; \
      lora|opcua)                                              cd third_party/supermq-contrib ;; \
      certs)                                                   cd third_party/certs ;; \
      bootstrap|provision|readers|writers|rules|alarms|reports) cd . ;; \
      *) echo "Unknown service: ${SVC}" >&2; exit 1 ;; \
    esac; \
    if [ -f Makefile ] && grep -qE "^${SVC}:" Makefile; then \
      make "${SVC}"; \
    else \
      test -d "cmd/${SVC}" || { echo "No Make target or cmd/${SVC} in $(pwd)"; exit 11; }; \
      GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o "build/${SVC}" "./cmd/${SVC}"; \
    fi; \
    (upx build/"${SVC}" || true); \
    mv build/"${SVC}" /exe

FROM scratch
# Certificates are needed so that mailing util can work.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /exe /
ENTRYPOINT ["/exe"]

