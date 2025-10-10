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
 && apk add --no-cache make upx git grep \
 && set -eux; \
    svcdir=""; \
    for d in "." "third_party/supermq" "third_party/supermq-contrib" "third_party/certs"; do \
      if [ -f "$d/Makefile" ] && grep -qE "^${SVC}:" "$d/Makefile"; then svcdir="$d"; build="make -C $d ${SVC}"; break; fi; \
      if [ -d "$d/cmd/${SVC}" ]; then svcdir="$d"; build="sh -c 'cd $d && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/${SVC} ./cmd/${SVC}'"; break; fi; \
    done; \
    [ -n "$svcdir" ] || { echo "Service ${SVC} not found in known locations"; exit 22; }; \
    eval $build; \
    (upx "$svcdir/build/${SVC}" || true); \
    mv "$svcdir/build/${SVC}" /exe

FROM scratch
# Certificates are needed so that mailing util can work.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /exe /
ENTRYPOINT ["/exe"]

