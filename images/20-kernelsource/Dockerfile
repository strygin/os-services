FROM gcc:7.3
# FROM arm64=arm64v8/gcc:7.3

LABEL maintainer="Dmitry Strygin <strygin@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        bc \
        curl \
        kmod \
        nano \
        libelf-dev \
        libncurses5-dev \
        libssh-dev \
        pkg-config \
        software-properties-common \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /dist
COPY build.sh /dist/
WORKDIR /usr/src

CMD ["/dist/build.sh"]

ENTRYPOINT ["/usr/bin/ros", "entrypoint"]
