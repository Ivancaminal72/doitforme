#!/bin/bash

#PARAMETERS
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then echo -e "Usage: $0 /path/to/experiments/output/directory"; exit; fi;
out_dir=${1%/}
if [ ! -d "$out_dir" ]; then echo "ERROR: Invalid experiments output directory: $out_dir"; exit -1; fi
IFS='/'; read -r -a ordir <<< $out_dir; unset IFS; #Parse dirnames "~/outputs/phd/kitti/rtab/unscaled"
group=${ordir[-1]}
system=${ordir[-2]}
dataset=${ordir[-3]}
project=${ordir[-4]}
res_dir="$HOME/important/$project/metrics/$system/$dataset/$group"
res_file="$res_dir/ate_${system}_${dataset}_$group.csv"
plots_dir="$res_dir/plots"

#RESET RESULTS
rm -rf $res_dir/*
mkdir -p $plots_dir/
#echo "Sequence;Experiment parameters;GT;Estimated;Compared;RMSE;MEAN;MEDIAN;STD;MIN;MAX" >> ${res_file}

#ITERATE SEQUENCES
find $out_dir -maxdepth 1 -type d -print0 |
while IFS= read -r -d '' line; do
    seq=`basename "$line"`
	seq_dir="$out_dir/$seq"
    logs_dir="$seq_dir/logs"
    if [[ ! -d $logs_dir ]]; then continue; fi; #Skip dirs without experiments
	
    echo -e "\n\n""Evaluating ate experiments sequence: $seq_dir"

	#ITERATE EXPERIMENTS
    find $logs_dir -maxdepth 1 -type f -print0 |
    while IFS= read -r -d '' log_file; do
        
        #Get exp properties
		log_name=`basename "$log_file"`
		props=${log_name:0:-4} #remove tail ".txt"
		IFS='_'; read -r -a props_a <<< $props; unset IFS; #Parse into array
        printf "${seq};${props};" | tee -a ${res_file}
        
        #Skip exp without poses file
        in_file="${seq_dir}/poses_${props}.txt"
        if [[ ! -f $in_file ]]; then 
            echo ";ERROR" | tee -a ${res_file}
            continue
        fi
		
		#Get depth_scale"
		depth_scale=""; #default none
		if [[ ${props_a[-1]} =~ scale* ]]; then depth_scale="--scale ${props_a[-1]:5}"; fi;
        
		#Evaluate and save results
		plot_file="$plots_dir/plot_${system}_${dataset}_$props.png"
        python ~/workspace/phd/metrics/evaluate_ate.py $depth_scale $HOME/datasets/${dataset}/poses/${seq}_freiburg.txt ${in_file} --plot ${plot_file} | tee -a ${res_file}
		printf "\n" | tee -a ${res_file};
	done
done