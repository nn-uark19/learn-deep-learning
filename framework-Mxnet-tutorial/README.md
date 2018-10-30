###################### 
# Tutorial

Source: 
	https://www.youtube.com/watch?v=GBkOMtc9BIk&t=499s
	https://github.com/zackchase/mxnet-the-straight-dope
	content: https://gluon.mxnet.io/

Install: for cpu
	sudo pip install --upgrade pip
	pip install jupyter --user
	pip install mxnet --pre --user
For GPU
	pip install mxnet-cu90
	pip install mxnet-cu75 --pre --user
	pip install mxnet-cu80 --pre --user


Check mxnet version and file
	import mxnet
	print(mxnet.__version__)
	print(mxnet.__file__)

NDArray: check the context (cpu/gpu)
	print(x_gpu.context)



========================================

Source: https://www.youtube.com/watch?v=DSNvm29kIAo
- From video: https://github.com/llSourcell/MXNet

Installation:
- Conda: conda create --name mxnetGpu python=3.6
- Install:

Jupyter notebook importing mxnet
- source: https://stackoverflow.com/questions/34389029/cannot-import-modules-in-jupyter-notebook-wrong-sys-path
- test this in both Jupyter notebook and terminal Python : 
	import sys
	sys.executable


# MXNet
This is the code for "Amazon's MXNet Deep Learning Framework" By Siraj Raval on Youtube


This is the code for [this](https://youtu.be/DSNvm29kIAo) video on Youtube by Siraj Raval on MXNet. Credits for the MXNet API go to Amazon 
