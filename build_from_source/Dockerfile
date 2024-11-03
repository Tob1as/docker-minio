FROM golang:1.22-alpine AS base

ENV GOPATH=/go
ENV CGO_ENABLED=0

RUN apk add --no-cache bash git make perl


FROM base AS minio

ARG MINIO_RELEASE_VERSION

RUN \
    MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION:-$(wget -qO- https://api.github.com/repos/minio/minio/releases/latest | grep 'tag_name' | cut -d\" -f4)} ; \
    echo "MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION}" ; \
    export MINIO_RELEASE="${MINIO_RELEASE_VERSION%%.*}" ; \
    git clone --single-branch --branch ${MINIO_RELEASE_VERSION} https://github.com/minio/minio.git /go/src/minio ; \
    cd /go/src/minio && make build && make install && make clean ; \
    /go/bin/minio --version

FROM base AS mc

ARG MC_RELEASE_VERSION

RUN \
    MC_RELEASE_VERSION=${MC_RELEASE_VERSION:-$(wget -qO- https://api.github.com/repos/minio/mc/releases/latest | grep 'tag_name' | cut -d\" -f4)} ; \
    echo "MC_RELEASE_VERSION=${MC_RELEASE_VERSION}" ; \
    export MC_RELEASE="${MC_RELEASE_VERSION%%.*}" ; \
    git clone --single-branch --branch ${MC_RELEASE_VERSION} https://github.com/minio/mc.git /go/src/mc ; \
    cd /go/src/mc && make build && make install && make clean ; \
    /go/bin/mc --version

FROM scratch

ARG MINIO_RELEASE_VERSION
ARG MC_RELEASE_VERSION
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

COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=minio /go/bin/minio /usr/bin/minio
COPY --from=mc /go/bin/mc /usr/bin/mc
#COPY --from=static-curl /usr/local/bin/curl /usr/bin/curl

COPY --from=minio /go/src/minio/CREDITS /licenses/CREDITS
COPY --from=minio /go/src/minio/LICENSE /licenses/LICENSE
COPY --from=minio /go/src/minio/dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9000
VOLUME ["/data"]

#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]