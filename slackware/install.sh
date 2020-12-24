#!/bin/bash

# ======================== !! NOTE !! ========================
# Rule of thumb is to always recompile SBo packages. This is the principle of Slackware.
# If you use a binary, you might easily miss important dependencies.
# Packages which you normally use from alien, such as chromium, vlc are OK to come in binary
# ======================== !! NOTE !! ========================

# ===================== CONFIRM READY =====================
echo -n "DID YOU ENABLE SUDO, SELECT A SLACKPKG MIRROR AND CONNECT TO THE INTERNET [y/n]?"
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

SBOTOOLS_VERSION=2.5
SLACK_VERSION=14.2


installbinary(){
  # Args:
  #   $1: Name of the package
  #   $2: Path of the binary
  installstart "$1"
  pkg=$SLACK_PKG_DIR/$2
  if [ -f $pkg ]; then
    sudo installpkg $pkg
    installend "$1"
  else 
    message "[ERROR]: $1 not available. Continuing without installing $1"
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
  sudo sboinstall -j7 $PACKAGE
  installend $PACKAGE
}


# ===================== INSTALLING PACKAGES =====================

# ------------------------ slackpkgplus ------------------------
message "Installing slackpkg+"
wget http://slakfinder.org/slackpkg+/pkg/slackpkg+-1.7.0-noarch-10mt.txz
mv slackpkg+*.txz $SLACK_PKG_DIR
sudo installpkg $SLACK_PKG_DIR/slackpkg+*.txz
cp $SLACK_BACKUP_DIR/slackpkgplus.conf /etc/slackpkg/slackpkgplus.conf
sudo slackpkg update gpg
sudo slackpkg update


# ------------------------ sbotools ------------------------
message "Installing sbotools"
wget https://pink-mist.github.io/sbotools/downloads/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
mv sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz $SLACK_PKG_DIR
sudo installpkg $SLACK_PKG_DIR/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
sudo sboconfig --slackware-version $SLACK_VERSION
sudo sbocheck


# ------------------------ sublime ------------------------
installsbo "sublime_text"
sudo ln -s /usr/bin/sublime_text /usr/bin/sublime
# Configure keyboard shortcuts and extensions
configure_sublime $SLACK_BACKUP_DIR


# ------------------------ avahi ------------------------
# Needed for geoclue2
sudo groupadd -g 214 avahi
sudo useradd -u 214 -g 214 -c "Avahi User" -d /dev/null -s /bin/false avahi
installsbo "avahi"
sudo /etc/rc.d/rc.avahidaemon start


# ------------------------ geoclue2 ------------------------
# Needed for redshift automatic location. Must be installed BEFORE redshift
installsbo "geoclue2" "!!!!!!!!! NOTE: Make sure to pass AVAHI=yes !!!!!!!!!"


# ------------------------ redshift ------------------------
installsbo "redshift"
cp $SLACK_BACKUP_DIR/redshift.conf ~/.config/
redshift &


# ------------------------ bash-completion ------------------------
installstart "bash-completion"
sudo slackpkg install bash-completion
installend "bash-completion"
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
sudo mv git-completion.bash /usr/share/bash-completion/completions/git


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
installsbo "spotify"
sudo slackpkg install ffmpeg3-compat


# ------------------------ plex ------------------------
installsbo "plexmediaserver" "!!!!!!!!! NOTE: Make sure to add the plex user and group when prompted by SBo !!!!!!!!!"


# ------------------------ jdk ------------------------
installstart "jdk"
jdk_dir=$SLACK_PKG_DIR/jdk-8u172
if [ -d $jdk_dir ]; then
  cd $jdk_dir
  sudo ./jdk.SlackBuild
  sudo installpkg /tmp/jdk-*-x86_64-1_SBo.tgz
  cd -
  installend "jdk"
else 
  message "ERROR: jdk not available. Continuing without installing jdk"
fi


# ------------------------ chromium ------------------------
sudo slackpkg install chromium


# ------------------------ dropbox ------------------------
sudo slackpkg install dropbox-client


# ------------------------ vlc ------------------------
sudo slackpkg install vlc
sudo slackpkg install npapi-vlc


# ------------------------ common packages ------------------------
installsbo "FontAwesome"
installsbo "git-lfs"
installsbo "hplip-plugin"
installsbo "mendeley-desktop"
installsbo "nvme-cli"
installsbo "teamviewer"
installsbo "texlive-extra"
installsbo "texlive-fonts"
installsbo "unrar"
installsbo "zoom"


# ------------------------ google-chrome ------------------------
# installbinary "google-chrome" "google-chrome/google-chrome-*-x86_64-1.txz"


# -------------------------------------
# IMPORTANT: POSSIBLY REQUIRED PACKAGES
# -------------------------------------

# # xvidcore: needed for ffmpeg from SBo
# installsbo "xvidcore"

# # Texlive additions
# installsbo "texlive-extra"
# installsbo "texlive-fonts"


# ------------------------ pip3 ------------------------
# installstart "pip3"
# wget https://bootstrap.pypa.io/get-pip.py
# mv get-pip.py $SLACK_PKG_DIR/
# sudo python3 $SLACK_PKG_DIR/get-pip.py
# installend "pip3"

