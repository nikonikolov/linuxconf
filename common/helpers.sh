#!/bin/bash

COMMON_DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

message(){
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo "------ $1"
  echo "-------------------------------------------------------------------------------"
  echo ""
}

make_yellow() {
  local text="$1"

  local yellow_code="\033[1;33m"
  local reset_code="\033[0m"

  echo -n "${yellow_code}${text}${reset_code}"
}

make_red() {
  local text="$1"

  local red_code="\033[1;31m"
  local reset_code="\033[0m"

  echo -n "${red_code}${text}${reset_code}"
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
  local SOURCE_PATH="$1"         # $1: source path
  local DESTIONATION_PATH="$2"   # $2: destination path

  if [ -f "$SOURCE_PATH" ]; then
    cp "$SOURCE_PATH" "$DESTIONATION_PATH"
  else
    echo "[WARNING]: File $SOURCE_PATH does not exist. IGNORING"
  fi
}

configure_tmux(){
  local BACKUP_CONF_FILES_DIR="$1"  # $1: Backup directory where the configuration files are
  local TMUX_COLOR="$2"             # $2: Color, e.g. "colour220". If present, treat as server and set fg and bg colors

  confstart "tmux"

  cp $BACKUP_CONF_FILES_DIR/tmux.conf $HOME/.tmux.conf
  mkdir -p ~/.tmux_plugins
  cd ~/.tmux_plugins
  if [ ! -d tmux-better-mouse-mode ]; then
    git clone https://github.com/NHDaly/tmux-better-mouse-mode.git
  fi
  cd -

  if [ $# == 2 ]; then
    sed -i "/# set -g pane-active-border-fg colour220/c\set -g pane-active-border-fg $TMUX_COLOR" $HOME/.tmux.conf
    sed -i "/# set -g status-bg colour220/c\set -g status-bg $TMUX_COLOR" $HOME/.tmux.conf
  fi
  
  confend "tmux"
}

configure_vim(){
  confstart "vim"

  mkdir -p $HOME/.vim
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  git clone https://github.com/flazz/vim-colorschemes
  mv vim-colorschemes/colors $HOME/.vim/
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
  local BACKUP_CONF_FILES_DIR="$1"  # $1: Backup directory where the configuration files are

  confstart "sublime"

  local CONFIGS_DIR="$HOME/.config/sublime-text/Packages/User"
  local PACKAGES_FILE="$CONFIGS_DIR/Package Control.sublime-settings"
  local INSTALLED_PACKDIR="$HOME/.config/sublime-text/Installed Packages"

  mkdir -p "$CONFIGS_DIR"

  # Install the configuration files
  safecp "$BACKUP_CONF_FILES_DIR/Preferences.sublime-settings" "$CONFIGS_DIR"  # General settings
  safecp "$BACKUP_CONF_FILES_DIR/Default (Linux).sublime-keymap" "$CONFIGS_DIR"  # Keyboard shortcuts
  safecp "$BACKUP_CONF_FILES_DIR/Python.sublime-settings" $CONFIGS_DIR  # Python-specfic settings
  safecp "$BACKUP_CONF_FILES_DIR/XML.sublime-settings" $CONFIGS_DIR  # XML-specific settings
  safecp "$BACKUP_CONF_FILES_DIR/PythonBreakpoints.sublime-settings" $CONFIGS_DIR  # Python-breakpoints settings

  # Install package control
  wget https://packagecontrol.io/Package%20Control.sublime-package
  mkdir -p "$INSTALLED_PACKDIR"
  mv Package\ Control.sublime-package "$INSTALLED_PACKDIR/"

  # Set up packages which will automatically be installed on next sublime startup
  safecp "$COMMON_DIRPATH/sublime_packages.json" "$PACKAGES_FILE"

  confend "sublime"
}

configure_redshift(){
  local BACKUP_CONF_FILES_DIR="$1"  # Backup directory where the configuration file is

  safecp $BACKUP_CONF_FILES_DIR/redshift.conf $HOME/.config/
}
