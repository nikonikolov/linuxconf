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

  # Append with custom options
  sed -i "/HISTSIZE=/c\HISTSIZE=3000" $HOME/.bashrc
  sed -i "/HISTFILESIZE=/c\HISTFILESIZE=3000" $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  echo '# ============================================================================' >> $HOME/.bashrc
  echo '# ============================ CUSTOM DEFINITIONS ============================' >> $HOME/.bashrc
  echo '# ============================================================================' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  echo 'alias tmux="tmux -2"' >> $HOME/.bashrc
  echo 'alias diskprops="df -h"' >> $HOME/.bashrc
  echo 'props(){ du -a -h --max-depth=1 $* | sort -hr; }' >> $HOME/.bashrc
  # echo '' >> $HOME/.bashrc
  # echo 'WAYVECODE="$HOME/Workspace/WayveCode"' >> $HOME/.bashrc
  # echo 'REMOTEHOME="/mnt/remote/data/users/nikolay/"' >> $HOME/.bashrc
  # echo 'alias sourcedl="source $WAYVECODE/deeplearning/activate"' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
  # Optional:
  # echo 'alias loadconda="export PATH=$HOME/miniconda3/bin:$PATH"' >> $HOME/.bashrc
  # echo 'PATH=$PATH:$HOME/.local/bin:$HOME/bin"' >> $HOME/.bashrc
  echo '' >> $HOME/.bashrc
}
