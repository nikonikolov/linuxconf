#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UBUNTU_BACKUP_DIR="$DIRPATH/configs"

install_tmux(){
  INSTALLED=$(dpkg -l | grep tmux)
  
  if [ INSTALLED == "" ]; then
    sudo apt-get install -y tmux
  fi
}

install_vim(){
  INSTALLED=$(dpkg -l | grep vim)
  
  if [ INSTALLED == "" ]; then
    sudo apt-get install -y vim
  fi
}

setupbashrc(){
  # Copy default bashrc if it does not exist already
  if [ ! -f ~/.bashrc ]; then
    cp $UBUNTU_BACKUP_DIR/bashrc.txt ~/.bashrc
  fi

  if [ ! -f ~/.bash_profile ]; then
    cp $UBUNTU_BACKUP_DIR/bash_profile.txt ~/.bash_profile
  fi

  # Append with custom options
  sed -i "/HISTSIZE=/c\HISTSIZE=3000" $HOME/.bashrc
  sed -i "/HISTFILESIZE=/c\HISTFILESIZE=3000" $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  echo '# ============================================================================' >> $HOME/.bashrc
  echo '# ============================ CUSTOM DEFINITIONS ============================' >> $HOME/.bashrc
  echo '# ============================================================================' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  echo 'alias tmux="tmux -2"' >> $HOME/.bashrc
  echo 'alias sublime="subl"' >> $HOME/.bashrc
  echo 'alias diskprops="df -h"' >> $HOME/.bashrc
  echo 'props(){ du -a -h --max-depth=1 $* | sort -hr; }' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  # Optional:
  # echo 'alias loadconda="export PATH=$HOME/miniconda3/bin:$PATH"' >> $HOME/.bashrc
  # echo 'PATH=$PATH:$HOME/.local/bin:$HOME/bin"' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
}
