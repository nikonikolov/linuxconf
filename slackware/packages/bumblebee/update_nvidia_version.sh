#!/bin/bash

# Get DRIVER_VERSION
if [ -z "$DRIVER_VERSION" ]; then
  echo "DRIVER_VERSION variable not set. You must provide a driver version, e.g. "
  echo "DRIVER_VERSION=410.78 $0"
  exit
fi

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
NVIDIADIR=$DIRPATH/nvidia/v${DRIVER_VERSION}
BUMBLEBEEDIR=$DIRPATH/bumblebee
KERNEL=$(uname -r)

# Make sure NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run is downloaded
if [ ! -f $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run ]; then
  echo "You need to download NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run to proceed"
  echo "Place it in $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run"
  exit
fi

# Download the extra packages
cd $NVIDIADIR
# wget http://http.download.nvidia.com/XFree86/nvidia-installer/nvidia-installer-${DRIVER_VERSION}.tar.bz2
wget http://http.download.nvidia.com/XFree86/nvidia-settings/nvidia-settings-${DRIVER_VERSION}.tar.bz2
wget http://http.download.nvidia.com/XFree86/nvidia-xconfig/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2
wget http://http.download.nvidia.com/XFree86/nvidia-modprobe/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2
# wget http://http.download.nvidia.com/XFree86/nvidia-persistenced/nvidia-persistenced-${DRIVER_VERSION}.tar.bz2
cd -

# Remove old symlinks
rm -f $BUMBLEBEEDIR/nvidia-kernel/NVIDIA-Linux-x86_64-*.run
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/NVIDIA-Linux-x86_64-*.run
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-settings-*.tar.bz2
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-xconfig-*.tar.bz2
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-modprobe-*.tar.bz2

# Create new symlinks
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run $BUMBLEBEEDIR/nvidia-kernel/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run $BUMBLEBEEDIR/nvidia-bumblebee/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run
ln -s $NVIDIADIR/nvidia-settings-${DRIVER_VERSION}.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-settings-${DRIVER_VERSION}.tar.bz2
ln -s $NVIDIADIR/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2
ln -s $NVIDIADIR/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2

# # Compile nvidia-kernel and nvidia-bumblebee
cd $BUMBLEBEEDIR/nvidia-bumblebee
sudo ./nvidia-bumblebee.SlackBuild
cd -
cd $BUMBLEBEEDIR/nvidia-kernel
sudo ./nvidia-kernel.SlackBuild
cd -

# Move the new packages to pkg64 dir
mkdir -p $DIRPATH/pkg64/kernel-$KERNEL/
sudo mv /tmp/nvidia-kernel-${DRIVER_VERSION}_$KERNEL-x86_64-1_bbsb.txz $DIRPATH/pkg64/kernel-$KERNEL/
sudo mv /tmp/nvidia-bumblebee-${DRIVER_VERSION}-x86_64-1_bbsb.txz $DIRPATH/pkg64/kernel-$KERNEL/

echo "SUCCESS"
echo "You now need to install the pacakges manually"
echo "$DIRPATH/pkg64/kernel-$KERNEL/nvidia-kernel-${DRIVER_VERSION}_$KERNEL-x86_64-1_bbsb.txz"
echo "$DIRPATH/pkg64/kernel-$KERNEL/nvidia-bumblebee-${DRIVER_VERSION}-x86_64-1_bbsb.txz"
