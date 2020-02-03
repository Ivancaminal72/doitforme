#!/bin/bash
kpfeat="gftt_brief_fix"
downsampling=1
path="/imatge/icaminal/datasets/kitti/generated"
out_dir="/imatge/icaminal/results/rtabmap"
#out_file="$out_dir/ate_kitti_${downsampling}_infrared_${kpfeat}.csv" #infrared
out_file="$out_dir/ate_kitti_${downsampling}_infrared_scaled_${kpfeat}.csv" #SCALED infrared
#out_file="$out_dir/ate_kitti_${downsampling}_scaled_${kpfeat}.csv" #SCALED
#out_file="$out_dir/ate_kitti_${downsampling}_${kpfeat}.csv"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
#inlier_dist_a=("0.020" "0.155" "0.025" "0.035" "0.030" "0.020" "0.120" "0.015" "0.045" "0.095" "0.015") #SCALED gftt/brief
#inlier_dist_a=("0.4" "3.2" "0.6" "0.7" "0.7" "0.5" "6.0" "0.3" "1.3" "1.9" "0.4") #gftt/brief
#inlier_dist_a=("0.020" "0.090" "0.030" "0.015" "0.050" "0.020" "0.070" "0.015" "0.030" "0.060" "0.020") #SCALED gftt/brief downsampling2
#inlier_dist_a=("0.4" "1.6" "0.5" "0.3" "1.2" "0.4" "1.3" "0.3" "0.6" "1.0" "0.4") #gftt/brief downsampling2
inlier_dist_a=("0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1") #FIX  SCALED
#inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2") #FIX

#seq_a=("07") 
#inlier_dist_a=("0.5") #gftt/brief

dot_a=("f2m" )

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	#seq_dir=$path/${seq_a[i]}_rtab_${downsampling}_infrared #infrared
	seq_dir=$path/${seq_a[i]}_rtab_${downsampling}_infrared_scaled #SCALED infrared
	#seq_dir=$path/${seq_a[i]}_rtab_${downsampling}_scaled #SCALED
	#seq_dir=$path/${seq_a[i]}_rtab_${downsampling}
	cd $seq_dir
	#rm -f ./*plot*

    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		#opt_scale=""
		opt_scale="--scale 20" #SCALED
		#plot="plot.${dot_a[j]}"
		plot="plot.${dot_a[j]}.scaled" #SCALED
				
		#in_name="${downsampling}.rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}"
		in_name="${downsampling}.rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}.scaled" #SCALED
		
		#Without loop closure		
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]};" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $opt_scale /imatge/icaminal/datasets/kitti/poses/${seq_a[i]}_freiburg.txt ./${in_name} --plot $plot.${kpfeat}.png | tee -a $out_file
		
		#With loop closure
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $opt_scale /imatge/icaminal/datasets/kitti/poses/${seq_a[i]}_freiburg.txt ./${in_name}.od --plot $plot.${kpfeat}.od.png | tee -a $out_file

	done
done
