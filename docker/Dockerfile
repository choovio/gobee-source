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
    case "$SVC" in \
      users|domains|http|ws|mqtt|coap)                    make -C third_party/supermq "$SVC" ;; \
      lora|opcua)                                         make -C third_party/supermq-contrib "$SVC" ;; \
      certs)                                              make -C third_party/certs "$SVC" ;; \
      bootstrap|provision|readers|writers|rules|alarms|reports) make "$SVC" ;; \
      *) echo "Unknown service: $SVC" >&2; exit 1 ;; \
    esac; \
    (upx build/$SVC || true); \
    mv build/$SVC /exe

FROM scratch
# Certificates are needed so that mailing util can work.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /exe /
ENTRYPOINT ["/exe"]

