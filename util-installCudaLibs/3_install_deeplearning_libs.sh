#!/usr/bin/env bash
# Installation script for Deep Learning Libraries on Ubuntu 14.04, by Roelof Pieters (@graphific)
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
###################################

export DEBIAN_FRONTEND=noninteractive
#sudo apt-get install -y libncurses-dev

# next part copied from (check there for newest version): 
# https://github.com/deeplearningparis/dl-machine/blob/master/scripts/install-deeplearning-libraries.sh

####################################
# Dependencies
####################################

# Build latest stable release of OpenBLAS without OPENMP to make it possible
# to use Python multiprocessing and forks without crash
# The torch install script will install OpenBLAS with OPENMP enabled in
# /opt/OpenBLAS so we need to install the OpenBLAS used by Python in a
# distinct folder.
# Note: the master branch only has the release tags in it
if [ ! -d "Libraries" ]; then
	mkdir ~/Libraries
fi

sudo apt-get install -y gfortran
export OPENBLAS_ROOT=/opt/OpenBLAS-no-openmp
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OPENBLAS_ROOT/lib

cd ~/Libraries/

if [ ! -d "OpenBLAS" ]; then
    git clone -q --branch=master git://github.com/xianyi/OpenBLAS.git ~/Libraries/OpenBLAS
    (cd ~/Libraries/OpenBLAS \
      && make FC=gfortran USE_OPENMP=0 NO_AFFINITY=1 NUM_THREADS=$(nproc) \
      && sudo make install PREFIX=$OPENBLAS_ROOT)
    echo "export OPENBLAS_ROOT=/opt/OpenBLAS-no-openmp" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OPENBLAS_ROOT/lib" >> ~/.bashrc
fi
sudo ldconfig

cd ~/
# Python basics: update pip and setup a virtualenv to avoid mixing packages
# installed from source with system packages
sudo apt-get update -y 
sudo apt-get install -y python-dev python-pip
sudo pip install -U pip virtualenv
if [ ! -d "venv_all" ]; then
    virtualenv venv_all
    echo "source ~/venv_all/bin/activate" >> ~/.bashrc
fi
source venv_all/bin/activate
pip install -U pip
pip install -U Cython Pillow # circus circus-web

# Checkout this project to access installation script and additional resources
cd ~/Libraries

