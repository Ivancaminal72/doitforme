#!/bin/bash
main(){
	#MULTIPLE seq execution
	seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
	#inlier_dist_a=("0.4" "3.2" "0.6" "0.7" "0.7" "0.5" "6.0" "0.3" "1.3" "1.9" "0.4") #gftt/brief
	#inlier_dist_a=("0.4" "1.6" "0.5" "0.3" "1.2" "0.4" "1.3" "0.3" "0.6" "1.0" "0.4") #gftt/brief downsampling2
	inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2") #FIX

	#SINGLE seq execution (override)
	#inlier_dist_a=2
	#seq_a=("07")

	#PARAMETERS
	group="unscaled" #scaled-n / modality
	data_dir="$HOME/datasets/kitti/generated"
	outputs="$HOME/outputs/phd/kitti/rtab/$group"
	downsampling=1
	max_inlierdist=6
	depth_scale=1.0
	kps=6
	features=6
	gftt_dist=6 #(2 for downsampling=2) GFTT.MinDistance/dw^2
	gftt_quality=0.0005
	cor_type=0 #(0) Correspondences computation approach: 0=Features Matching, 1=Optical Flow
	dot_a=("f2m"); odom_strategy=0 #(0)Odometry_stragegy {0=Frame-to-Map (F2M) 1=Frame-to-Frame (F2F) 2=Fovis 3=viso2 4=DVO-SLAM 5=ORB_SLAM2}
	reg_strategy=0 #(0) 0=Vis, 1=Icp, 2=VisIcp
	vis_estimation=0 #(1) Motion estimation approach: 0:3D->3D, 1:3D->2D (PnP), 2:2D->2D (Epipolar Geometry)
	vis_maxFeatures=1500 #(1000) - 0 no limits
	odom_vis_maxSize=3000 #(200) Local map of X maximum visual words.
	map_update=0 #(0.1 m) Minimum linear displacement to update the map. Rehearsal is done prior to this, so weights are still updated.
	rate=2 #(1 Hz) Detection rate. RTAB-Map will filter input images to satisfy this rate.

	#source ~/workspace/install/modules_rtabmap.sh #Not needed in "calcula" (current dependencies installed with puppet)
	cd $HOME/workspace/PHD/rtabmap/rgbd-dataset_rtab-map/build
	
	run 750 #With loop closure
	run -1 #Without loop closure
	
}

run(){
	for ((i=0;i<${#seq_a[@]};++i)); do
		gen_dir=$data_dir/${seq_a[i]}
		out_dir=$outputs/${seq_a[i]}_${downsampling}
		if [[ $1 > 0 ]]; then out_dir+="_LC"; fi;
		logs_dir=$out_dir/logs
		calib=$data_dir/${seq_a[i]}/calib_${downsampling}.000000.txt
		times_dir="$HOME/datasets/kitti/sequences/${seq_a[i]}/times.txt"
		rm -rf $out_dir/*
		mkdir -p $logs_dir/
	    echo -e "\n\n""Running sequence: $gen_dir"

		for ((j=0;j<${#dot_a[@]};++j)); do
			inlierdist=${inlier_dist_a[i]}
			while true
			do
				if [[ $1 > 0 ]]; then 
					out_name=${group}_${seq_a[i]}_${downsampling}_${dot_a[j]}_${inlierdist}
				else
					out_name=${group}_${seq_a[i]}_${downsampling}_LC-${1}_${dot_a[j]}_${inlierdist}
				fi;
				log_name=$out_name.txt
				
				echo -e "\n""Trying inlier distance --> $inlierdist"
				echo -e "\n""${out_name}"

				srun -p gpi.develop --time=0:30:00 --mem=8GB -c4 ./rgbd_dataset \
				--output $out_dir \
				--outname $out_name \
				--imagename "visible"\
				--depthname "depth"\
				--calibfile $calib \
				--poses ${dot_a[j]} \
				--scale ${depth_scale} \
				--times $times_dir \
				--Rtabmap/PublishRAMUsage true \
				--Rtabmap/DetectionRate $rate \
				--Rtabmap/CreateIntermediateNodes true \
				--RGBD/LinearUpdate $map_update \
				--Reg/Strategy $reg_strategy \
				--GFTT/QualityLevel $gftt_quality\
				--GFTT/MinDistance $gftt_dist \
				--Odom/Strategy $odom_strategy \
				--OdomF2M/MaxSize $odom_vis_maxSize \
				--Kp/MaxFeatures $1 \
				--Kp/DetectorStrategy $kps \
				--Vis/FeatureType $features \
				--Vis/CorType $cor_type \
				--Vis/MaxFeatures $vis_maxFeatures \
				--Vis/EstimationType $vis_estimation \
				--Vis/InlierDistance $inlierdist \
				$gen_dir \
				> $logs_dir/$log_name \

				#Loop closure other-possible-params:
					#--Mem/STMSize 30 \ #def. 10
					#--RGBD/OptimizeMaxError 2.0 \
					#--RGBD/NeighborLinkRefining true \
					# --Grid/FromDepth true \
					# --Grid/DepthDecimation 1 \
					# --Grid/RangeMax 20 \
					# --Grid/3D true \

				retVal=$?
				if [[ $retVal -eq 0 ]]
				then
					break
				elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]] #Tune inlier dist
				then
					inlierdist=$(echo "$inlierdist 0.1" | awk '{printf "%.1f", $1+$2}') #Increment Inlier Distance
					break #COMMENT FOR TUNNING #######------------#############
					rm -f $out_dir/*$out_name*
					rm -f $logs_dir/$log_name

				elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]] #Stop tunning (exceeds max)
				then 
					rm -f $out_dir/*$out_name*
					break

				else
					continue
				fi			
			done
		done
	done
}

main "$@"