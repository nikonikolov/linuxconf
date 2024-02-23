#!/bin/bash

KERNEL=$(ls /var/lib/pkgtools/packages | grep -i kernel-huge | grep -oP '\d+\.\d+\.\d+')

# Generate initrd
echo "Generating initrd for kernel $KERNEL"
$(sudo /usr/share/mkinitrd/mkinitrd_command_generator.sh -k $KERNEL | sed '/^#/d')

# Update grub config
echo "Updating grub configuration"
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Update bbswitch
echo "Updating bbswitch"
cd /home/niko/Packages/bumblebee/bumblebee/bbswitch
KENREL=$KERNEL ./bbswitch.SlackBuild
sudo upgradepkg --reinstall --install-new /tmp/bbswitch-*$KERNEL-*.txz

echo "Updating nvidia-kernel"
cd /home/niko/Packages/bumblebee/bumblebee/nvidia-kernel
KENREL=$KERNEL ./nvidia-kernel.SlackBuild
sudo upgradepkg --reinstall --install-new /tmp/nvidia-kernel-*$KERNEL-*.txz
