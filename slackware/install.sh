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
# ===================== CONFIRM READY =====================

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SLACK_BACKUP_DIR="$DIRPATH/configs"
SLACK_PKG_DIR="$DIRPATH/packages"
source $DIRPATH/../common/helpers.sh

SBOTOOLS_VERSION=2.7
SLACKWARE_VERSION=14.2

# ===================== HELPER FUNCTIONS =====================

installfromsource(){
  local PACKAGE_NAME="$1"
  local PACKAGE_BINARY_PATH="$2"
  installstart "$PACKAGE_NAME"
  PACKAGE_SLACKBUILD_DIR=$SLACK_PKG_DIR/$PACKAGE_NAME
  if [ -d $PACKAGE_SLACKBUILD_DIR ]; then
    cd $PACKAGE_SLACKBUILD_DIR
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
  installstart $PACKAGE
  if [ -z "$MESSAGE" ]; then
    printf "\n$MESSAGE\n"
    printf "Press any key to continue\n"
    read -n 1 -s -r
  fi
  sboinstall -j7 $PACKAGE
  installend $PACKAGE
}


# ===================== INSTALLING PACKAGES =====================

# ------------------------ slackpkgplus ------------------------
message "Installing slackpkg+"
wget http://slakfinder.org/slackpkg+/pkg/slackpkg+-1.7.0-noarch-10mt.txz
mv slackpkg+*.txz $SLACK_PKG_DIR
installpkg $SLACK_PKG_DIR/slackpkg+*.txz
cp $SLACK_BACKUP_DIR/slackpkgplus.conf /etc/slackpkg/slackpkgplus.conf
slackpkg update gpg
slackpkg update


# ------------------------ sbotools ------------------------
message "Installing sbotools"
wget https://pink-mist.github.io/sbotools/downloads/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
mv sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz $SLACK_PKG_DIR
installpkg $SLACK_PKG_DIR/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
sboconfig --slackware-version $SLACKWARE_VERSION
sbocheck


# ------------------------ sublime ------------------------
installsbo "sublime_text"
ln -s /usr/bin/sublime_text /usr/bin/sublime
# Configure keyboard shortcuts and extensions
sudo -u $SUDO_USER configure_sublime $SLACK_BACKUP_DIR


# ------------------------ avahi ------------------------
# Needed for geoclue2
groupadd -g 214 avahi
useradd -u 214 -g 214 -c "Avahi User" -d /dev/null -s /bin/false avahi
installsbo "avahi"
/etc/rc.d/rc.avahidaemon start


# ------------------------ geoclue2 ------------------------
# Needed for redshift automatic location. Must be installed BEFORE redshift
installsbo "geoclue2" "!!!!!!!!! NOTE: Make sure to pass AVAHI=yes !!!!!!!!!"


# ------------------------ redshift ------------------------
installsbo "redshift"
sudo -u $SUDO_USER cp $SLACK_BACKUP_DIR/redshift.conf ~/.config/
sudo -u $SUDO_USER redshift &


# ------------------------ chromium ------------------------
slackpkg install chromium


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
installsbo "strongswan"
#
installsbo "NetworkManager-openvpn"


# ------------------------ MasterPDFEditor ------------------------
installsbo "MasterPDFEditor"


# ------------------------ i8kutils ------------------------
installsbo "i8kutils"


# ------------------------ telegram ------------------------
installsbo "telegram"


# ------------------------ spotify ------------------------
installfromsource "spotify"
# installsbo "spotify"
# The deb package is linked to libcurl-gnutls.so.4, which is incorrect naming in Ubuntu
ln -s /usr/lib64/libcurl.so /usr/lib64/libcurl-gnutls.so.4
slackpkg install ffmpeg3-compat


# ------------------------ plex ------------------------
installsbo "plexmediaserver" "!!!!!!!!! NOTE: Make sure to add the plex user and group when prompted by SBo !!!!!!!!!"


# ------------------------ jdk ------------------------
installfromsource "jdk"


# ------------------------ mendeleydesktop ------------------------
installfromsource "mendeleydesktop"
# installsbo "mendeleydesktop"


# ------------------------ dropbox ------------------------
slackpkg install dropbox-client


# ------------------------ vlc ------------------------
slackpkg install vlc
slackpkg install npapi-vlc


# ------------------------ common packages ------------------------
installsbo "FontAwesome"
installsbo "git-lfs"
installsbo "hplip-plugin"
installsbo "nvme-cli"
installsbo "teamviewer"
installsbo "texlive-extra"
installsbo "texlive-fonts"
installsbo "unrar"
installsbo "zoom"


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
