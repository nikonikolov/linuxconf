#!/bin/bash

# ======================== !! NOTE !! ========================
# Rule of thumb is to always recompile SBo packages. This is the principle of Slackware.
# If you use a binary, you might easily miss important dependencies.
# Packages which you normally use from alien, such as chromium, vlc are OK to come in binary
# ======================== !! NOTE !! ========================

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# ===================== CONFIRM READY =====================
echo -n "DID YOU ENABLE SUDO AND CONNECT TO THE INTERNET [y/n]?"
read ready
if [ "$ready" != "y" ]; then
  echo "Exiting"
  exit 0
else
  echo "Continuing execution"
fi
# ===================== HELPER VARIABLES =====================

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $DIRPATH/../common/helpers.sh

SLACK_PKG_DIR="$DIRPATH/packages"

# Determine the directory where configs are stored
SLACK_HARDWARE_BACKUP_DIR="$DIRPATH/configs/$HARDWARE_ID"
if [ ! -d $SLACK_HARDWARE_BACKUP_DIR ]; then
  SLACK_HARDWARE_BACKUP_DIR="$DIRPATH/configs/$MAIN_HARDWARE_ID"
fi

SLACKWARE_VERSION=15.0

HOME_USER=/home/$SUDO_USER

# ===================== HELPER FUNCTIONS =====================

installfromsource(){
  local PACKAGE_NAME="$1"
  local PACKAGE_BINARY_PATH="$2"
  installstart "$PACKAGE_NAME"
  PACKAGE_SLACKBUILD_DIR=$SLACK_PKG_DIR/$PACKAGE_NAME
  if [ -d $PACKAGE_SLACKBUILD_DIR ]; then
    cd $PACKAGE_SLACKBUILD_DIR
    # Parse the .info file and download the source
    local PACKAGE_SOURCE_URL=$(grep -oP 'DOWNLOAD_x86_64="\K[^"]+' $PACKAGE_NAME.info)
    wget $PACKAGE_SOURCE_URL
    # Compile
    ./$PACKAGE_NAME.SlackBuild
    installpkg /tmp/$PACKAGE_NAME-*-x86_64-*.tgz
  else 
    message "[ERROR]: $PACKAGE_NAME not available. Continuing without installing $PACKAGE_NAME"
  fi
}

installbinary(){
  local PACKAGE_NAME="$1"
  local PACKAGE_BINARY_PATH="$2"
  installstart "$PACKAGE_NAME"
  pkg=$SLACK_PKG_DIR/$PACKAGE_BINARY_PATH
  if [ -f $pkg ]; then
    installpkg $pkg
    installend "$PACKAGE_NAME"
  else 
    message "[ERROR]: $PACKAGE_NAME not available. Continuing without installing $PACKAGE_NAME"
  fi
}

installsbo(){
  local PACKAGE="$1"
  local MESSAGE="$2"
  installstart $PACKAGE
  if [ ! -z "$MESSAGE" ]; then
    printf "$(make_yellow "\n$MESSAGE\n")"
    printf "Press any key to continue\n"
    read -n 1 -s -r
  fi
  sboinstall -j7 $PACKAGE
  if [ $? != 0 ]; then
    printf "$(make_red "\nPackage $PACKAGE did NOT install successfully\n")"
    printf "Press any key to continue\n"
    read -n 1 -s -r
  else
    installend $PACKAGE
  fi
}


# ===================== INSTALLING PACKAGES =====================

# ------------------------ slackpkgplus ------------------------
message "Installing slackpkg+"
# wget http://slakfinder.org/slackpkg+/pkg/slackpkg+-1.7.0-noarch-10mt.txz
wget https://slackware.nl/slackpkgplus15/pkg/slackpkg+-1.8.0-noarch-7mt.txz
mv slackpkg+*.txz $SLACK_PKG_DIR
installpkg $SLACK_PKG_DIR/slackpkg+*.txz
cp $SLACK_HARDWARE_BACKUP_DIR/slackpkgplus.conf /etc/slackpkg/slackpkgplus.conf
slackpkg update gpg
slackpkg update


# ------------------------ sbotools ------------------------
message "Installing sbotools"
cd $SLACK_PKG_DIR
if [ -d $SLACK_PKG_DIR/slackbuilds ]; then
  cd $SLACK_PKG_DIR/slackbuilds
  git pull
else
  mkdir -p $SLACK_PKG_DIR/slackbuilds
  cd $SLACK_PKG_DIR/slackbuilds
  git clone git://git.slackbuilds.org/slackbuilds.git
fi
chmod +x system/sbotools/sbotools.SlackBuild
sudo system/sbotools/sbotools.SlackBuild
cd -
sudo installpkg /tmp/sbotools-*-noarch-1_SBo
sboconfig --slackware-version $SLACKWARE_VERSION
sbocheck


# ------------------------ sublime ------------------------
installsbo "sublime_text"
ln -s /usr/bin/sublime_text /usr/bin/sublime
# Configure keyboard shortcuts and extensions for user
configure_sublime $SLACK_HARDWARE_BACKUP_DIR


