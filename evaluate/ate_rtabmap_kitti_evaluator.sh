#!/bin/bash

usage()
{
    echo -e "Usage: ./$(basename $0) {path} [--sub]"
    echo -e "Script to automate ate evaluation from the png_dataset (rtabmap tool) for different kitti sequences"
    echo -e ""
    echo -e "Mandatory"
    echo -e "\t""path           Path to the output experiments group"
    echo -e ""
    echo -e "Optional"
    echo -e "\t""--sub          Joint subgroup evalutation (the group contains subgroups)"
    echo -e "\t""--sub=Val      Individual subgroup evaluation (the group is a subgroup), the value of this argument is the parent foldername after evaluation"
    echo -e ""
    echo -e "\t""--help         Display this help and exit"
}

#Arg parser
if [[ "$#" -gt 2 ]] || [[ "$#" -lt 1 ]] || [[ $1 == --help ]]; then usage; exit; fi;
out_dir=${1%/}
if [ ! -d "$out_dir" ]; then echo "ERROR: Invalid experiments output directory: $out_dir"; exit 1; fi
subgroup=false
while [ "$2" != "" ]; do
    ARG=`echo $2 | awk -F= '{print $1}'`
    VAL=`echo $2 | awk -F= '{OFS="=";$1=""; printf substr($0,2)}'`
    case $ARG in
        --sub)
            parent=$VAL
            subgroup=true
            ;;
        *)
            echo "ERROR: unknown parameter \"$ARG\""; usage; exit 1
            ;;
    esac
    shift
done

IFS='/'; read -r -a ordir <<< $out_dir; unset IFS; #Parse dirnames "~/outputs/phd/kitti/rtab/unscaled"
if [[ $parent != "" ]]; then of=1; else of=0; fi #Jump parent foldername
group=${ordir[-1]}
system=${ordir[-2-$of]}
dataset=${ordir[-3-$of]}
project=${ordir[-4-$of]}
dir_depth=1
if ! $subgroup; then
    res_dir="$HOME/important/$project/metrics/$system/$dataset/$group"
    res_file="$res_dir/ate_${system}_${dataset}_$group.csv"
elif $subgroup && [ "$parent" = "" ]; then
    res_dir="$HOME/important/$project/metrics/$system/$dataset/$group"
    res_file="$res_dir/ate_${system}_${dataset}_$group.csv"
    dir_depth=2
else 
    res_dir="$HOME/important/$project/metrics/$system/$dataset/$parent/$group"
    res_file="$res_dir/ate_${system}_${dataset}_$group.csv"
fi
plots_dir="$res_dir/plots"

#RESET RESULTS
rm -rf $res_dir/*
mkdir -p $plots_dir/
echo "Sequence;Experiment parameters;Time;GT;Estimated;Compared;RMSE;MEAN;MEDIAN;STD;MIN;MAX" >> ${res_file}

#ITERATE SEQUENCES
find $out_dir -maxdepth $dir_depth -type d -print0 |
while IFS= read -r -d '' line; do
    seq=`basename "$line"`
	seq_dir="$line"
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
            echo "ERROR" | tee -a ${res_file}
            continue
        fi
        
        #Time of the execution
        tail -n 60 "$logs_dir/$log_name" | grep "Total time=" | sed 's/Total time=//g'| { awk -F. '{printf $1}'; printf ";"; } | tee -a ${res_file}
		
		#Get depth_scale"
		depth_scale=""; #default none
		if [[ ${props_a[-1]} =~ scale* ]]; then depth_scale="--scale ${props_a[-1]:5}"; fi;
        
		#Evaluate and save results
		plot_file="$plots_dir/plot_${system}_${dataset}_$props.png"
        python ~/workspace/phd/metrics/evaluate_ate.py $depth_scale $HOME/datasets/${dataset}/poses/${seq}_freiburg.txt ${in_file} --plot ${plot_file} | tee -a ${res_file}
		printf "\n" | tee -a ${res_file};
	done
done

echo -e "\n\nResults saved at: $res_file"