if [ ! -d "dl-machine" ]; then
    git clone https://github.com:deeplearningparis/dl-machine.git ~/Libraries/dl-machine
    (cd ~/Libraries/dl-machine && git remote add http https://github.com/deeplearningparis/dl-machine.git)

	# Build numpy from source against OpenBLAS
	# You might need to install liblapack-dev package as well
	# sudo apt-get install -y liblapack-dev
	rm -f ~/.numpy-site.cfg
	ln -s ~/Libraries/dl-machine/numpy-site.cfg ~/.numpy-site.cfg
	pip install -U numpy

	# Build scipy from source against OpenBLAS
	rm -f ~/.scipy-site.cfg
	ln -s ~/Libraries/dl-machine/scipy-site.cfg ~/.scipy-site.cfg
	pip install -U scipy

	# Install common tools from the scipy stack
	sudo apt-get install -y libfreetype6-dev libpng12-dev
	pip install -U matplotlib ipython[all] pandas scikit-image

	# Scikit-learn (generic machine learning utilities)
	pip install -e git+git://github.com/scikit-learn/scikit-learn.git#egg=scikit-learn

else
    if  [ "$1" == "reset" ]; then
        (cd ~/Libraries/dl-machine && git reset --hard && git checkout master && git pull --rebase $REMOTE master)
    fi
fi


####################################
# OPENCV 3
####################################
# from http://rodrigoberriel.com/2014/10/installing-opencv-3-0-0-on-ubuntu-14-04/
# for 2.9 see http://www.samontab.com/web/2014/06/installing-opencv-2-4-9-in-ubuntu-14-04-lts/ 
cd ~/Libraries

sudo apt-get -y install libgtk2.0-dev \
   pkg-config python-numpy libdc1394-22 libdc1394-22-dev libjpeg-dev \
   libpng12-dev libtiff4-dev libjasper-dev libavcodec-dev libavformat-dev \
   libswscale-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
   libv4l-dev libtbb-dev libqt4-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev \
   libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils unzip

if [ ! -d "opencv" ]; then
	#wget https://github.com/Itseez/opencv/archive/3.0.0.tar.gz -O opencv-3.0.0.tar.gz
	#tar -zxvf  opencv-3.0.0.tar.gz
	git clone -b 3.4.0 https://github.com/opencv/opencv	
	cd opencv
	mkdir build
	cd build

	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_QT=OFF -D WITH_OPENGL=ON -DWITH_IPP=ON -DINSTALL_CREATE_DISTRIB=OFF ..
	make -j
	sudo make install

	sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
	sudo ldconfig
	ln -s /usr/local/lib/python2.7/site-packages/cv2.so /home/$orig_executor/venv_all/lib/python2.7/site-packages/cv2.so

	echo "opencv 3.4 installed"
fi

####################################
# Theano
####################################
# installing theano
# By default, Theano will detect if it can use cuDNN. If so, it will use it. 
# To get an error if Theano can not use cuDNN, use this Theano flag: optimizer_including=cudnn.
cd ~/Libraries/

pip install -e git+git://github.com/Theano/Theano.git#egg=Theano
if [ ! -f ".theanorc" ]; then
    #ln -s ~/dl-machine/theanorc ~/.theanorc
    cp ~/Libraries/dl-machine/theanorc ~/.theanorc
fi

echo "Installed Theano"

####################################
# Torch
####################################

cd ~/Libraries/
if [ ! -d "torch" ]; then
    curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
    git clone https://github.com/torch/distro.git ~/Libraries/torch --recursive
    (cd ~/Libraries/torch && yes | ./install.sh)
fi
. ~/Libraries/torch/install/bin/torch-activate

cd ~/Libraries/
if [ ! -d "iTorch" ]; then
    git clone https://github.com:facebook/iTorch.git ~/Libraries/iTorch
    (cd ~/Libraries/iTorch && git remote add http https://github.com/facebook/iTorch.git)
else
    if  [ "$1" == "reset" ]; then
        (cd ~/Libraries/iTorch && git reset --hard && git checkout master && git pull --rebase $REMOTE master)
    fi
fi
(cd iTorch && luarocks make)

cd ~/Libraries/
git clone https://github.com/torch/demos.git torch-demos

#qt dependency
sudo apt-get install -y qt4-dev-tools libqt4-dev libqt4-core libqt4-gui

#main luarocks libs:
luarocks install image    # an image library for Torch7
luarocks install nnx      # lots of extra neural-net modules
luarocks install unup

echo "Installed Torch (demos in $HOME/torch-demos)"

# Register the circus daemon with Upstart
# if [ ! -f "/etc/init/circus.conf" ]; then
#    sudo ln -s $HOME/dl-machine/circus.conf /etc/init/circus.conf
#    sudo initctl reload-configuration
# fi
# sudo service circus restart



####################################
# pyTorch
####################################
cd ~/Libraries/

pip install http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp27-cp27mu-linux_x86_64.whl
pip install torchvision

## Next part ...
####################################
# Caffe
####################################

sudo apt-get install -y libprotobuf-dev libleveldb-dev \
  libsnappy-dev libboost-all-dev libhdf5-serial-dev \
  libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler \
  libyaml-dev libatlas-dev

cd ~/Libraries
if [ ! -d "caffe" ]; then
	git clone https://github.com/BVLC/caffe.git

	for req in $(cat python/requirements.txt); do pip install $req -U; done

	cd caffe
	cp ~/Libraries/dl-machine/Makefile.config.example Makefile.config

	# build using make
	make all -j
	make pycaffe -j
	make distribute

	# build using cmake
	mkdir build_cmake && cd build_cmake
	cmake -DBLAS=open .. && make all -j && make install -j
	cd -

	cd python
	pip install networkx -U
	pip install pillow -U
	pip install -r requirements.txt

	ln -s ~/Libraries/caffe/python/caffe ~/venv_all/lib/python2.7/site-packages/caffe
	echo -e "\nexport CAFFE_HOME=/home/$orig_executor/Libraries/caffe" >> ~/.bashrc
	echo -e "\nexport PYTHONPATH=$PYTHONPATH:~/Libraries/caffe/python" >> ~/.bashrc
fi
echo "Installed Caffe"

####################################
# Tensorflow
####################################

cd ~/Libraries

if [ ! -f "tensorflow_gpu-1.4.1-cp27-none-linux_x86_64.whl" ]; then
	wget https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.4.1-cp27-none-linux_x86_64.whl
fi

pip install --upgrade tensorflow_gpu-1.4.1-cp27-none-linux_x86_64.whl


####################################
# Digits
####################################

# Nvidia Digits needs a specific version of caffe
# so you can install the venv version by Nvidia uif you register
# with cudnn, cuda, and caffe already packaged
# instead we will install from scratch
cd ~/Libraries/
if [ ! -d "digits" ]; then
	git clone https://github.com/NVIDIA/DIGITS.git digits

	cd digits
	pip install -r requirements.txt

	sudo apt-get install -y graphviz
fi

echo "digits installed, run with ./digits-devserver or 	./digits-server"

####################################
# Lasagne
# https://github.com/Lasagne/Lasagne
####################################
# git clone https://github.com/Lasagne/Lasagne.git
# cd Lasagne
# python setup.py install

# echo "Lasagne installed"

####################################
# Nolearn
# asbtractions, mainly around Lasagne
# https://github.com/dnouri/nolearn
####################################
# git clone https://github.com/dnouri/nolearn
# cd nolearn
# pip install -r requirements.txt
# python setup.py install

# echo "nolearn wrapper installed"



####################################
# Keras
# https://github.com/fchollet/keras
# http://keras.io/
####################################
cd ~/Libraries/
if [ ! -d "keras" ]; then
	git clone https://github.com/fchollet/keras.git
	cd keras
	python setup.py install
fi

echo "Keras installed"


####################################
# Mx-Net
####################################
cd ~/Libraries/
if [ ! -d "mxnet" ]; then
	git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet --branch 1.3.0
	cd mxnet
	make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=/usr/local/cuda USE_CUDNN=1
	cd python
	pip install -e .
fi

echo "mxnet installed"


echo "all done, please restart your machine..."

#   possible issues & fixes:
# - Could not import cbook
pip install -U matplotlib
# - Couldn't import dot_parser, loading of dot files will not be possible." 
pip install -U pydot
# - Could not import sklearn
pip install -U numpy
# - skimage: issue with "not finding jpeg decoder?" 
# "PIL: IOError: decoder zip not available"
# (https://github.com/python-pillow/Pillow/issues/174)
# sudo apt-get install libtiff5-dev libjpeg8-dev zlib1g-dev \
#     libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
# next try:
# pip uninstall pillow
# git clone https://github.com/python-pillow/Pillow.git
# cd Pillow 
# python setup.py install
