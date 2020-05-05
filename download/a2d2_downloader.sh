#!/bin/bash
#Execution time ~12h
set -e

if [[ $1 == --h* ]] || [[ $1 == "" ]]; then
	echo -e "Usage: $0 /path/to/datasets (creates dir)"; exit; fi;
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

#Download info
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/tutorial.ipynb
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/cams_lidars.json
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/README.txt
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/README-SemSeg.txt
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/README-3DBoxes.txt
wget https://aev-autonomous-driving-dataset.s3.eu-central-1.amazonaws.com/README-SensorFusion.txt

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



