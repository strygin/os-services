#!/bin/bash
set -e

KERNEL_VERSION=$(uname -r)
echo "aws-ena for ${KERNEL_VERSION}"

STAMP=/lib/modules/${KERNEL_VERSION}/.aws-ena-done
KERNEL_SOURCE_STAMP=/lib/modules/${KERNEL_VERSION}/.kernel-source-done

if [ -e $STAMP ]; then
    modprobe ena

    echo "aws-ena for ${KERNEL_VERSION} is already installed. Delete $STAMP to reinstall"
    exit 0
fi

if [ -e $KERNEL_SOURCE_STAMP ]; then
    CLEAN_KERNEL_SOURCE=false
else
    ros service enable kernel-source
    ros service up kernel-source --foreground
    CLEAN_KERNEL_SOURCE=true
fi

ENA_BUILD_DIR=/dist/aws-ena

echo "Compiling ena driver"
cd ${ENA_BUILD_DIR}/kernel/linux/ena/
make -j$(nproc)
mkdir -p /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/amazon/ena/
cp ena.ko /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/amazon/ena/
depmod

cd /dist
touch $STAMP
echo "aws-ena for ${KERNEL_VERSION} is installed. Delete $STAMP to reinstall"

echo "Cleaning ena code"
rm -rf ${ENA_BUILD_DIR}

if [[ $CLEAN_KERNEL_SOURCE == true ]]; then
    echo "Cleaning kernel source"
    ros service disable kernel-source
    rm -rf /lib/modules/${KERNEL_VERSION}/build
    rm -rf /usr/src/linux
    rm -f /lib/modules/${KERNEL_VERSION}/.kernel-source-done
fi
