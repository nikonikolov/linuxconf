#!/bin/bash

message(){
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo "------ $1"
  echo "-------------------------------------------------------------------------------"
  echo ""
}

confstart(){
  message "Configuring $1"
}

confend(){
  message "Configuring $1: SUCCESS"
}

installstart(){
  message "Installing $1"
}

installend(){
  message "$1: SUCCESSFULLY INSTALLED"
}

safecp(){
  if [ -f "$1" ]; then
    cp "$1" "$2"
  else
    echo "[WARNING]: File $1 does not exist. IGNORING"
  fi
}

configure_tmux(){
  # Args:
  #   $1: Backup directory where the configuration file is
  #   $2: Color, e.g. "colour220". If present, treat as server and set fg and bg colors

  confstart "tmux"

  cp $1/tmux.conf $HOME/.tmux.conf
  mkdir -p ~/.tmux_plugins
  cd ~/.tmux_plugins
  if [ ! -d tmux-better-mouse-mode ]; then
    git clone https://github.com/NHDaly/tmux-better-mouse-mode.git
  fi
  cd -

  if [ $# == 2 ]; then
    sed -i "/# set -g pane-active-border-fg colour220/c\set -g pane-active-border-fg $2" $HOME/.tmux.conf
    sed -i "/# set -g status-bg colour220/c\set -g status-bg $2" $HOME/.tmux.conf
  fi
  
  confend "tmux"
}

configure_vim(){
  confstart "vim"

  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  git clone https://github.com/flazz/vim-colorschemes
  mv vim-colorschemes/colors/ .vim
  rm -rf vim-colorschemes
  # Get the .vimrc
  curl https://raw.githubusercontent.com/grigio/vim-sublime/master/vimrc > $HOME/.vimrc
  # Remove unwanted plugins
  sed -i "/Plugin 'SirVer\/ultisnips'/c\\\"Plugin 'SirVer\/ultisnips'" $HOME/.vimrc
  sed -i "/Plugin 'airblade\/vim-gitgutter'/c\\\"Plugin 'airblade\/vim-gitgutter'" $HOME/.vimrc
  sed -i "/Plugin 'Valloric\/YouCompleteMe'/c\\\"Plugin 'Valloric\/YouCompleteMe'" $HOME/.vimrc
  sed -i "/Plugin 'davidhalter\/jedi-vim'/c\\\"Plugin 'davidhalter\/jedi-vim'" $HOME/.vimrc
  # Install the plugins
  vim +PluginInstall +qall

  # Configure backup directories
  mkdir -p $HOME/.vim/backup
  echo "set directory=$HOME/.vim/backup   \" Directory for something" >> $HOME/.vimrc
  echo "set backupdir=$HOME/.vim/backup   \" Directory for backup files" >> $HOME/.vimrc
  echo "set undodir=$HOME/.vim/backup     \" Directory for undo history" >> $HOME/.vimrc

  confend "vim"
}

configure_sublime(){
  # Args:
  #   $1: Backup directory where the configuration files are
  confstart "sublime"
  
  PACKDIR="$HOME/.config/sublime-text-3/Packages/User"
  PACKFILE="$PACKDIR/Package\ Control.sublime-settings"
  INTALLED_PACKDIR="$HOME/.config/sublime-text-3/Installed\ Packages"

  # Install the keyboard shortcuts and settings files
  safecp "$1/Default\ (Linux).sublime-keymap" "$PACKDIR"
  safecp "$1/Preferences.sublime-settings" "$PACKDIR"

  # Install package control
  wget https://packagecontrol.io/Package%20Control.sublime-package
  mkdir -p INTALLED_PACKDIR
  mv Package\ Control.sublime-package INTALLED_PACKDIR/

  # Set up packages which will automatically be installed on next sublime startup
  mkdir -p $PACKDIR
  touch $PACKFILE
  echo '{' >> $PACKFILE
  echo '  "bootstrapped": true,' >> $PACKFILE
  echo '  "in_process_packages":' >> $PACKFILE
  echo '  [' >> $PACKFILE
  echo '  ],' >> $PACKFILE
  echo '  "installed_packages":' >> $PACKFILE
  echo '  [' >> $PACKFILE
  echo '    "CMake",' >> $PACKFILE
  echo '    "Package Control",' >> $PACKFILE
  echo '    "SideBarEnhancements"' >> $PACKFILE
  echo '  ]' >> $PACKFILE
  echo '}' >> $PACKFILE

  confend "sublime"
}

configure_redshift(){
  # Args:
  #   $1: Backup directory where the configuration file is
  safecp $1/redshift.conf $HOME/.config/
}
