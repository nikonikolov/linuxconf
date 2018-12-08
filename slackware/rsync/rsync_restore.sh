#!/bin/bash
sudo rsync -aAXh --delete --exclude-from 'rsync_exclude.txt' --progress /disk/system_backup /mnt
