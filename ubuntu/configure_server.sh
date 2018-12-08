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
# Set the tmux color to 220 (yellow), since this is a server
configure_tmux $UBUNTU_BACKUP_DIR "colour220"
