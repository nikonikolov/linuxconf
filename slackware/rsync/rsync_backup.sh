#!/bin/bash
sudo rsync -avAXh --delete --exclude-from 'rsync_exclude.txt' --progress / /run/media/niko/HD-PCFU3/system_backup
