#!/usr/bin/env bash
# Installation script for Deep Learning Dev-Tools on Ubuntu 14.04, modified by Gia
# BSD License

orig_executor="$(whoami)"
if [ "$(whoami)" == "root" ]; then
  echo "running as root, please run as user you want to have stuff installed as"
  exit 1
fi
###################################
#   Ubuntu 14.04 Install script for:
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
# - Pycharm
###################################

####################################
# Pycharm
####################################
# installing pycharm

cd ~/Softwares
wget https://download-cf.jetbrains.com/python/pycharm-community-2018.2.2.tar.gz
sudo tar -xvf pycharm-community-2018.2.2.tar.gz -C /opt/
cd /opt/pycharm-community-2018.2.2/bin
./pycharm.sh
echo -e "\nexport PATH=$PATH:/opt/pycharm-community-2018.2.2/bin" >> ~/.bashrc
source ~/.bashrc
