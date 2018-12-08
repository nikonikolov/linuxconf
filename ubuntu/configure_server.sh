#!/bin/bash

DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UBUNTU_BACKUP_DIR="$DIRPATH/configs"
source $DIRPATH/../common/helpers.sh
source $DIRPATH/functions.sh

# ------------- Append ~/.bashrc with custom configs -------------
setupbashrc

# ------------- Configure vim and tmux -------------
install_vim
install_tmux
configure_vim
configure_tmux $UBUNTU_BACKUP_DIR