# ------------------------ neovim ------------------------
installsbo "neovim"
configure_neovim $SLACK_HARDWARE_BACKUP_DIR


# ------------------------ avahi ------------------------
# NOTE: avahi is now part of official slackware64
# Needed for geoclue2
# groupadd -g 214 avahi
# useradd -u 214 -g 214 -c "Avahi User" -d /dev/null -s /bin/false avahi
# installsbo "avahi"
# /etc/rc.d/rc.avahidaemon start


# ------------------------ geoclue2 ------------------------
# Needed for redshift automatic location. Must be installed BEFORE redshift
# TODO: Make sure you get geoclue at least 2.7.2 and your latest geoclue config
# TODO: Installing from source requires passing AVAHI=yes
installsbo "geoclue2" "NOTE: Make sure to pass AVAHI=yes"

# Recover geoclue.conf
if [ -f /etc/geoclue/geoclue.conf ]; then
  printf "$(make_yellow "/nWARN: /etc/geoclue/geoclue.conf exists. ")"
  printf "$(make_yellow "Copying config file to /etc/geoclue/geoclue.conf.new. Make sure to resolve conflicts manually\n")"
  printf "Press any key to continue\n"
  read -n 1 -s -r
  sudo -u $SUDO_USER cp $SLACK_HARDWARE_BACKUP_DIR/geoclue.conf /etc/geoclue/geoclue.conf.new
else
  sudo -u $SUDO_USER cp $SLACK_HARDWARE_BACKUP_DIR/geoclue.conf /etc/geoclue/geoclue.conf
fi

# ------------------------ redshift ------------------------
installsbo "redshift"
sudo -u $SUDO_USER cp $SLACK_HARDWARE_BACKUP_DIR/redshift.conf /home/$SUDO_USER/.config/
sudo -u $SUDO_USER redshift &


# ------------------------ chromium ------------------------
slackpkg install chromium
# Set up keys to enable chromium syncing with the cloud
sudo cp $SLACK_HARDWARE_BACKUP_DIR/01-apikeys.conf /etc/chromium/01-apikeys.conf


# ------------------------ bash-completion ------------------------
installstart "bash-completion"
slackpkg install bash-completion
installend "bash-completion"
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
mv git-completion.bash /usr/share/bash-completion/completions/git


# ------------------------ VPN packages ------------------------
installsbo "pptp"
installsbo "NetworkManager-pptp"
#
installsbo "NetworkManager-l2tp"
installsbo "xl2tpd"
# installfromsource "xl2tpd"
installsbo "strongswan"
#
installsbo "NetworkManager-openvpn"
#
# openresolv needed for ProtonVPN, but is now part of official Slackware
# installsbo "openresolv" "NOTE: Make sure to pass OPENVPN=yes"


# ------------------------ MasterPDFEditor ------------------------
installsbo "MasterPDFEditor"


# ------------------------ i8kutils ------------------------
installsbo "i8kutils"


# ------------------------ telegram ------------------------
installsbo "telegram"


# ------------------------ wireplumber ------------------------
# installsbo "wireplumber"


# ------------------------ spotify ------------------------
installsbo "spotify"
# Spotify is now properly maintained on SlackBuilds.org and the hacks below are
# probably not needed anymore. Unsure about ffmpeg3-compat
# installfromsource "spotify"
# # The deb package is linked to libcurl-gnutls.so.4, which is incorrect naming in Ubuntu
# ln -s /usr/lib64/libcurl.so /usr/lib64/libcurl-gnutls.so.4
# slackpkg install ffmpeg3-compat  # This is probably not needed anymore


# ------------------------ plex ------------------------
installsbo "plexmediaserver" "NOTE: Make sure to add the plex user and group when prompted by SBo"
chmod +x /etc/rc.d/rc.plexmediaserver

# ------------------------ VS Code ------------------------

installsbo vscode-bin

# Configure .desktop file for opening urls. If it stops working, check the latest version in vscode .deb package
tee -a $HOME_USER/Downloads/code-url-handler.desktop > /dev/null <<EOT
[Desktop Entry]
Name=Visual Studio Code - URL Handler
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/bin/code --open-url %U
Icon=/usr/share/icons/hicolor/1024x1024/apps/code.png
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/vscode;
Keywords=vscode;
EOT
desktop-file-install --dir=$HOME/.local/share/applications $HOME_USER/Downloads/code-url-handler.desktop
update-desktop-database ~/.local/share/applications
if [ ! -f $HOME_USER/Downloads/code-url-handler.desktop ]; then
  echo
  printf "$(make_yellow "Run the following commands as normal user in a separate terminal:\n\n")"
  echo "desktop-file-install --dir=$HOME/.local/share/applications $HOME_USER/Downloads/code-url-handler.desktop"
  echo "update-desktop-database ~/.local/share/applications"
  printf "\nPress any key when done and ready to continue\n"
  read -n 1 -s -r
