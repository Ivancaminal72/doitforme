#!/bin/bash
#Execution time ~12h
set -e

if [[ $1 == --h* ]] || [[ $1 == "" ]]; then
	echo -e "Usage: $0 {datasets_directory} (creates kitti folder)"; exit; fi;
if [[ ! -d $1 ]]; then echo "Invalid $1"; exit 1; fi;
if [[ ! -w $1 ]]; then echo "User doesn't have write persmision to $1"; exit 1; fi;
dataset_dir="${1%/}/kitti"
if [[ -d $dataset_dir ]]; then echo "Already exists $dataset_dir (delete it)"; exit 1; fi;
mkdir -p $dataset_dir/logs_download && cd $dataset_dir
files=(
"devkit_odometry"
"data_odometry_poses"
"data_odometry_calib"
"data_odometry_gray"
"data_odometry_color"
"data_odometry_velodyne"
)

for file in ${files[@]}; do
	rm -rf $dataset_dir/${file}/*
	echo "Downloading: ${file}"
	wget -O ${file}.zip "https://s3.eu-central-1.amazonaws.com/avg-kitti/${file}.zip" > ./logs_download/dw_${file}.txt 2>&1 && mkdir ${file} && unzip -o -d "./${file}/" ${file}.zip > ./logs_download/xz_${file}.txt 2>&1  && rm -f ${file}.zip &
done

wait #until download jobs finish
echo "Reorganizing dirs structure"
mv devkit_odometry/devkit/ .
mv data_odometry_poses/dataset/poses/ .
rsync -av --remove-source-files ./data_odometry_velodyne/dataset/sequences/ ./data_odometry_color/dataset/sequences/ > ./logs_download/rg_velodyne-color.txt 2>&1 &
rsync -av --remove-source-files ./data_odometry_gray/dataset/sequences/ ./data_odometry_color/dataset/sequences/ > ./logs_download/rg_gray-color.txt 2>&1 &
rsync -av --remove-source-files ./data_odometry_calib/dataset/sequences/ ./data_odometry_color/dataset/sequences/ > ./logs_download/rg_calib-color.txt 2>&1 &
wait
mv data_odometry_color/dataset/sequences/ .
rm -rf devkit_odometry/
rm -rf data_odometry_poses/
rm -rf data_odometry_calib/
rm -rf data_odometry_gray/
rm -rf data_odometry_color/
rm -rf data_odometry_velodyne/
echo "OK!"



