FROM gcc:7.3
# FROM arm64=arm64v8/gcc:7.3 arm=arm32v7/gcc:7.3

LABEL maintainer="Dmitry Strygin <strygin@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

ARG ENA_VERSION=1.5.1
ENV ENA_VERSION=${ENA_VERSION}

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    curl \
    build-essential \
    autoconf \
    kmod \
    libtool \
    libelf-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /dist
COPY build.sh /dist/

RUN mkdir -p /dist/aws-ena && \
    curl -SsL https://github.com/amzn/amzn-drivers/archive/ena_linux_${ENA_VERSION}.tar.gz | tar zx -C /dist/aws-ena --strip-components=1

COPY build.sh /dist/

CMD ["/dist/build.sh"]

ENTRYPOINT ["/usr/bin/ros", "entrypoint"]
