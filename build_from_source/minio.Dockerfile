FROM golang:1.22-alpine AS build

ARG MINIO_RELEASE_VERSION

ENV GOPATH=/go
ENV CGO_ENABLED=0

RUN \
    apk add --no-cache bash git make perl; \
    MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION:-$(wget -qO- https://api.github.com/repos/minio/minio/releases/latest | grep 'tag_name' | cut -d\" -f4)} ; \
    echo "MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION}" ; \
    export MINIO_RELEASE="${MINIO_RELEASE_VERSION%%.*}" ; \
    git clone --single-branch --branch ${MINIO_RELEASE_VERSION} https://github.com/minio/minio.git /go/src/minio ; \
    cd /go/src/minio && make build && make install && make clean ; \
    /go/bin/minio --version

FROM scratch AS minio

ARG MINIO_RELEASE_VERSION
#ARG MC_RELEASE_VERSION
ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.title="MinIO" \
      org.opencontainers.image.vendor="MinIO Inc <dev@min.io>" \
      org.opencontainers.image.authors="MinIO Inc <dev@min.io>, Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.version="${MINIO_RELEASE_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.description="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
      org.opencontainers.image.documentation="https://min.io/docs/minio/container/index.html , https://github.com/minio/minio" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/minio" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-minio"

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env \
    MC_CONFIG_DIR=/tmp/.mc

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/minio /usr/bin/minio
#COPY --from=build /go/bin/mc /usr/bin/mc
#COPY --from=docker.io/tobi312/tools:static-curl /usr/bin/curl /usr/bin/curl

COPY --from=build /go/src/minio/CREDITS /licenses/CREDITS
COPY --from=build /go/src/minio/LICENSE /licenses/LICENSE
COPY --from=build /go/src/minio/dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9000
VOLUME ["/data"]

#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]