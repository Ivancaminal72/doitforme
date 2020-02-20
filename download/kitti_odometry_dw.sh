#!/bin/bash
set -e 
cd ~/datasets
links=(
"https://s3.eu-central-1.amazonaws.com/avg-kitti/devkit_odometry.zip"
"https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_poses.zip"
"https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_calib.zip"
"https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_gray.zip"
"https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_color.zip"
"https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_velodyne.zip"
)

for idx in ${!links[@]}; do
	echo "Downloading link: $idx"
	wget -O $idx.zip ${links[$idx]} > log_$idx.txt 2>&1 && unzip -q $idx.zip && rm $idx.zip &
done