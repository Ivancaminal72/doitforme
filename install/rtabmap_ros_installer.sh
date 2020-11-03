#!/bin/bash

#PARAMETERS
# version=0.17.1-0
version=0.19.3-1
project=rtabmap_ros
# distro=kinetic
distro=melodic
cd $HOME/workspace/ros_ddd

#Download
# wstool init src
# rosinstall_generator ${project} --deps --wet-only --exclude RPP libg2o octomap octomap_msgs rtabmap > deps_rtabmap.rosinstall
# wstool merge -t src deps_rtabmap.rosinstall
# wstool update -t src
# cd src
# mv ${project}/ ${project}_${distro}_${version}/
# cd ${project}_${distro}_${version}/
# git checkout release/${distro}/${project}/${version}
# mv .git/ .git2/ #deactivate (multirepo w/ possible future modifications)

#Build (remote host?)
catkin_make -j$(nproc)
catkin_make -j$(nproc) install
