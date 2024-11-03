FROM golang:1.22-alpine AS build

ARG MC_RELEASE_VERSION

ENV GOPATH=/go
ENV CGO_ENABLED=0

RUN \
    apk add --no-cache bash git make perl; \
    MC_RELEASE_VERSION=${MC_RELEASE_VERSION:-$(wget -qO- https://api.github.com/repos/minio/mc/releases/latest | grep 'tag_name' | cut -d\" -f4)} ; \
    echo "MC_RELEASE_VERSION=${MC_RELEASE_VERSION}" ; \
    export MC_RELEASE="${MC_RELEASE_VERSION%%.*}" ; \
    git clone --single-branch --branch ${MC_RELEASE_VERSION} https://github.com/minio/mc.git /go/src/mc ; \
    cd /go/src/mc && make build && make install && make clean ; \
    /go/bin/mc --version

FROM scratch AS mc

ARG MC_RELEASE_VERSION
ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.title="MinIO Client" \
      org.opencontainers.image.vendor="MinIO Inc <dev@min.io>" \
      org.opencontainers.image.authors="MinIO Inc <dev@min.io>, Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.version="${MC_RELEASE_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.description="MinIO Client - Unix like utilities for object store." \
      org.opencontainers.image.documentation="https://min.io/docs/minio/linux/reference/minio-mc.html , https://github.com/minio/mc" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/minio" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-minio"

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/mc /usr/bin/mc

COPY --from=build /go/src/mc/CREDITS /licenses/CREDITS
COPY --from=build /go/src/mc/LICENSE /licenses/LICENSE

ENTRYPOINT ["mc"]