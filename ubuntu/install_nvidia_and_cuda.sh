#!/bin/bash

NVIDIA_VERSION=nvidia-375

sudo service lightdm stop
sudo echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
sudo echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

# Install nvidia
sudo apt-get update
sudo apt-get install -y $NVIDIA_VERSION

# Download CUDA
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb
# wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb

# Install CUDA
sudo dpkg -i cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get install -y cuda

# Setup paths
echo 'export CUDA_HOME=/usr/local/cuda-8.0' >> ~/.bashrc
echo 'export PATH=${CUDA_HOME}/bin:${PATH}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=${CUDA_HOME}/lib64' >> ~/.bashrc
source ~/.bashrc

# TODO: Update the version of CUDA that you install
# NOTE: Use cudnn v6 NOT v7. v7 is not supported by TF
wget https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v7/prod/8.0_20170802/cudnn-8.0-linux-x64-v6-tgz
tar xvzf cudnn-8.0-linux-x64-v6.0.tgz
sudo cp -P cuda/include/cudnn.h $CUDA_HOME/include
sudo cp -P cuda/lib64/libcudnn* $CUDA_HOME/lib64
sudo chmod a+r $CUDA_HOME/include/cudnn.h $CUDA_HOME/lib64/libcudnn*