fi
rm -f $HOME_USER/Downloads/code-url-handler.desktop

# ------------------------ jdk ------------------------

# These are for Java 8. There is Java 11 now, which is more widely used. They can't exist together
# slackpkg install openjdk
# slackpkg install openjre


# ------------------------ mendeleydesktop ------------------------
# installfromsource "mendeleydesktop"
# installsbo "mendeleydesktop"


# ------------------------ dropbox ------------------------
# slackpkg install dropbox-client
# Alienbob hasn't updated dropbox-client in ages. Use his scripts and a much newer version
# TODO: Update version in the source or look into installing from source
# https://slackbuilds.org/repository/15.0/network/dropbox/
# https://github.com/dropbox/nautilus-dropbox
installfromsource "dropbox-client"


# ------------------------ vlc ------------------------
slackpkg install vlc
slackpkg install npapi-vlc
# Configure keyboard shortcuts
sed -i '/key-jump-extrashort=/c\key-jump-extrashort=Left' $HOME_USER/.config/vlc/vlcrc
sed -i '/key-jump+extrashort=/c\key-jump+extrashort=Right' $HOME_USER/.config/vlc/vlcrc
sed -i '/key-jump-short=/c\key-jump-short=Shift+Left' $HOME_USER/.config/vlc/vlcrc
sed -i '/key-jump+short=/c\key-jump+short=Shift+Right' $HOME_USER/.config/vlc/vlcrc


# ------------------------ VNC ------------------------
slackpkg install fltk  # Needed for tigervnc to work
slackpkg install tigervnc


# ------------------------ FFMPEG ------------------------
# Update ffmpeg to alienbob's version as it's compiled with x264 and x265 support
# Preference already configured in slackpkgplus.conf
slackpkg upgrade ffmpeg
installsbo "x265"


# ------------------------ libreoffice ------------------------
slackpkg install openjdk11  # jdk and jre are in the same package
slackpkg install libreoffice
# This might be incomplete. Might need boost-compat and icu4c-compat as well as `export MESA_LOADER_DRIVER_OVERRIDE=i915`
# Check your Slackware.md notes and the latest announcements from alien


# ------------------------ emoji ------------------------
installsbo "noto-emoji"  # Needed for emoji to show up properly in KDE emoji selector


# ------------------------ common packages ------------------------
installsbo "FontAwesome"
installsbo "git-lfs"
installsbo "hplip-plugin"
installsbo "nvme-cli"
installsbo "teamviewer"
installsbo "texlive-extra"
installsbo "texlive-fonts"
installsbo "unrar"
installsbo "zoom-linux"
installsbo "deb2tgz"
installsbo "lsb-release"


# ------------------------ python packages ------------------------
sudo pip3 install -U ipython
sudo pip3 install -U matplotlib
sudo pip3 install -U numpy
sudo pip3 install -U youtube-dl
sudo pip3 install -U virtualenv
sudo pip3 install -U ipdb
# Make sure to install cv2 with -no-binary option so it uses the system opencv library. Otherwise, there's a conflict
# in the libraries and you get errors displaying any images. This would probably have to be updated every time you
# update the system opencv
sudo pip3 install -U --no-binary opencv-python opencv-python


# ------------------------ docker ------------------------
installsbo "docker-cli"  # If it doesn't work, use a new terminal or install manually locally. Had such problems before
# source /etc/profile.d/go.sh
sudo usermod -aG docker $SUDO_USER
message "Added to docker group. Remember to reboot for changes to take effect"
installsbo "docker-buildx"
installsbo "libnvidia-container"
sudo chmod +x /etc/rc.d/rc.docker
# TODO: Install nvidia-container-toolkit - code untested
# cd $HOME_USER/Packages/
# wget https://nvidia.github.io/libnvidia-container/stable/deb/amd64/nvidia-container-toolkit_1.14.5-1_amd64.deb
# deg2tgz nvidia-container-toolkit_1.14.5-1_amd64.deb
# sudo installpkg nvidia-container-toolkit_1.14.5-1_amd64.txz
# cd -

# ------------------------ bazel ------------------------

# You don't need zulu-openjdk11 as long as you have jdk11 from alienbob
# zulu-openjdk11 is just an open-source version
installfromsource "bazel"

# ------------------------ virtualbox ------------------------
groupadd vboxusers
sudo usermod -aG vboxusers $SUDO_USER


# ------------------------ google-chrome ------------------------
# installbinary "google-chrome" "google-chrome/google-chrome-*-x86_64-1.txz"

# ------------------------ pip3 ------------------------
# installstart "pip3"
# wget https://bootstrap.pypa.io/get-pip.py
# mv get-pip.py $SLACK_PKG_DIR/
# python3 $SLACK_PKG_DIR/get-pip.py
# installend "pip3"

# -------------------------------------
# IMPORTANT: POSSIBLY REQUIRED PACKAGES
# -------------------------------------

# # xvidcore: needed for ffmpeg from SBo
# installsbo "xvidcore"
