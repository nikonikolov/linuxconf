#!/bin/bash

# ======================== !! NOTE !! ========================
# Rule of thumb is to always recompile SBo packages. This is the principle of Slackware.
# Packages which you normally use from alien, such as chromium, vlc are OK to come in binary
# ======================== !! NOTE !! ========================

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
  installstart $1
  sudo sboinstall -j7 $1
  installend $1
}


# ===================== INSTALLING PACKAGES =====================

# ------------------------ sbotools ------------------------
message "Installing sbotools"
wget https://pink-mist.github.io/sbotools/downloads/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
mv sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz $SLACK_PKG_DIR
sudo installpkg $SLACK_PKG_DIR/sbotools-$SBOTOOLS_VERSION-noarch-1_SBo.tgz
sudo sboconfig --slackware-version $SLACK_VERSION
sudo sbocheck


# ------------------------ pip3 ------------------------
installstart "pip3"
wget https://bootstrap.pypa.io/get-pip.py
mv get-pip.py $SLACK_PKG_DIR/
sudo python3 $SLACK_PKG_DIR/get-pip.py
installend "pip3"


# ------------------------ sublime ------------------------
installsbo "sublime_text"
sudo ln -s /usr/bin/sublime_text /usr/bin/sublime
# Configure keyboard shortcuts and extensions
configure_sublime $SLACK_BACKUP_DIR


# ------------------------ redshift ------------------------
installsbo "redshift"
cp $SLACK_BACKUP_DIR/redshift.conf ~/.config/
redshift &


# ------------------------ pptp and NetworkManager-pptp for VPN ------------------------
installsbo "pptp"
installsbo "NetworkManager-pptp"


# ------------------------ MasterPDFEditor ------------------------
installsbo "MasterPDFEditor"


# ------------------------ i8kutils ------------------------
installsbo "i8kutils"


# ------------------------ jdk ------------------------
installstart "jdk"
jdk_dir=$SLACK_PKG_DIR/jdk
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
installbinary "chromium" "chromium/chromium-*-x86_64-1alien.txz"


# ------------------------ dropbox ------------------------
installbinary "dropbox" "dropbox/dropbox-client-1.6.1-x86_64-1alien.tgz"


# ------------------------ vlc ------------------------
installbinary "vlc" "vlc/vlc-*-x86_64-1alien.txz"
installbinary "npapi-vlc" "vlc/npapi-vlc-*-x86_64-1alien.txz"


# ------------------------ google-chrome ------------------------
installbinary "google-chrome" "google-chrome/google-chrome-*-x86_64-1.txz"


if [ -x "$(command -v plasmashell)" ];
  message "Found KDE5"
else
  message "Found KDE4"
  configure_kde4
fi

configure_kde4(){
  
  message "Configuring KDE shortcuts"
  # Configure KDE shortcuts
  KDE_SHORTCUTS=$HOME/.kde/share/config/kglobalshortcutsrc
  if [ -f $KDE_SHORTCUTS ]; then
    mv $KDE_SHORTCUTS $KDE_SHORTCUTS.backup
  fi 
  cp $SLACK_BACKUP_DIR/kglobalshortcutsrc ~/.kde/share/config/kglobalshortcutsrc

  # ===================== INSTALL KDE THEMES =====================
  message "Installing HexLite-KDETheme"
  cd $SLACK_PKG_DIR/HexLite-KDETheme
  cp -r Aurorae/* ~/.kde/share/apps/aurorae/themes/
  cp -r Plasma/* ~/.kde/share/apps/desktoptheme/
  cp -r Color\ Schemes/* ~/.kde/share/apps/color-schemes/
  cd -

  message "Installing EvolvereSuit KDE4 icons"
  mkdir -p ~/.evolveresuit && git clone https://github.com/franksouza183/EvolvereSuit ~/.evolveresuit/
  cp -r ~/.evolveresuit/icons/evolvere-black-folders-vivid ~/.kde/share/icons/
  rm -rf ~/.evolveresuit

  installsbo "QtCurve-KDE4"
}


# -------------------------------------
# IMPORTANT: POSSIBLY REQUIRED PACKAGES
# -------------------------------------

# # xvidcore: needed for ffmpeg from SBo
# installsbo "xvidcore"

# # Texlive additions
# installsbo "texlive-extra"
# installsbo "texlive-fonts"


# ---------------------------------------------
# OLD PACKAGES (now part of official Slackware)
# ---------------------------------------------

# installstart "ffmpeg"
# ffmpeg_pkg=$SLACK_PKG_DIR/ffmpeg-alien/ffmpeg-*-x86_64-1alien.txz
# if [ -f $ffmpeg_pkg ]; then
#   sudo installpkg $ffmpeg_pkg
#   installend "ffmpeg"
# else 
#   message "ERROR: ffmpeg not available. Continuing without installing ffmpeg"
# fi

# installsbo "libinput"
# sudo cp $SLACK_BACKUP_DIR/*libinput.conf /etc/X11/xorg.conf.d/
# sudo cp $SLACK_BACKUP_DIR/*touchpad.conf /etc/X11/xorg.conf.d/

# installsbo "xf86-input-libinput"
