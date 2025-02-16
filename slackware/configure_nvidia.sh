# DEPRECATED!!!

# DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# SLACK_BACKUP_DIR="$DIRPATH/configs"


# echo "-------------------------------------------------------------------------------"
# echo "------ Configuring rc.local"
# echo "-------------------------------------------------------------------------------"

# echo "" | sudo tee --append /etc/rc.d/rc.local
# echo "# Make bumblebeed start with the system" | sudo tee --append /etc/rc.d/rc.local
# echo "[ -x /etc/rc.d/rc.bumblebeed ] && /etc/rc.d/rc.bumblebeed start" | sudo tee --append /etc/rc.d/rc.local

# echo "" | sudo tee --append /etc/rc.d/rc.local
# echo "# Stop the nvidia card" | sudo tee --append /etc/rc.d/rc.local
# echo "/home/niko/bin/nvidia_control.sh stop" | sudo tee --append /etc/rc.d/rc.local


# echo "-------------------------------------------------------------------------------"
# echo "------ Configuring rc.local_shutdown"
# echo "-------------------------------------------------------------------------------"

# echo "" | sudo tee --append /etc/rc.d/rc.local_shutdown
# echo "# Make bumblebeed stop with the system" | sudo tee --append /etc/rc.d/rc.local_shutdown
# echo "[ -x /etc/rc.d/rc.bumblebeed ] && /etc/rc.d/rc.bumblebeed stop" | sudo tee --append /etc/rc.d/rc.local_shutdown


# echo "-------------------------------------------------------------------------------"
# echo "------ Configuring bbswitch"
# echo "-------------------------------------------------------------------------------"
# sudo touch /etc/modprobe.d/bbswitch.conf

# echo "options bbswitch load_state=0" | sudo tee --append /etc/modprobe.d/bbswitch.conf
# echo "options bbswitch unload_state=0" | sudo tee --append /etc/modprobe.d/bbswitch.conf

# echo "-------------------------------------------------------------------------------"
# echo "------ Configuring bumblebee"
# echo "-------------------------------------------------------------------------------"
# sudo chmod +x /etc/rc.d/rc.bumblebeed
# sudo cp $SLACK_BACKUP_DIR/bumblebee.conf /etc/bumblebee/bumblebee.conf


# echo "-------------------------------------------------------------------------------"
# echo "------ Starting bumblebee and stopping the card"
# echo "-------------------------------------------------------------------------------"
# sudo modprobe bbswitch
# sudo [ -x /etc/rc.d/rc.bumblebeed ]
# sudo /etc/rc.d/rc.bumblebeed start
# nvidia stop


