#!/bin/bash

#PARAMETERS
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then echo -e "Usage: $0 /path/to/experiments/output/directory"; exit; fi;
out_dir=${1%/}
if [ ! -d "$out_dir" ]; then echo "ERROR: Invalid experiments output directory: $out_dir"; exit -1; fi
group=`basename $out_dir`
res_dir="$HOME/important/phd/metrics/rtab/kitti/$group"
plots_dir="$res_dir/plots_ate_rtab_kitti_$group"
echo -e "Out_dir: $out_dir"
echo -e "GROUP: $group"
echo -e "res_dir: $res_dir"
echo -e "plots_dir: $plots_dir"

#RESET RESULTS
rm -rf $res_dir/*
mkdir -p $plots_dir/

#ITERATE EXPERIMENTS
find $out_dir -maxdepth 1 -type d -print0 | #list dirs
while IFS= read -r -d '' line; do
    if [[ $out_dir == $line ]]; then continue; fi; #skip parent dir 
    exp=`basename "$line"`
	exp_dir=$out_dir/$exp
	
	echo -e "\n\n""Evaluating ate experiments sequence: $exp_dir"

	find $exp_dir -maxdepth 1 -type f -print0 | #list all files
	while IFS= read -r -d '' in_file; do
		
		if [[ ! $in_file =~ poses_* ]]; then continue; fi; #Skip non-pose files
		
        echo -e "\n\n""Experiment: $in_file"
        
		#Get properties
		in_name=`basename $in_file`
		props=${in_name:6:-4} #remove head "poses_" and tail ".txt"
		IFS='_'; read -r -a props_a <<< $props; unset IFS; #Parse into array
        echo -e "In_file: $in_file"
        echo -e "in_name: $in_name"
        echo -e "props: $props"
        echo -e "props_a: ${props_a[@]}"
        echo -e "seq: ${props_a[1]}"
        echo -e "last: ${props_a[-1]}" 
        echo -e "seq: ${props_a[1]}"
		
		#Get depth_scale"
		depth_scale=""; #default none
		if [[ ${props_a[-1]} =~ scale-* ]]; then depth_scale="--scale ${props_a[-1]:6}"; fi;
	    
        echo -e "seq: ${props_a[1]}"
        
		#Evaluate and save results
		plot_file="$plots_dir/plot_rtab_kitti_$props.png"
		res_file="$res_dir/ate_rtab_kitti_$group.csv"
		printf "${props};" | tee -a ${res_file}
        python ~/workspace/phd/metrics/evaluate_ate.py --verbose $depth_scale $HOME/datasets/kitti/poses/${props_a[1]}_freiburg.txt ${in_file} --plot ${plot_file} | tee -a ${res_file}
		printf "\n" | tee -a ${res_file};
	done
    exit
done