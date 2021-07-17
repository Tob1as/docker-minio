# MinIO on x86_64 and ARM

### Supported tags and respective `Dockerfile` links

-	[`latest`, `RELEASE.<date>` (*Dockerfile*)](https://github.com/Tob1asDocker/minio/blob/main/alpine.multiarch.git_release.Dockerfile)
-	[`development` (*Dockerfile*)](https://github.com/Tob1asDocker/minio/blob/main/alpine.multiarch.git_master.Dockerfile)

### What is MinIO?

MinIO is a High Performance Object Storage released under Apache License v2.0. It is API compatible with Amazon S3 cloud storage service. Use MinIO to build high performance infrastructure for machine learning, analytics and application data workloads.

MinIO running on baremetal hardware, Docker and Kubernetes.

> [read more](https://github.com/minio/minio/blob/master/README.md)

[![MinIO](https://raw.githubusercontent.com/minio/minio/master/.github/logo.svg?sanitize=true)](https://min.io)

### About these images:
* based on official Alpine images: [DockerHub](https://hub.docker.com/_/alpine) / [GitHub](https://github.com/alpinelinux/docker-alpine)
* build from MinIO [GIT](https://github.com/minio/minio):  
    * `development` is build from master branch
    * `latest` is build from latest release branch.

### How to use these images:

* ``` $ docker run --name minio -v $(pwd)/minio-data:/data:rw -p 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=minio" -e "MINIO_ROOT_PASSWORD=minio123" -d tobi312/minio:latest server --console-address ":9001" /data```

* Environment Variables:  
  * `MINIO_ROOT_USER` (set user)
  * `MINIO_ROOT_PASSWORD` (set password)
  * optional: user/group in container instead root: 
    * `MINIO_USERNAME` and `MINIO_GROUPNAME` (set user and group name, example `minio`)
    * `MINIO_UID` and `MINIO_GID` (set ID for user and group, example `1000`)
  * optional: MinIO Console behind a load balancer, proxy or k8s ingress ([*](https://github.com/minio/minio#test-using-minio-console))
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

#### Troubleshooting

<details>
<summary>If your container fails to start with Images that based on Alpine 3.13 or newer Debian/Ubuntu on ARM devices...</summary>
<p>

... with Raspbian/Debian 10 Buster (32 bit) then update `libseccomp2`[*](https://packages.debian.org/buster-backports/libseccomp2) to >=2.4.4 and restart the container. (Source: [1](https://docs.linuxserver.io/faq#libseccomp), [2](https://github.com/owncloud/docs/pull/3196#issue-577993147), [3](https://github.com/moby/moby/issues/40734))  
  
Example (wrong date):
```sh
$ docker run --rm --name testing -it alpine:3.13 date
Sun Jan  0 00:100:4174038  1900
```
  
Solution:
```sh
 sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
 echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
 sudo apt update
 sudo apt install -t buster-backports libseccomp2
```
</p>
</details>
  

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/minio/)
* [GitHub](https://github.com/Tob1asDocker/minio)
