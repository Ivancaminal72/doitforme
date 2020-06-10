#!/bin/bash
#Execution time ~12h
set -e

if [[ $1 == --h* ]] || [[ $1 == "" ]]; then
	echo -e "Usage: $0 {datasets_directory} (creates a2d2 folder)"; exit; fi;
if [[ ! -d $1 ]]; then echo "ERROR: Invalid directory $1"; exit 1; fi;
if [[ ! -w $1 ]]; then echo "ERROR: User doesn't have write persmision at $1"; exit 1; fi;
dataset_dir="${1%/}/a2d2"
if [[ -d $dataset_dir ]]; then
	read -p "Already exists $dataset_dir, do you wish to proceed?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
fi

mkdir -p $dataset_dir/logs_download && cd $dataset_dir
hostName="https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com"

#Download info
wget $hostName/tutorial.ipynb -O ./tutorial.ipynb
wget $hostName/cams_lidars.json -O ./cams_lidars.json
wget $hostName/README.txt -O ./README.txt
wget $hostName/README-SemSeg.txt -O ./README-SemSeg.txt
wget $hostName/README-3DBoxes.txt -O ./README-3DBoxes.txt
wget $hostName/README-SensorFusion.txt -O ./README-SensorFusion.txt

#Download data
declare -a files

# #Semantic segmentation
# files+=(
# "camera_lidar_semantic.tar"
# "camera_lidar_semantic_instance.tar"
# "camera_lidar_semantic_bus.tar"
# )
# 
# #3D Object Detection
# files+=(
# "camera_lidar_semantic_bboxes.tar"
# )

#Sensor Fusion - Gaimersheim
files+=(
"camera_lidar-20180810150607_lidar_frontcenter.tar"
"camera_lidar-20180810150607_camera_frontcenter.tar"
"camera_lidar-20180810150607_bus_signals.tar"
)

for file in ${files[@]}; do
	name=${file: 0:-4}
	rm -rf $dataset_dir/${name}/*
	echo "Downloading & extracting: ${file}"
	mkdir ${name} && wget -q -O - "https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/${file}" | tar xv -C $dataset_dir/$name > ./logs_download/dw_${name}.txt 2>&1 &
done

wait #until download jobs finish
echo "OK!"



