FROM golang:1.17-alpine as builder

LABEL maintainer="MinIO Inc <dev@min.io>"

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on

ARG MINIO_RELEASE_VERSION

RUN  \
     apk add --no-cache git curl && \
     RELEASE=$(curl -s https://api.github.com/repos/minio/minio/releases/latest | grep 'tag_name' | cut -d\" -f4) && \
     MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION:-${RELEASE}} && \
     echo "MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION}" && \
     export MINIO_RELEASE="RELEASE" && \
     git clone https://github.com/minio/minio && cd minio && \
     VERSION=$(echo ${MINIO_RELEASE_VERSION} | sed 's#RELEASE\.\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\)T\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\)Z#\1-\2-\3T\4:\5:\6Z#') && \
     git checkout ${MINIO_RELEASE_VERSION} && go install -v -ldflags "$(go run buildscripts/gen-ldflags.go ${VERSION})"

FROM alpine:3.13

ARG VCS_REF
ARG BUILD_DATE
ARG MINIO_RELEASE_VERSION="RELEASE"

LABEL org.opencontainers.image.title="MinIO" \
     org.opencontainers.image.vendor="MinIO Inc <dev@min.io>" \
     org.opencontainers.image.authors="MinIO Inc <dev@min.io>, Tobias Hargesheimer <docker@ison.ws>" \
     org.opencontainers.image.version="${MINIO_RELEASE_VERSION}" \
     org.opencontainers.image.created="${BUILD_DATE}" \
     org.opencontainers.image.revision="${VCS_REF}" \
     org.opencontainers.image.description="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
     org.opencontainers.image.licenses="Apache-2.0" \
     org.opencontainers.image.url="https://hub.docker.com/r/tobi312/minio" \
     org.opencontainers.image.source="https://github.com/Tob1asDocker/minio"

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env

EXPOSE 9000

COPY --from=builder /go/bin/minio /usr/bin/minio
COPY --from=builder /go/minio/CREDITS /licenses/CREDITS
COPY --from=builder /go/minio/LICENSE /licenses/LICENSE
COPY --from=builder /go/minio/dockerscripts/docker-entrypoint.sh /usr/bin/
#COPY docker-entrypoint.sh /usr/bin/

RUN  \
     apk add --no-cache curl ca-certificates shadow util-linux && \
     chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
