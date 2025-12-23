#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UBUNTU_BACKUP_DIR="$DIRPATH/configs"

install_tmux(){
  INSTALLED=$(dpkg -l | grep tmux)
  
  if [ INSTALLED == "" ]; then
    sudo apt install -y tmux
  fi
}

install_vim(){
  INSTALLED=$(dpkg -l | grep vim)
  
  if [ INSTALLED == "" ]; then
    sudo apt install -y vim
  fi
}

install_neovim() {
  # NOTE: This function doesn't overwrite the system installed nvim via apt

  local REQUIRED_VERSION="0.10.4"  # Minimum required version

  if command -v nvim >/dev/null 2>&1; then
    # Extract version: "NVIM v0.11.4" → "0.11.4"
    local INSTALLED_VERSION
    INSTALLED_VERSION="$(nvim --version | head -n1 | sed -E 's/^NVIM v([0-9.]+).*$/\1/')"

    if [ "$(printf '%s\n%s\n' "$REQUIRED_VERSION" "$INSTALLED_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
      echo "Neovim $INSTALLED_VERSION is already >= $REQUIRED_VERSION"
      return 0
    fi
  fi

  # INSTALL FROM BINARY (does not touch apt-installed nvim)
  # We install from binary because some versions of ubuntu have too old version of nvim which doesn't support our extensions
  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

  export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
}

setupbashrc(){
  # Copy default bashrc if it does not exist already
  if [ ! -f ~/.bashrc ]; then
    cp $UBUNTU_BACKUP_DIR/bashrc.txt ~/.bashrc
  fi

  if [ ! -f ~/.bash_profile ]; then
    cp $UBUNTU_BACKUP_DIR/bash_profile.txt ~/.bash_profile
  fi

  sed -i "/HISTSIZE=/c\HISTSIZE=3000" $HOME/.bashrc
  sed -i "/HISTFILESIZE=/c\HISTFILESIZE=3000" $HOME/.bashrc

  # Append with custom options
  tee -a $HOME/.bashrc > /dev/null <<EOT
# ============================================================================
# ============================ CUSTOM DEFINITIONS ============================
# ============================================================================

alias tmux="tmux -2"
alias sublime="subl"
alias diskprops="df -h"
props(){ du -a -h --max-depth=1 \$* | sort -hr; }

pidps() {
  local PS_FLAGS='-eo user,pid,ppid,lstart,cmd'
  if [ \$# == 0 ]; then
    ps \$PS_FLAGS
  else
    ps \$PS_FLAGS | head -1; ps \$PS_FLAGS | grep "\$1"
  fi
  # ps \$PS_FLAGS | head -1; ps \$PS_FLAGS | grep "\$1"
  # ps -eaf | head -1; ps -eaf | grep "\$1"
  # ps -eo uid,pid,ppid,lstart,cmd
}

export PATH="\$PATH:/opt/nvim-linux-x86_64/bin"

if [ ! -z \$(which nvim) ]; then
  alias vim='nvim'
fi

EOT
}
