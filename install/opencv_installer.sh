#!/bin/bash

#PARAMETERS
# version=3.2.0
version=4.2.0
project=opencv
mkdir -p $HOME/workspace/phd/${project}${version}/ && cd $HOME/workspace/phd/${project}${version}/

#Downlaod
wget https://github.com/opencv/opencv/archive/${version}.tar.gz
tar -xzvf ${version}.tar.gz
rm -f ${version}.tar.gz
wget https://github.com/opencv/opencv_contrib/archive/${version}.tar.gz
tar -xzvf ${version}.tar.gz
rm -f ${version}.tar.gz

#Build (remote host?)
cd opencv-${version}/
mkdir build && cd build
# cmake-gui >> configure >> add contrib path >> configure >> tick all OFF >> prefix & release >> generate
# cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/local/${project}_${version} \
#     -DOPENCV_EXTRA_MODULES_PATH=$HOME/workspace/phd/opencv/${project}_contrib-${version}/modules/ \
#     -DENABLE_PRECOMPILED_HEADERS=OFF \
#     -DBUILD_opencv_aruco=OFF \
#     -DBUILD_opencv_bgsegm=OFF \
#     -DBUILD_opencv_bioinspired=OFF \
#     -DBUILD_opencv_ccalib=OFF \
#     -DBUILD_opencv_cnn_3dobj=OFF \
#     -DBUILD_opencv_contrib_world=OFF \
#     -DBUILD_opencv_cvv=OFF \
#     -DBUILD_opencv_datasets=OFF \
#     -DBUILD_opencv_dnn=OFF \
#     -DBUILD_opencv_dnns_easily_fooled=OFF \
#     -DBUILD_opencv_dpm=OFF \
#     -DBUILD_opencv_face=OFF \
#     -DBUILD_opencv_fuzzy=OFF \
#     -DBUILD_opencv_freetype=OFF \
#     -DBUILD_opencv_hdf=OFF \
#     -DBUILD_opencv_line_descriptor=OFF \
#     -DBUILD_opencv_matlab=OFF \
#     -DBUILD_opencv_optflow=OFF \
#     -DBUILD_opencv_plot=OFF \
#     -DBUILD_opencv_reg=OFF \
#     -DBUILD_opencv_rgbd=OFF \
#     -DBUILD_opencv_saliency=OFF \
#     -DBUILD_opencv_sfm=OFF \
#     -DBUILD_opencv_stereo=OFF \
#     -DBUILD_opencv_structured_light=OFF \
#     -DBUILD_opencv_surface_matching=OFF \
#     -DBUILD_opencv_text=OFF \
#     -DBUILD_opencv_tracking=OFF \
#     -DBUILD_opencv_xfeatures2d=ON \
#     -DBUILD_opencv_ximgproc=OFF \
#     -DBUILD_opencv_xobjdetect=OFF \
#     -DBUILD_opencv_xphoto=OFF
#
# srun -p gpi.develop --mem 20G -c12 make -j12
# srun -p gpi.develop --mem 20G -c12 make -j12 install

make -j$(nproc)
make install -j$(nproc)
