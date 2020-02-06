#!/bin/bash

#PARAMETERS
out_dir=$1
if [ ! -d "$out_dir" ]; then echo "ERROR: Invalid experiments output directory: $out_dir"; exit -1; fi
group=`basename $out_dir`
res_dir="$HOME/important/phd/metrics/rtab/kitti/$group"
plots_dir="$res_dir/plots_ate_rtab_kitti_$group"

#RESET RESULTS
rm -rf $res_dir/*
mkdir -p $plots_dir/

#ITERATE SEQUENCES
find $out_dir -maxdepth 1 -type d -print0 | #list seq dirs
while IFS= read -r -d '' line; do 
    seq=`basename "$line"`
	seq_dir=$out_dir/$seq
	
	echo -e "\n\n""Evaluating ate sequence: $seq_dir"

	find $seq_dir -maxdepth 1 -type f -print0 | #list all files
	while IFS= read -r -d '' in_file; do
		
		if [[ ! $in_file =~ poses_* ]]; then continue; fi; #Skip non-pose files
		
		#Get properties
		in_name=`basename $in_file`
		props={in_name:6:-4} #remove head "poses_" and tail ".txt"
		IFS='_'; read -r -a props_a <<< $props; unset IFS; #Parse into array
		
		#Get depth_scale
		depth_scale=""; #default none
		if [[ ${props_a[-1]} =~ scale-* ]]; then depth_scale="--scale ${props_a[-1]:6}"; fi; done; 
	
		#Evaluate and save results
		plot_file="$plots_dir/plot_rtab_kitti_$props.png"
		res_file="$res_dir/ate_rtab_kitti_$group.csv"
		printf "${props};" | tee -a ${res_file}
		python ~/workspace/phd/metrics/evaluate_ate.py --verbose $depth_scale $HOME/datasets/kitti/poses/${seq}_freiburg.txt ${in_file} --plot ${plot_file} | tee -a ${res_file}
		printf "\n" | tee -a ${res_file};
		
	done
done