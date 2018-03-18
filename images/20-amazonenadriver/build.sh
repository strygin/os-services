#!/bin/sh
set -ex

KERNEL_VERSION=$(uname -r)
echo "aws-ena for ${KERNEL_VERSION}"

STAMP=/lib/modules/${KERNEL_VERSION}/.aws-ena-done

if [ -e $STAMP ]; then
    modprobe ena

    echo "aws-ena for ${KERNEL_VERSION} already installed. Delete $STAMP to reinstall"
    exit 0
fi

ros service enable kernel-source
ros service up kernel-source --foreground

ENA_BUILD_DIR=/dist/aws-ena

echo "Compiling ena driver"
cd ${ENA_BUILD_DIR}/kernel/linux/ena/
make -j$(nproc)
mkdir -p /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/amazon/ena/
cp ena.ko /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/amazon/ena/
depmod

cd /dist
touch $STAMP
echo "aws-ena for ${KERNEL_VERSION} installed. Delete $STAMP to reinstall"

echo "Cleaning ena code"
rm -rf ${ENA_BUILD_DIR}

echo "Cleaning kernel source"
ros service disable kernel-source
rm -rf /lib/modules/${KERNEL_VERSION}/build
rm -rf /usr/src/linux
rm -f /lib/modules/${KERNEL_VERSION}/.kernel-source-done
