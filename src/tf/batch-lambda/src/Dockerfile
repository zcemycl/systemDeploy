FROM tensorflow/tensorflow:latest-jupyter
ENV S3FS_VERSION=1.93

RUN groupadd --gid 1000 batch
RUN useradd --uid 1000 --gid batch --shell /bin/bash --create-home batch

RUN apt-get -y update
RUN apt-get -y install \
    curl wget build-essential automake \
    libcurl4-openssl-dev libxml2-dev \
    pkg-config libssl-dev libfuse-dev parallel \
    fuse3

RUN apt -y install s3fs

# RUN wget "https://github.com/s3fs-fuse/s3fs-fuse/archive/v${S3FS_VERSION}.tar.gz" && \
#     tar -xzvf "v${S3FS_VERSION}.tar.gz" && \
#     cd "s3fs-fuse-${S3FS_VERSION}" && \
#     ./autogen.sh && \
#     ./configure --prefix=/usr && \
#     make && \
#     make install && \
#     rm -rf "s3fs-fuse-${S3FS_VERSION}" "${S3FS_VERSION}.tar.gz"

RUN mkdir /data

RUN chown -R 1000:1000 /data

COPY entrypoint.sh /entrypoint.sh
COPY main.py /main.py

ENTRYPOINT ["/entrypoint.sh", "python", "/main.py"]
