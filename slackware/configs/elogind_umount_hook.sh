#!/bin/bash
case $1/$2 in
  pre/*)
    # Put here any commands expected to be run when suspending or hibernating.
    pkill -9 sshfs || true
    for MOUNTPOINT in $(findmnt -nl -t fuse.sshfs | awk '{print $1}'); do fusermount3 -u -z $MOUNTPOINT; done
    nmcli connection down WayveVPN || true
    ;;
  post/*)
    # Put here any commands expected to be run when resuming from suspension or thawing from hibernation.
    ;;
esac
