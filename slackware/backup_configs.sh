#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SLACK_BACKUP_DIR="$DIRPATH/configs"
source $DIRPATH/../common/helpers.sh

# sublime key shortcuts
safecp "$HOME/.config/sublime-text/Packages/User/Default (Linux).sublime-keymap" $SLACK_BACKUP_DIR
safecp "$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings" $SLACK_BACKUP_DIR
safecp "$HOME/.config/sublime-text/Packages/User/Python.sublime-settings" $SLACK_BACKUP_DIR
safecp "$HOME/.config/sublime-text/Packages/User/PythonBreakpoints.sublime-settings" $SLACK_BACKUP_DIR
safecp "$HOME/.config/sublime-text/Packages/User/XML.sublime-settings" $SLACK_BACKUP_DIR

# slackpkgplus
safecp /etc/slackpkg/slackpkgplus.conf $SLACK_BACKUP_DIR

# redshift
safecp $HOME/.config/redshift.conf $SLACK_BACKUP_DIR

# .bashrc
safecp $HOME/.bashrc $SLACK_BACKUP_DIR/bashrc.txt

# .bash_profile
safecp $HOME/.bash_profile $SLACK_BACKUP_DIR/bash_profile.txt

# .vimrc
safecp $HOME/.vimrc $SLACK_BACKUP_DIR/vimrc.txt

# .tmux.conf
safecp $HOME/.tmux.conf $SLACK_BACKUP_DIR/tmux.conf

# Mutt
# safecp $HOME/.mutt/muttrc $SLACK_BACKUP_DIR/mutt.txt

# nvidia controller
safecp $HOME/bin/nvidia_control.sh $SLACK_BACKUP_DIR

# KDE shortcuts
safecp $HOME/.config/kglobalshortcutsrc $SLACK_BACKUP_DIR
safecp $HOME/.config/khotkeysrc $SLACK_BACKUP_DIR

# konsole configuration
for FILE in $HOME/.local/share/konsole/*
do
  safecp $FILE $SLACK_BACKUP_DIR/konsole/$(basename $FILE)
done

# Libinput configuration
safecp /etc/X11/xorg.conf.d/*libinput.conf $SLACK_BACKUP_DIR
safecp /etc/X11/xorg.conf.d/*touchpad.conf $SLACK_BACKUP_DIR
for FILE in /usr/share/X11/xorg.conf.d/*libinput.conf
do
  safecp $FILE $SLACK_BACKUP_DIR/$(basename $FILE).system
done
xinput list > $SLACK_BACKUP_DIR/xinput-list.txt
xinput list-props 12 > $SLACK_BACKUP_DIR/xinput-list-props-12.txt
xinput list-props 13 > $SLACK_BACKUP_DIR/xinput-list-props-13.txt

# bumblebee
safecp /etc/bumblebee/bumblebee.conf $SLACK_BACKUP_DIR

# elilo
# safecp /boot/efi/EFI/Slackware/elilo.conf $SLACK_BACKUP_DIR

# grub
safecp /etc/default/grub $SLACK_BACKUP_DIR

# ld.so.conf
safecp /etc/ld.so.conf $SLACK_BACKUP_DIR

# rc.local and rc.local_shutdown
safecp /etc/rc.d/rc.local $SLACK_BACKUP_DIR
safecp /etc/rc.d/rc.local_shutdown $SLACK_BACKUP_DIR

# rc.modules.local
safecp /etc/rc.d/rc.modules.local $SLACK_BACKUP_DIR

# fstab
safecp /etc/fstab $SLACK_BACKUP_DIR

# blacklisted kernel modules
safecp /etc/modprobe.d/blacklist.conf $SLACK_BACKUP_DIR

# hosts
safecp /etc/hosts $SLACK_BACKUP_DIR

# elogind
safecp /etc/elogind/system-sleep/network_hook.sh $SLACK_BACKUP_DIR/elogind_network_hook.sh

# installed packages
ls /var/log/packages > $SLACK_BACKUP_DIR/packages.txt
ls /var/log/packages | grep SBo > $SLACK_BACKUP_DIR/packages_SBo.txt
ls /var/log/packages | grep alien > $SLACK_BACKUP_DIR/packages_alien.txt

# groups
groups $USER > $SLACK_BACKUP_DIR/groups-$USER.txt

# chromium 
safecp /etc/chromium/01-apikeys.conf $SLACK_BACKUP_DIR

# Alienbob script for mirroring slackware sources
safecp $HOME/SlackWare/mirrors/mirror-slackware-current.conf $SLACK_BACKUP_DIR
safecp $HOME/SlackWare/mirrors/mirror-slackware-current.exclude $SLACK_BACKUP_DIR
safecp $HOME/SlackWare/mirrors/mirror-slackware-current.sh $SLACK_BACKUP_DIR

# default applications
safecp $HOME/.config/mimeapps.list $SLACK_BACKUP_DIR

# geoclue.conf
safecp /etc/geoclue/geoclue.conf $SLACK_BACKUP_DIR

# slackpkg blacklist and greylist - not used, but backed up for reference
safecp /etc/slackpkg/blacklist $SLACK_BACKUP_DIR/slackpkg-blacklist
safecp /etc/slackpkg/greylist $SLACK_BACKUP_DIR/slackpkg-greylist
