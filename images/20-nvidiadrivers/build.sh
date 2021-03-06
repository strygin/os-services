#!/bin/bash
set -e

NVIDIA_DRIVER_VERSION=${NVIDIA_DRIVER_VERSION:-384.111}
# A temp bug workaround -- `ros config set ...` strips trailing zeros if thing looks like a float
[[ $NVIDIA_DRIVER_VERSION == 390.3 ]] && NVIDIA_DRIVER_VERSION="390.30"

KERNEL_VERSION=$(uname -r)

echo "Nvidia drivers ${NVIDIA_DRIVER_VERSION} for ${KERNEL_VERSION}"

KERNEL_SOURCE_STAMP=/lib/modules/${KERNEL_VERSION}/.kernel-source-done
STAMP=/lib/modules/${KERNEL_VERSION}/.nvidia-drivers-done

if [ -e $STAMP ]; then
    echo "Nvidia drivers for ${KERNEL_VERSION} are already installed. Delete $STAMP to reinstall"
    exit 0
fi

if [ -e $KERNEL_SOURCE_STAMP ]; then
    CLEAN_KERNEL_SOURCE=false
else
    ros service enable kernel-source
    ros service up kernel-source --foreground
    CLEAN_KERNEL_SOURCE=true
fi

echo "Downloading Nvidia drivers"
curl http://us.download.nvidia.com/tesla/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run -Lvo nvidia.run
chmod a+x nvidia.run

echo "Environment:"
env

echo "Compiling Nvidia drivers"
./nvidia.run \
    --accept-license \
    --no-questions \
    --ui=none \
    --no-backup \
    --no-drm \
    --disable-nouveau \
    --concurrency-level=$(nproc) \
    --utility-prefix=/usr/local/nvidia \
    --opengl-prefix=/usr/local/nvidia \
    --documentation-prefix=/usr/local/nvidia \
    --x-prefix=/usr/local/nvidia \
    --kernel-source-path=/usr/src/linux

touch $STAMP
echo "Nvidia drivers ${NVIDIA_DRIVER_VERSION} for ${KERNEL_VERSION} are installed. Delete $STAMP to reinstall"

echo "Cleaning code"
rm -rf /dist

if [[ $CLEAN_KERNEL_SOURCE == true ]]; then
    echo "Cleaning kernel source"
    ros service disable kernel-source
    rm -rf /lib/modules/${KERNEL_VERSION}/build
    rm -rf /usr/src/linux
    rm -f /lib/modules/${KERNEL_VERSION}/.kernel-source-done
fi
