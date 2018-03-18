#!/bin/sh
set -ex

NVIDIA_DRIVER_VERSION=${NVIDIA_DRIVER_VERSION:-384.111}

KERNEL_VERSION=$(uname -r)

echo "Nvidia drivers ${NVIDIA_DRIVER_VERSION} for ${KERNEL_VERSION}"

STAMP=/lib/modules/${KERNEL_VERSION}/.nvidia-drivers-done

if [ -e $STAMP ]; then
    echo "Nvidia drivers for ${KERNEL_VERSION} are already installed. Delete $STAMP to reinstall"
    exit 0
fi

ros service enable kernel-source
ros service up kernel-source --foreground

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

echo "Cleaning kernel source"
ros service disable kernel-source
rm -rf /lib/modules/${KERNEL_VERSION}/build
rm -rf /usr/src/linux
rm -f /lib/modules/${KERNEL_VERSION}/.kernel-source-done
