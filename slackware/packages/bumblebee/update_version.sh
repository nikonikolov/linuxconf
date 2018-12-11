#!/bin/bash

if [ $# == 0 ]; then
  echo "ERROR: You must provide a version of the driver, e.g. '410.78'"
  exit
fi

VERSION=$1

# ===================== CONFIRM READY =====================
echo -n "DID YOU DOWNLOAD NVIDIA-Linux-x86_64-$VERSION.run [y/n]?"
read ready
if [ "$ready" != "y" ]; then
  echo "Exiting"
  exit 0
else
  echo "Continuing execution"
fi
# ===================== CONFIRM READY =====================

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
NVIDIADIR=$DIRPATH/nvidia/v$VERSION
BUMBLEBEEDIR=$DIRPATH/bumblebee
# DRIVER=$(ls $NVIDIADIR/NVIDIA-Linux-x86_64-*.run)
KERNEL=$(uname -r)

# Download the extra packages
cd $NVIDIADIR
wget http://http.download.nvidia.com/XFree86/nvidia-settings/nvidia-setting-$VERSION.tar.bz2
wget http://http.download.nvidia.com/XFree86/nvidia-xconfig/nvidia-xconfig-$VERSION.tar.bz2
wget http://http.download.nvidia.com/XFree86/nvidia-modprobe/nvidia-modprobe-$VERSION.tar.bz2
cd -

# Remove old symlinks
rm -f $BUMBLEBEEDIR/nvidia-kernel/NVIDIA-Linux-x86_64-*.run
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/NVIDIA-Linux-x86_64-*.run
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-setting-*.tar.bz2
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-xconfig-*.tar.bz2
rm -f $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-modprobe-*.tar.bz2

# Create new symlinks
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-$VERSION.run $BUMBLEBEEDIR/nvidia-kernel/NVIDIA-Linux-x86_64-$VERSION.run
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-$VERSION.run $BUMBLEBEEDIR/nvidia-bumblebee/NVIDIA-Linux-x86_64-$VERSION.run
ln -s $NVIDIADIR/nvidia-setting-$VERSION.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-setting-$VERSION.tar.bz2
ln -s $NVIDIADIR/nvidia-xconfig-$VERSION.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-xconfig-$VERSION.tar.bz2
ln -s $NVIDIADIR/nvidia-modprobe-$VERSION.tar.bz2 $BUMBLEBEEDIR/nvidia-bumblebee/nvidia-modprobe-$VERSION.tar.bz2

# Compile nvidia-kernel and nvidia-bumblebee
cd $BUMBLEBEEDIR/nvidia-bumblebee
sudo ./nvidia-bumblebee.SlackBuild
cd -
cd $BUMBLEBEEDIR/nvidia-kernel
sudo ./nvidia-kernel.SlackBuild
cd -

# Move the new packages to pkg64 dir
mkdir -p $DIRPATH/pkg64/kernel-$KERNEL/
mv /tmp/nvidia-kernel-$VERSION_$KERNEL-x86_64-1_bbsb.txz $DIRPATH/pkg64/kernel-$KERNEL/
# mv /tmp/bbswitch-*_$KERNEL-x86_64-1_bbsb.txz $DIRPATH/pkg64/kernel-$KERNEL/
