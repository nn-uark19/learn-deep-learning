#!/usr/bin/env bash
# Test script for checking if Cuda and Drivers correctly installed on Ubuntu 16.04, by Roelof Pieters (@graphific)
# BSD License

if [ "$(whoami)" == "root" ]; then
  echo "running as root, please run as user you want to have stuff installed as"
  exit 1
fi
###################################
#   Ubuntu 16.04 Install script for:
# - Nvidia graphic drivers for Titan X: 352
# - Cuda 8.0
# - CuDNN 6.0
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

# started with a bare ubuntu 16.04.3 LTS install, with only ubuntu-desktop installed
# script will install the bare minimum, with all "extras" in a seperate venv

export DEBIAN_FRONTEND=noninteractive

# Checking cuda installation
# installing the samples and checking the GPU
cd /usr/local/cuda-8.0/samples/1\_Utilities/deviceQuery
sudo make

#Samples installed and GPU(s) Found ?
./deviceQuery  | grep "Result = PASS"
greprc=$?
if [[ $greprc -eq 0 ]] ; then
    echo "Cuda Samples installed and GPU found"
    echo "you can also check usage and temperature of gpus with nvidia-smi"
else
    if [[ $greprc -eq 1 ]] ; then
        echo "Cuda Samples not installed, exiting..."
        exit 1
    else
        echo "Some sort of error, exiting..."
        exit 1
    fi
fi

echo "now would be time to install cudnn for a speedup"
echo "unfortunately only available by registering on nvidias website:"
echo "https://developer.nvidia.com/cudnn"

# Install CUDNN
cd ~/Softwares
tar -xvf cudnn-8.0-linux-x64-v6.0.tgz
sudo cp cuda/include/*.h /usr/local/cuda/include
sudo cp -av cuda/lib64/*.* /usr/local/cuda/lib64

echo "deep learning libraries can be installed with final script #3"

