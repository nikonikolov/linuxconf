#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $DIRPATH/../common/helpers.sh

SYSTEM_BACKUP_DIR="$DIRPATH/configs/$HARDWARE_ID"  # The backup directory for THIS MACHINE!
MAIN_BACKUP_DIR="$DIRPATH/configs/$MAIN_HARDWARE_ID"  # The default 'source-of-truth' backup directory for ANY machine

mkdir -p $SYSTEM_BACKUP_DIR

if [ "$HARDWARE_ID" == "$MAIN_HARDWARE_ID" ]; then
    IS_MAIN="true"
else
    IS_MAIN="false"
    SYMLINK_PATH=$(realpath --relative-to $SYSTEM_BACKUP_DIR $MAIN_BACKUP_DIR)
fi

# sublime key shortcuts
mkdir -p $SYSTEM_BACKUP_DIR/sublime/
if [ "$IS_MAIN" = "true" ]; then
  safecp "$HOME/.config/sublime-text/Packages/User/Default (Linux).sublime-keymap" $SYSTEM_BACKUP_DIR/sublime/
  safecp "$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings" $SYSTEM_BACKUP_DIR/sublime/
  safecp "$HOME/.config/sublime-text/Packages/User/Python.sublime-settings" $SYSTEM_BACKUP_DIR/sublime/
  safecp "$HOME/.config/sublime-text/Packages/User/PythonBreakpoints.sublime-settings" $SYSTEM_BACKUP_DIR/sublime/
  safecp "$HOME/.config/sublime-text/Packages/User/XML.sublime-settings" $SYSTEM_BACKUP_DIR/sublime/
else
  ln -sf "$MAIN_BACKUP_DIR/sublime/Default (Linux).sublime-keymap" "$SYSTEM_BACKUP_DIR/sublime/Default (Linux).sublime-keymap"
  ln -sf "$MAIN_BACKUP_DIR/sublime/Preferences.sublime-settings" "$SYSTEM_BACKUP_DIR/sublime/Preferences.sublime-settings"
  ln -sf "$MAIN_BACKUP_DIR/sublime/Python.sublime-settings" "$SYSTEM_BACKUP_DIR/sublime/Python.sublime-settings"
  ln -sf "$MAIN_BACKUP_DIR/sublime/PythonBreakpoints.sublime-settings" "$SYSTEM_BACKUP_DIR/sublime/PythonBreakpoints.sublime-settings"
  ln -sf "$MAIN_BACKUP_DIR/sublime/XML.sublime-settings" "$SYSTEM_BACKUP_DIR/sublime/XML.sublime-settings"
fi


