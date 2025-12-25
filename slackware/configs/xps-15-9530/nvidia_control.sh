#!/bin/bash

nvidia_help(){
    echo "$0 [options]"
    echo
    # echo "  start"
    # echo "      Start the nvidia graphics card"
    # echo "  stop"
    # echo "      Safely stop the nvidia graphics card"
    # echo "  restart"
    # echo "      Restart the nvidia graphics card"
    echo "  load_driver"
    echo "      Load the nvidia driver"
    echo "  unload_driver"
    echo "      Unload the nvidia driver"
    echo "  reload_driver"
    echo "      Reload the nvidia driver"
    echo "  status"
    echo "      Display the current status of the card - ON/OFF"
    echo "  --help"
    echo "      Display this message"
}

nvidia_load_driver(){
    sudo modprobe nvidia
    sudo modprobe nvidia_modeset
    sudo modprobe nvidia_drm
    sudo modprobe nvidia_uvm
    sudo /usr/bin/nvidia-modprobe -c 0 -u
}

nvidia_unload_driver(){
    # check if nvidia_drm is loaded
    if [ "$(lsmod | grep nvidia_drm)" != "" ]; then
        sudo rmmod nvidia_drm
    fi
    # check if nvidia_uvm is loaded
    if [ "$(lsmod | grep nvidia_uvm)" != "" ]; then
        sudo rmmod nvidia_uvm
    fi
    # check if nvidia_modeset is loaded
    if [ "$(lsmod | grep nvidia_modeset)" != "" ]; then
        sudo rmmod nvidia_modeset
    fi
    # check if nvidia is loaded
    if [ "$(lsmod | grep nvidia)" != "" ]; then
        sudo rmmod nvidia
    fi
}

nvidia_start(){
    #sudo modprobe bbswitch
    sudo tee /proc/acpi/bbswitch <<<ON
    cat /proc/acpi/bbswitch
    nvidia_load_driver
}

nvidia_stop(){
    # Unload all nvidia modules
    nvidia_unload_driver

    # Stop the nvidia card
    sudo tee /proc/acpi/bbswitch <<<OFF
    cat /proc/acpi/bbswitch
}


if [ $# -eq 0 ] || [ "$1" == "--help" ]; then
    nvidia_help
# elif [ "$1" == "stop" ]; then
#     nvidia_stop
# elif [ "$1" == "start" ]; then
#     nvidia_start
# elif [ "$1" == "restart" ]; then
#     nvidia_stop
#     nvidia_start
elif [ "$1" == "load_driver" ]; then
    nvidia_load_driver
elif [ "$1" == "unload_driver" ]; then
    nvidia_unload_driver
elif [ "$1" == "reload_driver" ]; then
    nvidia_unload_driver
    nvidia_load_driver
elif [ "$1" == "status" ]; then
    cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
    # if [ "$(lsmod | grep bbswitch)" != "" ]; then
    #     cat /proc/acpi/bbswitch
    # else
    #     echo "Error: bbswitch kernel module not loaded"
    # fi
# elif [ "$1" == "watch" ]; then
#     watch primusrun nvidia-smi
#     # Alternative version of displaying
#     # watch primusrun nvidia-smi -q -d temperature
else
    nvidia_help
fi



# nvidia(){
#     if [ "$1" == "stop" ]; then
#         nvidia_stop
#     elif [ "$1" == "start" ]; then
#         nvidia_start
#     elif [ "$1" == "restart" ]; then
#         nvidia_stop
#         nvidia_start
#     elif [ "$1" == "status" ]; then
#         if [ "$(lsmod | grep bbswitch)" != "" ]; then
#             cat /proc/acpi/bbswitch
#         fi
#     elif [ "$1" == "watch" ]; then
#         watch primusrun nvidia-smi
#         # alternative version of displaying
#         #watch primusrun nvidia-smi -q -d temperature
#     else
#         echo bumblebee error: Invalid argument
#     fi
# }

