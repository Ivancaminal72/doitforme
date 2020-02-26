#!/bin/bash

#PARAMETERS
#version=0.17.1-0
version=0.19.3-2
project=rtabmap-release
#distro=kinetic
distro=melodic

#Downlaod (local/remote)
cd $HOME/workspace/phd/rtabmap/
git clone https://github.com/introlab/${project}.git
mv ${project}/ ${project}_${distro}_${version}/
cd ${project}_${distro}_${version}/
git checkout release/${distro}/rtabmap/${version}
mv .git/ .git2/ #deactivate (multirepo w/ possible future modifications)

#Remote build (after local upload)
# cd $HOME/workspace/phd/rtabmap/${project}_${distro}_${version}/
# mkdir build && cd build
# cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/local/${project}_${distro}_${version} -DWITH_FREENECT=OFF -DWITH_FREENECT2=OFF -DWITH_QT=OFF -DBUILD_TOOLS=OFF -DBUILD_EXAMPLES=OFF
# srun -p gpi.develop --mem 20G -c12 make -j12 #gpic03 - OK
# srun -p gpi.develop --mem 20G -c12 make -j12 install