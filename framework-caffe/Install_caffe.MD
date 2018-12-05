Source: Dr. Gia

## Requirement
1. CUDA 8.0
2. Dependencies 
```
sudo apt-get install -y libprotobuf-dev libleveldb-dev \
  libsnappy-dev libboost-all-dev libhdf5-serial-dev \
  libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler \
  libyaml-dev liblapack-dev libopenblas-dev libpython-dev
```
## Installation/Compilation
```
cd caffe
mkdir build; cd build
cmake -D BLAS=open ..
make all -j $(nproc)
make install
```


# error No module named skimage.io
https://github.com/yahoo/open_nsfw/issues/13

