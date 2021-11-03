FROM golang:1.17-alpine as builder

LABEL maintainer="MinIO Inc <dev@min.io>"

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on

RUN  \
     apk add --no-cache git && \
     git clone https://github.com/minio/minio && cd minio && \
     git checkout master && go install -v -ldflags "$(go run buildscripts/gen-ldflags.go)"

FROM alpine:3.13

ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.title="MinIO" \
     org.opencontainers.image.vendor="MinIO Inc <dev@min.io>" \
     org.opencontainers.image.authors="MinIO Inc <dev@min.io>, Tobias Hargesheimer <docker@ison.ws>" \
     org.opencontainers.image.version="development" \
     org.opencontainers.image.created="${BUILD_DATE}" \
     org.opencontainers.image.revision="${VCS_REF}" \
     org.opencontainers.image.description="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
     org.opencontainers.image.licenses="AGPL-3.0" \
     org.opencontainers.image.url="https://hub.docker.com/r/tobi312/minio" \
     org.opencontainers.image.source="https://github.com/Tob1asDocker/minio"

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env \
    PATH=$PATH:/opt/bin

COPY --from=builder /go/bin/minio /opt/bin/minio
COPY --from=builder /go/minio/CREDITS /licenses/CREDITS
COPY --from=builder /go/minio/LICENSE /licenses/LICENSE
COPY --from=builder /go/minio/dockerscripts/docker-entrypoint.sh /usr/bin/
#COPY docker-entrypoint.sh /usr/bin/

RUN  \
     apk add --no-cache curl ca-certificates shadow util-linux && \
     chmod +x /usr/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