if [ "$IS_MAIN" = "true" ]; then
  # redshift
  safecp $HOME/.config/redshift.conf $SYSTEM_BACKUP_DIR

  # .bashrc
  safecp $HOME/.bashrc $SYSTEM_BACKUP_DIR/bashrc.txt

  # .bash_profile
  safecp $HOME/.bash_profile $SYSTEM_BACKUP_DIR/bash_profile.txt

  # .vimrc
  safecp $HOME/.vimrc $SYSTEM_BACKUP_DIR/vimrc.txt

  # .nvim
  safecp $HOME/.config/nvim/init.lua $SYSTEM_BACKUP_DIR/nvim-init.lua

  # .tmux.conf
  safecp $HOME/.tmux.conf $SYSTEM_BACKUP_DIR/tmux.conf

  # chromium
  safecp /etc/chromium/01-apikeys.conf $SYSTEM_BACKUP_DIR

  # konsole configuration
  mkdir -p $SYSTEM_BACKUP_DIR/konsole
  for FILE in $HOME/.local/share/konsole/*
  do
    safecp $FILE $SYSTEM_BACKUP_DIR/konsole/$(basename $FILE)
  done

  # Alienbob script for mirroring slackware sources
  safecp $HOME/SlackWare/mirrors/mirror-slackware-current.conf $SYSTEM_BACKUP_DIR
  safecp $HOME/SlackWare/mirrors/mirror-slackware-current.exclude $SYSTEM_BACKUP_DIR
  safecp $HOME/SlackWare/mirrors/mirror-slackware-current.sh $SYSTEM_BACKUP_DIR

else
  ln -sf "$SYMLINK_PATH/redshift.conf" "$SYSTEM_BACKUP_DIR/redshift.conf"
  ln -sf "$SYMLINK_PATH/bashrc.txt" "$SYSTEM_BACKUP_DIR/bashrc.txt"
  ln -sf "$SYMLINK_PATH/bash_profile.txt" "$SYSTEM_BACKUP_DIR/bash_profile.txt"
  ln -sf "$SYMLINK_PATH/vimrc.txt" "$SYSTEM_BACKUP_DIR/vimrc.txt"
  ln -sf "$SYMLINK_PATH/tmux.conf" "$SYSTEM_BACKUP_DIR/tmux.conf"
  ln -sf "$SYMLINK_PATH/01-apikeys.conf" "$SYSTEM_BACKUP_DIR/01-apikeys.conf"
  ln -sf "$SYMLINK_PATH/01-apikeys.conf" "$SYSTEM_BACKUP_DIR/01-apikeys.conf"
  ln -sf "$SYMLINK_PATH/mirror-slackware-current.conf" "$SYSTEM_BACKUP_DIR/mirror-slackware-current.conf"
  ln -sf "$SYMLINK_PATH/mirror-slackware-current.exclude" "$SYSTEM_BACKUP_DIR/mirror-slackware-current.exclude"
  ln -sf "$SYMLINK_PATH/mirror-slackware-current.sh" "$SYSTEM_BACKUP_DIR/mirror-slackware-current.sh"

  # konsole configuration
  mkdir -p $SYSTEM_BACKUP_DIR/konsole
  for FILE in $MAIN_BACKUP_DIR/konsole*
  do
    ln -sf "$SYMLINK_PATH/$(basename $FILE)" "$SYSTEM_BACKUP_DIR/$(basename $FILE)"
  done

fi

# KDE shortcuts
safecp $HOME/.config/kglobalshortcutsrc $SYSTEM_BACKUP_DIR
safecp $HOME/.config/khotkeysrc $SYSTEM_BACKUP_DIR

# default applications
safecp $HOME/.config/mimeapps.list $SYSTEM_BACKUP_DIR

# autostart applications
safecp $HOME/.config/autostart/* $SYSTEM_BACKUP_DIR/autostart/

# nvidia controller
safecp $HOME/bin/nvidia_control.sh $SYSTEM_BACKUP_DIR

# slackpkgplus
safecp /etc/slackpkg/slackpkgplus.conf $SYSTEM_BACKUP_DIR

# slackpkg blacklist and greylist - not used, but backed up for reference
safecp /etc/slackpkg/blacklist $SYSTEM_BACKUP_DIR/slackpkg-blacklist
safecp /etc/slackpkg/greylist $SYSTEM_BACKUP_DIR/slackpkg-greylist


# Libinput configuration
mkdir -p $SYSTEM_BACKUP_DIR/libinput
safecp /etc/X11/xorg.conf.d/*libinput.conf $SYSTEM_BACKUP_DIR/libinput
safecp /etc/X11/xorg.conf.d/*touchpad.conf $SYSTEM_BACKUP_DIR/libinput

for FILE in /usr/share/X11/xorg.conf.d/*libinput.conf
do
  safecp $FILE $SYSTEM_BACKUP_DIR/libinput/$(basename $FILE).system
done

xinput list > $SYSTEM_BACKUP_DIR/libinput/xinput-list.txt
xinput list-props 12 > $SYSTEM_BACKUP_DIR/libinput/xinput-list-props-12.txt
xinput list-props 13 > $SYSTEM_BACKUP_DIR/libinput/xinput-list-props-13.txt

# bumblebee
# safecp /etc/bumblebee/bumblebee.conf $SYSTEM_BACKUP_DIR

# elilo
safecp /boot/efi/EFI/Slackware/elilo/elilo.conf $SYSTEM_BACKUP_DIR

# grub
safecp /etc/default/grub $SYSTEM_BACKUP_DIR

# ld.so.conf
safecp /etc/ld.so.conf $SYSTEM_BACKUP_DIR

# rc.local and rc.local_shutdown
safecp /etc/rc.d/rc.local $SYSTEM_BACKUP_DIR
safecp /etc/rc.d/rc.local_shutdown $SYSTEM_BACKUP_DIR

# rc.modules.local
safecp /etc/rc.d/rc.modules.local $SYSTEM_BACKUP_DIR

# fstab
safecp /etc/fstab $SYSTEM_BACKUP_DIR

# blacklisted kernel modules
safecp /etc/modprobe.d/blacklist.conf $SYSTEM_BACKUP_DIR

# hosts
safecp /etc/hosts $SYSTEM_BACKUP_DIR

# elogind
safecp /etc/elogind/system-sleep/network_hook.sh $SYSTEM_BACKUP_DIR/elogind_network_hook.sh

# installed packages
ls /var/log/packages > $SYSTEM_BACKUP_DIR/packages.txt
ls /var/log/packages | grep SBo > $SYSTEM_BACKUP_DIR/packages_SBo.txt
ls /var/log/packages | grep alien > $SYSTEM_BACKUP_DIR/packages_alien.txt

# groups
groups $USER > $SYSTEM_BACKUP_DIR/groups-$USER.txt

# geoclue.conf
safecp /etc/geoclue/geoclue.conf $SYSTEM_BACKUP_DIR
