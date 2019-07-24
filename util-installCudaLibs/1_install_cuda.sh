#!/usr/bin/env bash
# Installation script for Cuda and drivers on Ubuntu 16.04, modified by Gia
# BSD License
if [ "$(whoami)" == "root" ]; then
  echo "running as root, please run as user you want to have stuff installed as"
  exit 1
fi
###################################
#   Ubuntu 16.04 Install script for:
# - Nvidia graphic drivers for Titan X: 352
# - Cuda 8.0
# - CuDNN6
# - Tensorflow 1.4 (Latest as of 01/24/2018)
# - Torch7, pyTorch
# - ipython notebook (running as service with circus auto(re)boot on port 8888)
# - itorch notebook (running as service with circus auto(re)boot on port 8889)
# - Caffe (pycaffe)
# - OpenCV 3.x release (Latest 01/24/2018)
# - Digits
# - Lasagne
# - Nolearn
# - Keras
# - Theano
###################################

# started with a bare ubuntu 16.04.5 LTS install, with only ubuntu-desktop installed
# script will install the bare minimum, with all "extras" in a seperate venv

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y

# Install Compiling Essential PKG
sudo apt-get install -y linux-image-generic build-essential unzip cmake pkg-config

# Setup SSH
sudo apt-get install -y openssh-server
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
sudo chmod a-w /etc/ssh/sshd_config.factory-defaults

# Install CURL, WGET
sudo apt-get install -y wget curl

# Install GIT
sudo apt-get install -y git

# Install Text Editors
sudo apt-get install -y vim gedit

# Install Terminal Multiplexer
sudo apt-get install -y tmux

# Install Process Manager
sudo apt-get install -y htop

# Install Open-Terminal in Nautilus
sudo apt-get install -y nautilus-open-terminal

# manual driver install with:
# sudo service lightdm stop
# (login on non graphical terminal)
# wget http://uk.download.nvidia.com/XFree86/Linux-x86_64/375.26/NVIDIA-Linux-x86_64-375.26.run
# chmod +x ./NVIDIA-Linux-x86_64-352.30.run
# sudo ./NVIDIA-Linux-x86_64-352.30.run

# Cuda 8.0
# instead we install the nvidia driver 375 from the cuda repo
# which makes it easier than stopping lightdm and installing in terminal

mkdir ~/Softwares

cd ~/Softwares
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
#wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
sudo apt-get update
sudo apt-get install -y cuda

wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb
#wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda-repo-ubuntu1404-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb
sudo apt-get update
sudo apt-get install -y cuda-repo-ubuntu1604-8-0-local-cublas-performance-update

echo -e "\nexport CUDA_HOME=/usr/local/cuda\nexport CUDA_ROOT=/usr/local/cuda" >> ~/.bashrc
echo -e "\nexport PATH=/usr/local/cuda/bin:\$PATH\nexport LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc

echo "CUDA installation complete: please reboot your machine and continue with script #2"
