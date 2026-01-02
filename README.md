# MinIO on x86_64 and ARM

>⚠️ Deprecated !  
> This repository is no longer maintained.  
As the upstream [MinIO project](https://github.com/minio/minio/commit/27742d469462e1561c776f88ca7a1f26816d69e2) has entered maintenance mode, these Docker images should not be used.

### Supported tags and respective `Dockerfile` links

-	[`latest`, `RELEASE.<date>` , `alpine`, `alpine-RELEASE.<date>` (*Dockerfile*)](https://github.com/Tob1as/docker-minio/blob/main/alpine.multiarch.release.Dockerfile)
-	[`scratch`, `scratch-RELEASE.<date>` (*Dockerfile*)](https://github.com/Tob1as/docker-minio/blob/main/scratch.multiarch.release.Dockerfile)

### What is MinIO?

MinIO is a High Performance Object Storage released under GNU Affero General Public License v3.0. It is API compatible with Amazon S3 cloud storage service. Use MinIO to build high performance infrastructure for machine learning, analytics and application data workloads.

MinIO running on baremetal hardware, Docker and Kubernetes.

> [read more](https://github.com/minio/minio/blob/master/README.md)

[![MinIO](https://raw.githubusercontent.com/minio/minio/master/.github/logo.svg?sanitize=true)](https://min.io)

### About these images:
* based on official Alpine images: [DockerHub](https://hub.docker.com/_/alpine) / [GitHub](https://github.com/alpinelinux/docker-alpine)
* build from MinIO offical [Release](https://dl.min.io/server/minio/release)

### How to use these images:

* ``` $ docker run --name minio -v $(pwd)/minio-data:/data:rw -p 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=minio" -e "MINIO_ROOT_PASSWORD=minio123" -d tobi312/minio:latest server --console-address ":9001" /data```

* Environment Variables:  
  * `MINIO_ROOT_USER` (set user)
  * `MINIO_ROOT_PASSWORD` (set password)
  * optional: user/group in container instead root: 
    * `MINIO_USERNAME` and `MINIO_GROUPNAME` (set user and group name, example `minio`)
    * `MINIO_UID` and `MINIO_GID` (set ID for user and group, example `1000`)
  * optional: MinIO Console behind a load balancer, proxy or k8s ingress ([*](https://github.com/minio/minio#test-using-minio-console))
    * `MINIO_SERVER_URL`
    * `MINIO_BROWSER_REDIRECT_URL`

More Information see official MinIO [Documentation](https://github.com/minio/minio#readme) !

#### Docker-Compose

```yaml
version: "2.4"
services:

  minio:
    image: tobi312/minio:latest
    container_name: minio
    #restart: unless-stopped
    ports:
      - "9000:9000" # Buckets
      - "9001:9001" # Console
    volumes:
      - ./minio-data:/data:rw
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123
    command:  ["server", "--address", ":9000", "--console-address", ":9001", "/data"]
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:9000/minio/health/live"]
      interval: 60s
      timeout: 10s
      retries: 3
```  

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/minio/)
* [GitHub](https://github.com/Tob1as/docker-minio)
