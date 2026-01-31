#!/bin/bash

# MAKE SURE TO FIRST ALLOW SUDO AND CONNECT TO THE INTERNET !!!

# ===================== CONFIRM READY =====================
echo -n "DID YOU ENABLE SUDO AND CONNECT TO THE INTERNET [y/n]?"
read ready
if [ "$ready" != "y" ]; then
  echo "Exiting"
  exit 0
else
  echo "Continuing execution"
fi
# ===================== CONFIRM READY =====================

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $DIRPATH/../common/helpers.sh

# Determine the directory where configs are stored
SLACK_HARDWARE_BACKUP_DIR="$DIRPATH/configs/$HARDWARE_ID"
if [ ! -d $SLACK_HARDWARE_BACKUP_DIR ]; then
  SLACK_HARDWARE_BACKUP_DIR="$DIRPATH/configs/$MAIN_HARDWARE_ID"
fi


mkdir -p ~/bin

# Prompt for the sudo password once
sudo -v || exit 1

# ------------------------ quotes ------------------------
message "Removing Quotes"
if [  -f /etc/profile.d/bsd-games-login-fortune.sh ]; then
  sudo chmod -x /etc/profile.d/bsd-games-login-fortune.sh
fi


# ------------------------ groups ------------------------
message "Adding to power group"
# sudo usermod -aG power niko
sudo usermod -aG power $USER


# ------------------------ git ------------------------
message "Configuring git"
git config --global user.name "nikonikolov"
git config --global user.email "niko.b.nikolov@gmail.com"
git config --global core.editor "nvim -w"


# ------------------------ bashrc and bash_profile ------------------------

message "Configuring .bashrc"
cp $SLACK_HARDWARE_BACKUP_DIR/bash_profile.txt ~/.bash_profile
cp $SLACK_HARDWARE_BACKUP_DIR/bashrc.txt ~/.bashrc

source ~/.bash_profile


# ------------------------ konsole profiles ------------------------
message "Configuring konsole profiles"

