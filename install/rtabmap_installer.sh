#!/bin/bash

#PARAMETERS
# version=0.17.1-0
version=0.19.3-2
project=rtabmap-release
# distro=kinetic
distro=melodic

#Downlaod
# cd $HOME/workspace/phd/rtabmap/
# git clone https://github.com/introlab/${project}.git
# mv ${project}/ ${project}_${distro}_${version}/
# cd ${project}_${distro}_${version}/
# git checkout release/${distro}/rtabmap/${version}
# mv .git/ .git2/ #deactivate (multirepo w/ possible future modifications)

#Build (remote host?)
cd $HOME/workspace/phd/rtabmap/${project}_${distro}_${version}/
if ! [ -d ./build/ ]; then
    mkdir build
else
    rm -rf ./build/*
fi
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/local/${project}_${distro}_${version} -DWITH_FREENECT=OFF -DWITH_FREENECT2=OFF -DWITH_QT=OFF -DBUILD_TOOLS=OFF -DBUILD_EXAMPLES=OFF | tee -a ./cmake_stdout.log
srun -p gpi.develop --mem 20G -c12 make -j12
srun -p gpi.develop --mem 20G -c12 make -j12 install
