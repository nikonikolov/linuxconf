#!/bin/bash

# Get DRIVER_VERSION
if [ -z "$DRIVER_VERSION" ]; then
  echo "DRIVER_VERSION variable not set. You must provide a driver version, e.g. "
  echo "DRIVER_VERSION=410.78 $0"
  exit
fi

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# SLACKBUILDS_ROOT=$(dirname $SCRIPT_ROOT)
SLACKBUILDS_ROOT=$SCRIPT_ROOT/packages/slackbuilds
NVIDIADIR=$SCRIPT_ROOT/v${DRIVER_VERSION}
# KERNEL=$(uname -r)
KERNEL=$(ls /var/lib/pkgtools/packages | grep -i kernel-generic | grep -oP '\d+\.\d+\.\d+')

if [ ! -d $SLACKBUILDS_ROOT ]; then
  echo "Expected git clone of slackbuilds.org at $SLACKBUILDS_ROOT is missing"
  echo "Please clone slackbuilds.org (see source code for details)"
  # mkdir -p packages/slackbuilds && cd packages/slackbuilds
  # git init
  # git remote add -f origin git://git.slackbuilds.org/slackbuilds.git
  # git config core.sparseCheckout true
  # echo "system/nvidia-driver" >> .git/info/sparse-checkout
  # echo "system/nvidia-kernel" >> .git/info/sparse-checkout
  # git pull origin 15.0
  # git checkout 15.0
  echo "Exiting"
  exit
fi

# Make sure NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run is downloaded
# if [ ! -f $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run ]; then
#   echo "You need to download NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run to proceed"
#   echo "Place it in $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run"
#   exit
# fi

mkdir -p $NVIDIADIR

# Download the source files
cd $NVIDIADIR
if [ ! -f NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run ]; then
  wget https://download.nvidia.com/XFree86/Linux-x86_64/${DRIVER_VERSION}/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run
fi
if [ ! -f nvidia-installer-${DRIVER_VERSION}.tar.bz2 ]; then
  wget http://http.download.nvidia.com/XFree86/nvidia-installer/nvidia-installer-${DRIVER_VERSION}.tar.bz2
fi
if [ ! -f nvidia-modprobe-${DRIVER_VERSION}.tar.bz2 ]; then
  wget http://http.download.nvidia.com/XFree86/nvidia-modprobe/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2
fi
if [ ! -f nvidia-settings-${DRIVER_VERSION}.tar.bz2 ]; then
  wget http://http.download.nvidia.com/XFree86/nvidia-settings/nvidia-settings-${DRIVER_VERSION}.tar.bz2
fi
if [ ! -f nvidia-xconfig-${DRIVER_VERSION}.tar.bz2 ]; then
  wget http://http.download.nvidia.com/XFree86/nvidia-xconfig/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2
fi
# wget http://http.download.nvidia.com/XFree86/nvidia-persistenced/nvidia-persistenced-${DRIVER_VERSION}.tar.bz2
cd -

# Remove old symlinks
rm -f $SLACKBUILDS_ROOT/system/nvidia-kernel/NVIDIA-Linux-x86_64-*.run
rm -f $SLACKBUILDS_ROOT/system/nvidia-driver/NVIDIA-Linux-x86_64-*.run
rm -f $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-installer-*.tar.bz2
rm -f $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-modprobe-*.tar.bz2
rm -f $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-settings-*.tar.bz2
rm -f $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-xconfig-*.tar.bz2

# Create new symlinks
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run $SLACKBUILDS_ROOT/system/nvidia-kernel/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run
ln -s $NVIDIADIR/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run $SLACKBUILDS_ROOT/system/nvidia-driver/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run
ln -s $NVIDIADIR/nvidia-installer-${DRIVER_VERSION}.tar.bz2 $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-installer-${DRIVER_VERSION}.tar.bz2
ln -s $NVIDIADIR/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2 $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-modprobe-${DRIVER_VERSION}.tar.bz2
ln -s $NVIDIADIR/nvidia-settings-${DRIVER_VERSION}.tar.bz2 $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-settings-${DRIVER_VERSION}.tar.bz2
ln -s $NVIDIADIR/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2 $SLACKBUILDS_ROOT/system/nvidia-driver/nvidia-xconfig-${DRIVER_VERSION}.tar.bz2

# # Compile nvidia-kernel and nvidia-driver
cd $SLACKBUILDS_ROOT/system/nvidia-kernel
sudo VERSION=$DRIVER_VERSION KERNEL=$KERNEL OPEN=yes ./nvidia-kernel.SlackBuild
cd -
cd $SLACKBUILDS_ROOT/system/nvidia-driver
sudo VERSION=$DRIVER_VERSION WINE=no ./nvidia-driver.SlackBuild
cd -

# Move the new packages to pkg64 dir
mkdir -p $SLACKBUILDS_ROOT/pkg64/kernel-$KERNEL/
sudo mv /tmp/nvidia-kernel-open-${DRIVER_VERSION}_$KERNEL-x86_64-1_SBo.tgz $SLACKBUILDS_ROOT/pkg64/kernel-$KERNEL/
sudo mv /tmp/nvidia-driver-${DRIVER_VERSION}-x86_64-1_SBo.tgz $SLACKBUILDS_ROOT/pkg64/kernel-$KERNEL/

echo "SUCCESS"
echo "You now need to install the pacakges manually"
echo "$SLACKBUILDS_ROOT/pkg64/kernel-$KERNEL/nvidia-kernel-open-${DRIVER_VERSION}_$KERNEL-x86_64-1_SBo.tgz"
echo "$SLACKBUILDS_ROOT/pkg64/kernel-$KERNEL/nvidia-driver-${DRIVER_VERSION}-x86_64-1_SBo.tgz"