mkdir -p $HOME/.local/share/konsole/
for FILE in $HOME/.local/share/konsole/*
do
  mv $FILE "$FILE.original"
done
cp $SLACK_HARDWARE_BACKUP_DIR/konsole/* $HOME/.local/share/konsole/


# ------------------------ tmux ------------------------
configure_tmux $SLACK_HARDWARE_BACKUP_DIR


# ------------------------ vim ------------------------
# This is deprecated in favor of neovim which needs to be installed and is done in install.sh
# configure_vim $SLACK_HARDWARE_BACKUP_DIR
# sudo ln -s "/home/$USER/.vimrc" /root/.vimrc
# sudo ln -s "/home/$USER/.vim" /root/.vim
# sudo ln -s /home/niko/.vimrc /root/.vimrc
# sudo ln -s /home/niko/.vim /root/.vim


# ------------------------ swappiness ------------------------
message "Setting swappiness"
sudo sysctl -w vm.swappiness=10


# ------------------------ nvidia ------------------------
message "Adding nvidia control script"
# Add the nvidia control script so that bashrc finds it
cp $SLACK_HARDWARE_BACKUP_DIR/nvidia_control.sh ~/bin/nvidia_control.sh
chmod +x ~/bin/nvidia_control.sh


# ======================== !! NOTE !! ========================
# It is a bad idea to copy your backups of slackpkg blacklist since you might overwrite system files.
# Copying rc.local, rc.local_shutdown, etc. is OK since these are user-specific files
# ======================== !! NOTE !! ========================


# ------------------------ slackpkg blacklist ------------------------
message "Blacklisting packages in slackpkg"

sudo tee -a /etc/slackpkg/blacklist > /dev/null <<EOT

# Blacklist trustable sources:
[0-9]+_bbsb
# [0-9]+_SBo
# [0-9]+alien
# [0-9]+compat32

# Blacklist all xfce packages
xfce
# Blacklist all games in y/
bsd-games
nethack

# Make sure that nouveau driver is not automatically updated because this will overwrite the nvidia libraries
xf86-video-nouveau
# Blacklist specific packages
google-chrome
EOT

message "Greylisting packages in slackpkg"

sudo tee -a /etc/slackpkg/greylist > /dev/null <<EOT

# Make sure installed SBo packages show on upgrade (will be deselected):
[0-9]+_SBo
EOT


# ------------------------ slackpkg mirror ------------------------
LINE_NUM=$(sudo grep -n '# file://path/to/some/directory/' /etc/slackpkg/mirrors | cut -d: -f 1)
sudo sed -i "$LINE_NUM a file://home/$USER/SlackWare/mirrors/slackware64-current/" /etc/slackpkg/mirrors
# sudo sed -i "$LINE_NUM a file://home/niko/SlackWare/mirrors/slackware64-current/" /etc/slackpkg/mirrors


# ------------------------ aleinbob scripts for mirroring slackware sources ------------------------
mkdir -p $HOME/SlackWare/mirrors
cp $SLACK_HARDWARE_BACKUP_DIR/mirror-slackware-current.conf $HOME/SlackWare/mirrors/
cp $SLACK_HARDWARE_BACKUP_DIR/mirror-slackware-current.exclude $HOME/SlackWare/mirrors/
cp $SLACK_HARDWARE_BACKUP_DIR/mirror-slackware-current.sh $HOME/SlackWare/mirrors/


# ------------------------ libinput ------------------------
sudo cp $SLACK_HARDWARE_BACKUP_DIR/libinput/*-touchpad.conf /etc/X11/xorg.conf.d/
sudo cp $SLACK_HARDWARE_BACKUP_DIR/libinput/*-libinput.conf /etc/X11/xorg.conf.d/


# ------------------------ rc.local ------------------------
message "Configuring /etc/rc.d/rc.local"
sudo cp $SLACK_HARDWARE_BACKUP_DIR/rc.local /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local


# ------------------------ rc.local_shutdown ------------------------
message "Configuring /etc/rc.d/rc.local_shutdown"
sudo cp $SLACK_HARDWARE_BACKUP_DIR/rc.local_shutdown /etc/rc.d/rc.local_shutdown
sudo chmod +x /etc/rc.d/rc.local_shutdown


# ------------------------ rc.modules.local ------------------------
message "Configuring /etc/rc.d/rc.modules.local"
sudo cp $SLACK_HARDWARE_BACKUP_DIR/rc.modules.local /etc/rc.d/rc.modules.local
sudo chmod +x /etc/rc.d/rc.modules.local


# ------------------------ elogind sleep hook ------------------------
sudo mkdir -p /etc/elogind/system-sleep
sudo cp $SLACK_HARDWARE_BACKUP_DIR/elogind_network_hook.sh /etc/elogind/system-sleep/network_hook.sh
sudo chmod +x /etc/elogind/system-sleep/network_hook.sh


# ------------------------ DHCP ------------------------
message "Setting DHCP client"
sudo sed -i '/dhcp=dhcpcd/c\#dhcp=dhcpcd' /etc/NetworkManager/conf.d/00-dhcp-client.conf
sudo sed -i '/dhcp=dhclient/c\dhcp=dhclient' /etc/NetworkManager/conf.d/00-dhcp-client.conf


# ------------------------ Pipewire ------------------------
message "Configuring pipewire. Remember to reboot for changes to take effect"
sudo pipewire-enable.sh
# # Enable the pipewire autostart configuration files
# sudo mv /etc/xdg/autostart/pipewire-pulse.desktop.sample /etc/xdg/autostart/pipewire-pulse.desktop
# sudo mv /etc/xdg/autostart/pipewire.desktop.sample /etc/xdg/autostart/pipewire.desktop
# sudo mv /etc/xdg/autostart/wireplumber.desktop.sample /etc/xdg/autostart/wireplumber.desktop
# # sudo mv /etc/xdg/autostart/pipewire-media-session.desktop.sample /etc/xdg/autostart/pipewire-media-session.desktop
# # Disable pulseaudio autostart configuration file
# sudo mv /etc/xdg/autostart/pulseaudio.desktop /etc/xdg/autostart/pulseaudio.desktop.sample
# # Disable pulseaudio
# # sudo sed -i '/autospawn = yes/c\autospawn = no' /etc/pulse/client.conf
# sudo sed -i "s/autospawn = yes/autospawn = no/g" /etc/pulse/client.conf
# sudo sed -i "s/allow-autospawn-for-root = yes/allow-autospawn-for-root = no/g" /etc/pulse/client.conf

# ===============================================
# ===================== OLD =====================
# ===============================================

# message "Configuring mutt"
# mkdir -p ~/.mutt
# cp $SLACK_HARDWARE_BACKUP_DIR/mutt.txt ~/.mutt/muttrc

# message "Enabling Network Manager"
# sudo chmod +x /etc/rc.d/rc.networkmanager
# sudo /etc/rc.d/rc.networkmanager restart

# message "Disabling inet1"
# sudo chmod -x /etc/rc.d/rc.inet1 
