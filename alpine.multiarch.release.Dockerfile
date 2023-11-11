FROM alpine:latest

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
      org.opencontainers.image.licenses="AGPL-3.0" \
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

RUN \
   set -ex && \
   apk add --no-cache curl ca-certificates shadow util-linux minisign && \
   ## TARGETARCH ##
	# https://en.wikipedia.org/wiki/Uname
   ARCH=`uname -m` && \
	echo "ARCH=$ARCH" && \
   if [ "$ARCH" == "x86_64" ]; then \
      echo "x86_64 (amd64)" && \
      TARGETARCH="amd64"; \
   elif [ "$ARCH" == "amd64" ]; then \
      echo "amd64" && \
      TARGETARCH="amd64"; \
   elif [ "$ARCH" == "arm64" ]; then \
      echo "arm64" && \
      TARGETARCH="arm64"; \
   elif [ "$ARCH" == "aarch64" ]; then \
      echo "aarch64 (arm64)" && \
      TARGETARCH="arm64"; \
   elif [ "$ARCH" == "armv7l" ]; then \
      echo "armv7l (arm)" && \
      TARGETARCH="arm"; \
   elif [ "$ARCH" == "armv6l" ]; then \
      echo "armv6l (arm)" && \
      TARGETARCH="arm"; \
   elif [ "$ARCH" == "armhf" ]; then \
      echo "armhf (arm)" && \
      TARGETARCH="arm"; \
   else \
      echo "unknown arch" && \
      exit 1; \
   fi && \ 
   export TARGETARCH=$TARGETARCH && \
   ## GET MINIO_RELEASE_VERSION ##
   MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION:-$(curl -s https://api.github.com/repos/minio/minio/releases/latest | grep 'tag_name' | cut -d\" -f4)} && \
   echo "MINIO_RELEASE_VERSION=${MINIO_RELEASE_VERSION}" && \
   ## Download minio binary and signature file ##
   curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${MINIO_RELEASE_VERSION} -o /usr/bin/minio && \
   curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${MINIO_RELEASE_VERSION}.minisig -o /tmp/minio.minisig && \
   chmod +x /usr/bin/minio && \
   ## GET MC_RELEASE_VERSION ##
   MC_RELEASE_VERSION=${MC_RELEASE_VERSION:-$(curl -s https://api.github.com/repos/minio/mc/releases/latest | grep 'tag_name' | cut -d\" -f4)} && \
   echo "MC_RELEASE_VERSION=${MC_RELEASE_VERSION}" && \
   ## Download mc binary and signature file ##
   curl -s -q https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc.${MC_RELEASE_VERSION} -o /usr/bin/mc && \
   curl -s -q https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc.${MC_RELEASE_VERSION}.minisig -o /tmp/mc.minisig && \
   chmod +x /usr/bin/mc && \
   ## Verify binary signature using public key ##
   minisign -Vqm /usr/bin/minio -x /tmp/minio.minisig -P ${MINIO_UPDATE_MINISIGN_PUBKEY} && \
   minisign -Vqm /usr/bin/mc -x /tmp/mc.minisig -P ${MINIO_UPDATE_MINISIGN_PUBKEY} && \
   ## Download minio cerdits, license and docker-entrypoint ##
   mkdir /licenses && \
   curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_RELEASE_VERSION}/CREDITS -o /licenses/CREDITS && \
   curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_RELEASE_VERSION}/LICENSE -o /licenses/LICENSE && \
   curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_RELEASE_VERSION}/dockerscripts/docker-entrypoint.sh -o /usr/bin/docker-entrypoint.sh && \
   chmod +x /usr/bin/docker-entrypoint.sh
	
EXPOSE 9000
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]