#!/bin/bash
set +ex

KERNEL_VERSION=$(uname -r)
echo "Kernel source ${KERNEL_VERSION}"

mkdir -p /lib/modules/${KERNEL_VERSION}
STAMP=/lib/modules/${KERNEL_VERSION}/.kernel-source-done

if [ -e $STAMP ]; then
    echo "Kernel source ${KERNEL_VERSION} is already installed. Delete $STAMP to reinstall"
    exit 0
fi

mkdir -p /usr/src/linux
echo "Fetching and extracting source..."
curl -SsL https://github.com/rancher/os-kernel/releases/download/v${KERNEL_VERSION}/linux-${KERNEL_VERSION}-src.tgz | tar -zx --strip-components=1 -C /usr/src/linux
ln -s /usr/src/linux /lib/modules/${KERNEL_VERSION}/build
cd /usr/src/linux
zcat /proc/config.gz > ./.config

echo "make module_prepare"
make modules_prepare -j$(nproc)

touch $STAMP
echo "Kernel source ${KERNEL_VERSION} is installed. Delete $STAMP to reinstall"
