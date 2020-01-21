#!/bin/bash
downsampling=1
data_dir="/imatge/icaminal/datasets/2018-slam/kitti/generated"
outputs="/imatge/icaminal/outputs/phd/kitti/rtab"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
#inlier_dist_a=("0.4" "3.2" "0.6" "0.7" "0.7" "0.5" "6.0" "0.3" "1.3" "1.9" "0.4") #gftt/brief
#inlier_dist_a=("0.4" "1.6" "0.5" "0.3" "1.2" "0.4" "1.3" "0.3" "0.6" "1.0" "0.4") #gftt/brief downsampling2
inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2") #FIX

inlier_dist_a=2
seq_a="07"
dot_a=("f2m") #Odometry_stragegy {0=Frame-to-Map (F2M) 1=Frame-to-Frame (F2F) 2=Fovis 3=viso2 4=DVO-SLAM 5=ORB_SLAM2}

max_inlierdist=6
depth_scale=1
gftt_dist=6
#gftt_dist=2 #downsampling2 GFTT.MinDistance/dw^2

#source ~/workspace/install/modules_rtabmap.sh #Not needed in "calcula" (dependencies installed with puppet)
#cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build (not needed --> binaries in $PATH)

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$data_dir/${seq_a[i]}
	out_dir=$outputs/${seq_a[i]}_${downsampling}
	calib=$data_dir/${seq_a[i]}/calib_${downsampling}.000000.txt
	rm -f $out_dir/*rtabmap*
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=$downsampling.rtabmap.poses.$inlierdist.${dot_a[j]}
			printf "\nTrying inlier distance --> $inlierdist\n"

			#Without loop closure
			printf "\n${dot_a[j]} "

			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "visible"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--scale ${depth_scale} \
			--times /imatge/icaminal/datasets/2018-slam/kitti/sequences/${seq_a[i]}/times.txt \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.0005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures -1 \
			--Kp/DetectorStrategy 6 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6\
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.txt \

			
			retVal=$?
			
			if [[ $retVal -eq 0 ]]
			then
				break
			
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]] #Tune inlier dist
			then
				inlierdist=$(echo "$inlierdist 0.1" | awk '{printf "%.1f", $1+$2}') #Increment Inlier Distance
				break #COMMENT FOR TUNNING #######------------#############
				rm -f $out_dir/$out_name
			
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]] #Stop tunning (exceeds max)
			then 
				rm -f $out_dir/$out_name
				break
			
			else
				continue
			fi

		done
	done
done

:'
#With loop closure

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$data_dir/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}
	calib=$data_dir/${seq_a[i]}/calib_${downsampling}.000000.txt
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=$downsampling.rtabmap.poses.$inlierdist.${dot_a[j]}
			rm -f $out_dir/database.$downsampling.rtabmap.poses.*.od.db
			printf "\nTrying inlier distance --> $inlierdist\n"
		
			printf "\n${dot_a[j]}.od "
			out_name=$out_name.od
			
			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "visible"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--times /imatge/icaminal/datasets/kitti/sequences/${seq_a[i]}/times.txt \
			--scale ${depth_scale} \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.0005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures 750 \
			--Kp/DetectorStrategy 6 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6\
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.od.txt \

			#--Mem/STMSize 30 \ #def. 10
			#--RGBD/OptimizeMaxError 2.0 \
			#--RGBD/NeighborLinkRefining true \

#			--Grid/FromDepth true\
#			--Grid/DepthDecimation 1\
#			--Grid/RangeMax 20\
#			--Grid/3D true\	
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				break
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.1" | awk '{printf "%.1f", $1+$2}')
				break #NO TUNE INLIER DIST#######------------#############
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue
			fi
		done
	done
done
'