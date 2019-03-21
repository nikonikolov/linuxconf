#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UBUNTU_BACKUP_DIR="$DIRPATH/configs"
source $DIRPATH/../common/helpers.sh
source $DIRPATH/functions.sh

# Get the OS version number
UBUNTU_VERSION=$(lsb_release -sr | cut -f 1 -d ".")

# ------------- Append ~/.bashrc with custom configs -------------
setupbashrc

# ------------- Configure vim and tmux -------------
install_vim
install_tmux
configure_vim
configure_tmux $UBUNTU_BACKUP_DIR

# ------------- Install sublime text 3 -------------
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install -y sublime-text
# Configure shortcuts and options
configure_sublime $UBUNTU_BACKUP_DIR


# Ubuntu 18.04 and higher
if [ "$UBUNTU_VERSION" -gt "16" ]; then
  
  # Install gnome-tweak-tool - needed for number of workspaces
  sudo apt update
  sudo apt install -y gnome-tweak-tool

  # Install workspace grid extension
  # TODO: Check the code when you get to work
  # See:
  # - https://linuxconfig.org/how-to-install-gnome-shell-extensions-from-zip-file-using-command-line-on-ubuntu-18-04-bionic-beaver-linux
  # - https://extensions.gnome.org/extension/484/workspace-grid/
  # - https://github.com/zakkak/workspace-grid

  # TODO: If not working, might be <Ctrl> or <Control> instead of <Primary>
  # ------------- Window-management shortcuts -------------
  gsettings set org.gnome.desktop.wm.keybindings maximize "['<Primary>g']"
  gsettings set org.gnome.desktop.wm.keybindings close "['<Primary>q']"
  
  # NOTE: Moving windows need to be set up first
# ------------- Workspace shortcuts -------------
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Primary><Alt>Right']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Primary><Alt>Left']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Primary><Alt>Up']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Primary><Alt>Down']"

  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary>Down']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary>Up']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Primary>Left']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Primary>Right']"
  
  # ------------- Make alt-tab switch over windows from current workspace only -------------
  gsettings set org.gnome.shell.app-switcher current-workspace-only true

else
  # Install unity-tweak-tool - needed for number of workspaces
  # If not found, add this repo
  # sudo add-apt-repository ppa:freyja-dev/unity-tweak-tool-daily
  sudo apt update
  sudo apt install -y unity-tweak-tool

  # Set window shortcuts
  # ------------- Window-management shortcuts -------------
  gsettings set org.gnome.desktop.wm.keybindings maximize "['<Control>g']"
  gsettings set org.gnome.desktop.wm.keybindings close "['<Control>q']"

  # NOTE: Moving windows need to be set up first
# ------------- Workspace shortcuts -------------
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Control><Alt>Right']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Control><Alt>Left']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Control><Alt>Up']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Control><Alt>Down']"

  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Control>Down']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Control>Up']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control>Left']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control>Right']"
fi

message "[WARNING]: You must set the number of workspaces manually"
