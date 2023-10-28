#!/bin/bash
case $1/$2 in
  pre/*)
    # Put here any commands expected to be run when suspending or hibernating.
    pkill -9 sshfs || true
    # Unmount any remote drives
    for MOUNTPOINT in $(findmnt -nl -t fuse.sshfs | awk '{print $1}'); do fusermount3 -u -z $MOUNTPOINT; done
    # Disconnect from VPN
    nmcli connection down WayveVPN || true
    # Unload network kernel module - often causes trouble
    sudo modprobe -r brcmfmac || true
    ;;
  post/*)
    # Put here any commands expected to be run when resuming from suspension or thawing from hibernation.
    # Load network kernel module
    sudo modprobe brcmfmac || true
    sleep 1
    # Restart the bluetooth, it usually breaks after the kernel module has been reloaded
    sudo /etc/rc.d/rc.bluetooth restart || true
    ;;
esac
