#!/bin/bash

#PARAMETERS
# version=0.17.1-0
# version=0.19.3-1
version=0.20.10-1
project=rtabmap_ros
# distro=kinetic
# distro=melodic
distro=noetic
roscd && cd ..

#Download
wstool init src
rosinstall_generator ${project} --deps --wet-only --exclude RPP libg2o octomap octomap_msgs rtabmap > rosinstall_rtabmap.rosinstall
wstool merge -t src rosinstall_rtabmap.rosinstall
wstool update -t src
cd src
mv ${project}/ ${project}_${distro}_${version}/
cd ${project}_${distro}_${version}/
git checkout release/${distro}/${project}/${version}
mv .git/ .git2/ #deactivate (multirepo w/ possible future modifications)

#Build (remote host?)
catkin_make -j$(nproc)
catkin_make -j$(nproc) install

#Test
# roslaunch rtabmap_ros rtabmap.launch rviz:=true rtabmapviz:=false rgb_topic:=/data_throttled_image depth_topic:=/data_throttled_image_depth camera_info_topic:=/data_throttled_camera_info compressed:=true frame_id:=openni_camera_link database_path:=/dev/null
# roslaunch rtabmap_ros rgbd_mapping.launch rviz:=true rtabmapviz:=false rgb_topic:=/data_throttled_image depth_registered_topic:=/data_throttled_image_depth camera_info_topic:=/data_throttled_camera_info compressed:=true frame_id:=openni_camera_link
# roslaunch rtabmap_ros rgbd_mapping.launch rviz:=true rviz_cfg:=/home/icaminal/workspace/ros_ddd/rviz/rtabmap_kitti.rviz rtabmapviz:=false rgb_topic:=/cam02 depth_registered_topic:=/cam02_depth camera_info_topic:=/camera_info frame_id:=lidar database_path:=/tmp/rtabmap.db approx_sync:=false
