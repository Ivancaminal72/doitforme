#!/bin/bash
set -e
rm -rf ~/datasets/kitti/logs_download/* && mkdir -p ~/datasets/kitti/logs_download && cd ~/datasets/kitti
files=(
"devkit_odometry"
"data_odometry_poses"
"data_odometry_calib"
"data_odometry_gray"
"data_odometry_color"
"data_odometry_velodyne"
)

for file in ${files[@]}; do
	rm -rf ~/datasets/kitti/${file}/*
	echo "Downloading: ${file}"
	wget -O ${file}.zip "https://s3.eu-central-1.amazonaws.com/avg-kitti/${file}.zip" > ./logs_download/dw_${file}.txt 2>&1 && mkdir ${file} && unzip -o -d "./${file}/" ${file}.zip > ./logs_download/xz_${file}.txt 2>&1  && rm -f ${file}.zip &
done