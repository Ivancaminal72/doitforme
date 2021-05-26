#!/bin/bash

#Dependencies
roscd && cd ../src
git clone https://github.com/ethz-asl/minkindr.git
#(optional) git checkout 5b9fe7f21b58510c0cd8c1ef1aef376f77001ffe
cd ..
wstool init src
sudo apt-get install libgflags-dev
cp src/minkindr/dependencies.rosinstall ~/workspace/ros_ddd/rosinstall_minkindr.rosinstall
wstool merge -t src rosinstall_minkindr.rosinstall
wstool update -t src
catkin_make --only-pkg-with-deps glog_catkin -j$(nproc) | tee logs/glog_catkin.txt
cd src
git clone https://github.com/ethz-asl/catkin_boost_python_buildtool.git
cd ..
catkin_make --only-pkg-with-deps catkin_boost_python_buildtool -j$(nproc) | tee logs/catkin_boost_python_buildtool.txt
cd src
git clone https://github.com/ethz-asl/numpy_eigen.git
cd ..
catkin_make --only-pkg-with-deps numpy_eigen -j$(nproc) | tee logs/numpy_eigen.txt
catkin_make -DCATKIN_WHITELIST_PACKAGES="" -j$(nproc) | tee logs/minkindr.txt
cd src
git clone https://github.com/ethz-asl/minkindr_ros.git
cd ..
catkin_make -DCATKIN_WHITELIST_PACKAGES="" -j$(nproc) | tee logs/minkindr_ros.txt
rm -f ~/workspace/ros_ddd/rosinstall_minkindr.rosinstall

#Downlaod & Build (remote host?)
# roscd && cd ../src
# git clone https://github.com/ethz-asl/kitti_to_rosbag.git
# #(optional) git checkout 24bf8a0a31a58058881e4ae42b8b73f139093ec5
# cd kitti_to_rosbag
# mv kitti_to_rosbag/* .
# rm -r kitti_to_rosbag/
# mv .git/ .git2/ #deactivate (multirepo w/ possible future modifications)

#Build (remote host?)
roscd && cd ..
catkin_make -DCATKIN_WHITELIST_PACKAGES="" -j$(nproc) | tee logs/kitti_to_rosbag.txt
