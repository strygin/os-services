FROM gcc:7.3
# FROM arm64=arm64v8/gcc:7.3 arm=arm32v7/gcc:7.3

LABEL maintainer="Dmitry Strygin <strygin@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    bc \
    curl \
    build-essential \
    autoconf \
    libncurses5-dev \
    kmod \
    pkg-config \
    software-properties-common \
    libtool \
    libelf-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /dist
COPY build.sh /dist/

CMD ["/dist/build.sh"]

ENTRYPOINT ["/usr/bin/ros", "entrypoint"]
