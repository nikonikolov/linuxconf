#!/bin/bash

# MAKE SURE TO FIRST ALLOW SUDO AND CONNECT TO THE INTERNET !!!

# ===================== CONFIRM READY =====================
echo -n "DID YOU ENABLE SUDO, NETWORKMANAGER AND CONNECT TO THE INTERNET [y/n]?"
read ready
if [ "$ready" != "y" ]; then
  echo "Exiting"
  exit 0
else
  echo "Continuing execution"
fi
# ===================== CONFIRM READY =====================

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SLACK_BACKUP_DIR="$DIRPATH/configs"
source $DIRPATH/../common/helpers.sh

mkdir -p ~/bin

# ------------------------ quotes ------------------------
message "Removing Quotes"
sudo chmod -x /etc/profile.d/bsd-games-login-fortune.sh


# ------------------------ groups ------------------------
message "Adding to power group"
sudo usermod -aG power niko


# ------------------------ git ------------------------
message "Configuring git"
git config --global user.name "nikonikolov"
git config --global user.email "niko.b.nikolov@gmail.com"
git config --global core.editor "sublime_text -w"


# ------------------------ bashrc and bash_profile ------------------------
message "Configuring .bash_profile"
cp $SLACK_BACKUP_DIR/bash_profile.txt ~/.bash_profile
source ~/.bash_profile

message "Configuring .bashrc"
cp $SLACK_BACKUP_DIR/bashrc.txt ~/.bashrc
source ~/.bashrc


# ------------------------ tmux ------------------------
configure_tmux $SLACK_BACKUP_DIR


# ------------------------ vim ------------------------
configure_vim $SLACK_BACKUP_DIR
sudo ln -s /home/niko/.vimrc /root/.vimrc
sudo ln -s /home/niko/.vim /root/.vim


# ------------------------ swappiness ------------------------
message "Setting swappiness"
sudo sysctl -w vm.swappiness=10


# ------------------------ nvidia ------------------------
message "Adding nvidia control script"
# Add the nvidia control script so that bashrc finds it
cp $SLACK_BACKUP_DIR/nvidia_control.sh ~/bin/nvidia_control.sh
chmod +x ~/bin/nvidia_control.sh


# ======================== !! NOTE !! ========================
# It is a bad idea to copy your backups of slackpkg blacklist, rc.local, rc.local_shutdown, etc.
# since you might overwrite new contents in the system files
# ======================== !! NOTE !! ========================


# ------------------------ slackpkg blacklist ------------------------
message "Blacklisting Packages in slackpkg"
# Make sure that the following package extensions are properly 
# recognized by the system and will not be automatically removed
echo '' | sudo tee --append /etc/slackpkg/blacklist
echo '# Blacklist trustable sources:' | sudo tee --append /etc/slackpkg/blacklist
echo '[0-9]+_SBo' | sudo tee --append /etc/slackpkg/blacklist
echo '# [0-9]+alien' | sudo tee --append /etc/slackpkg/blacklist
echo '# [0-9]+compat32' | sudo tee --append /etc/slackpkg/blacklist
echo '[0-9]+_bbsb' | sudo tee --append /etc/slackpkg/blacklist

# Make sure that nouveau driver is not automatically updated
# because this will overwrite the nvidia libraries
echo '' | sudo tee --append /etc/slackpkg/blacklist
echo '# Make sure that nouveau driver is not automatically updated because this will overwrite the nvidia libraries' | sudo tee --append /etc/slackpkg/blacklist
echo 'xf86-video-nouveau' | sudo tee --append /etc/slackpkg/blacklist

echo '# Blacklist specific packages' | sudo tee --append /etc/slackpkg/blacklist
echo 'google-chrome' | sudo tee --append /etc/slackpkg/blacklist


# ------------------------ rc.local ------------------------
message "Configuring /etc/rc.d/rc.local"
sudo cp $SLACK_BACKUP_DIR/rc.local /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local

# echo "# Make bumblebeed start with the system" | sudo tee --append /etc/rc.d/rc.local
# echo "[ -x /etc/rc.d/rc.bumblebeed ] && /etc/rc.d/rc.bumblebeed start" | sudo tee --append /etc/rc.d/rc.local
# echo "" | sudo tee --append /etc/rc.d/rc.local

# echo "# Stop the nvidia card" | sudo tee --append /etc/rc.d/rc.local
# echo "[ -x /home/niko/bin/nvidia_control.sh ] && /home/niko/bin/nvidia_control.sh stop" | sudo tee --append /etc/rc.d/rc.local
# echo "" | sudo tee --append /etc/rc.d/rc.local

# echo "# Start docker daemon" | sudo tee --append /etc/rc.d/rc.local
# echo "[ -x /etc/rc.d/rc.docker ] && /etc/rc.d/rc.docker start" | sudo tee --append /etc/rc.d/rc.local
# echo "" | sudo tee --append /etc/rc.d/rc.local


# ------------------------ rc.local_shutdown ------------------------
message "Configuring /etc/rc.d/rc.local_shutdown"
sudo cp $SLACK_BACKUP_DIR/rc.local_shutdown /etc/rc.d/rc.local_shutdown
sudo chmod +x /etc/rc.d/rc.local_shutdown

# message "Making the contents of /tmp get deleted on shutdown"
# # Make the contents of /tmp get deleted on shut down
# sudo touch /etc/rc.d/rc.local_shutdown
# echo "# Delete the contents of /tmp on shutdown" | sudo tee --append /etc/rc.d/rc.local_shutdown
# echo "/usr/bin/find /tmp -mindepth 1 -maxdepth 1 -exec /bin/rm -rf {} +;" | sudo tee --append /etc/rc.d/rc.local_shutdown
# echo "" | sudo tee --append /etc/rc.d/rc.local_shutdown
# sudo chmod +x /etc/rc.d/rc.local_shutdown


# ------------------------ rc.modules.local ------------------------
message "Configuring /etc/rc.d/rc.modules.local"
sudo cp $SLACK_BACKUP_DIR/rc.modules.local /etc/rc.d/rc.modules.local
sudo chmod +x /etc/rc.d/rc.modules.local

# message "Making i8k module be automatically loaded"
# # Load the i8k kernel module for monitoring fan
# echo "/sbin/modprobe i8k force=1     # Dell hardware module" | sudo tee --append /etc/rc.d/rc.modules.local
# echo "" | sudo tee --append /etc/rc.d/rc.modules.local
# sudo chmod +x /etc/rc.d/rc.modules.local


# ------------------------ DHCP ------------------------
message "Setting DHCP client"
sudo sed -i '/dhcp=dhcpcd/c\#dhcp=dhcpcd' /etc/NetworkManager/conf.d/00-dhcp-client.conf
sudo sed -i '/dhcp=dhclient/c\dhcp=dhclient' /etc/NetworkManager/conf.d/00-dhcp-client.conf


# ===============================================
# ===================== OLD =====================
# ===============================================

# message "Configuring mutt"
# mkdir -p ~/.mutt
# cp $SLACK_BACKUP_DIR/mutt.txt ~/.mutt/muttrc

# message "Enabling Network Manager"
# sudo chmod +x /etc/rc.d/rc.networkmanager
# sudo /etc/rc.d/rc.networkmanager restart

# message "Disabling inet1"
# sudo chmod -x /etc/rc.d/rc.inet1 
