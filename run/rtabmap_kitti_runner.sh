#!/bin/bash

usage()
{
    echo -e "Usage: ./$(basename $0) {group} {release} [--sub=Val] [--ate[=Val]] [--rec] [--out=Val] [--odom=Val]"
    echo -e "Script to automate running the png_dataset (rtabmap tool) for different kitti sequences"
    echo -e ""
    echo -e "Mandatory"
    echo -e "\t""group          Name of the experiments group (scaled-n / modality)"
    echo -e "\t""release        Release number of rtabmap to use (png_dataset_{release})"
    echo -e ""
    echo -e "Optional"
    echo -e "\t""--sub=Val      Make group become subgroup within a new group called as this parameter value"
    echo -e "\t""--ate[=Val]    Execute ATE evalutation script after running. In case of --sub argument will do individual subgroup mode with [Val] as the parent foldername (defalut: tmp)"
    echo -e "\t""--rec          Preserve rtabmap .db file to allow for exporting its pointcloud/mesh reconstruction"
    echo -e "\t""--out=Val      Custom output folder name (like: r017k / r017m / r019m)"
    echo -e ""
    echo -e "Rtabmap"
    echo -e "\t"'--odom=Val     Odometry strategy idx ("f2m" "f2f" "Fovis" "Viso2" "DVO-SLAM" "ORB_SLAM2" "OKVIS" "LOAM" "MSCKF_VIO" "VINS-Fusion")'
    echo -e ""
    echo -e "\t""--help         Display this help and exit"
}

#Arg parser
if [[ "$#" -gt 6 ]] || [[ "$#" -lt 2 ]] || [[ $1 == --help ]]; then usage; exit; fi
script_path=$0
group=$1
subgroup=""
rtab_release=$2 #png_dataset_${rtab_release}
evaluate_ate=false
rtab_out="r${2}"
ate_parent="tmp"
delete_db=true
odom_idx=0 #(0)Odometry_stragegy {"0=Frame-to-Map (F2M) 1=Frame-to-Frame (F2F) 2=Fovis 3=viso2 4=DVO-SLAM 5=ORB_SLAM2 6=OKVIS 7=LOAM 8=MSCKF_VIO 9=VINS-Fusion"}
while [ "$3" != "" ]; do
    ARG=`echo $3 | awk -F= '{print $1}'`
    VAL=`echo $3 | awk -F= '{OFS="=";$1=""; printf substr($0,2)}'`
    case $ARG in
        --sub)
            subgroup=$VAL
            ;;
        --ate)
            evaluate_ate=true
            if [[ $VAL != "" ]]; then ate_parent=$VAL; fi
            ;;
        --rec)
            delete_db=false
            ;;
        --out)
            rtab_out=$VAL
            ;;
        --odom)
            odom_idx=$VAL
            ;;
        *)
            echo "ERROR: unknown parameter \"$ARG\""; usage; exit 1
            ;;
    esac
    shift
done

main(){
	#MULTIPLE seq execution
	# seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
	# inlier_dist_a=("0.4" "3.2" "0.6" "0.7" "0.7" "0.5" "6.0" "0.3" "1.3" "1.9" "0.4") #gftt/brief
	# inlier_dist_a=("0.4" "1.6" "0.5" "0.3" "1.2" "0.4" "1.3" "0.3" "0.6" "1.0" "0.4") #gftt/brief downsampling2
	# inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2") #FIX

	#SINGLE seq execution (override)
	seq_a=("08")
    inlier_dist_a=2

	#PARAMETERS
	data_dir="$HOME/datasets/kitti/generated"
    if [ subgroup == "" ];
    then outputs="$HOME/outputs/phd/kitti/$rtab_out/$group"; 
    else outputs="$HOME/outputs/phd/kitti/$rtab_out/$subgroup/$group"; fi;    
	downsampling=1
	max_inlierdist=6
	depth_scale=1
	kps=6
	features=6
	gftt_dist=6 #(2 for downsampling=2) GFTT.MinDistance/dw^2
	gftt_quality=0.0005
	cor_type=0 #(0) Correspondences computation approach: 0=Features Matching, 1=Optical Flow
    odom_a=("f2m" "f2f" "Fovis" "Viso2" "DVO-SLAM" "ORB_SLAM2" "OKVIS" "LOAM" "MSCKF_VIO" "VINS-Fusion") 
	reg_strategy=0 #(0) 0=Vis, 1=Icp, 2=VisIcp
	vis_estimation=0 #(1) Motion estimation approach: 0:3D->3D, 1:3D->2D (PnP), 2:2D->2D (Epipolar Geometry)
	vis_maxFeatures=1000 #(1000) - 0 no limits
	odom_vis_maxSize=2000 #(2000) Local map of X maximum visual words.
	map_update=0.1 #(0.1) (m) Minimum linear displacement to update the map. Rehearsal is done prior to this, so weights are still updated.
	rate=10 #(1) (Hz) Detection rate. RTAB-Map will filter input images to satisfy this rate.
    force3dof=false #Force 3 degrees-of-freedom transform (3Dof: x,y and yaw). Parameters z, roll and pitch will be set to 0."

	#source ~/workspace/install/modules_rtabmap.sh #Not needed in "calcula.tsc.upc.edu" (current dependencies installed with puppet)
	cd $HOME/workspace/phd/rtabmap/png_dataset_${rtab_release}/build

	reset_outputs #Delete old runs
	run 750 #With loop closure
	run -1 #Without loop closure
    
    #Delete rtabmap db
    if $delete_db; then find $outputs -name *.db -type f -delete & fi
    
    #Evaluate ATE
    if $evaluate_ate && [[ $subgroup = "" ]]; then
        ~/workspace/doitforme/evaluate/ate_rtabmap_kitti_evaluator.sh $outputs &
    elif $evaluate_ate; then
        ~/workspace/doitforme/evaluate/ate_rtabmap_kitti_evaluator.sh $outputs --sub=$ate_parent &
    fi
}

run(){
	for ((i=0;i<${#seq_a[@]};++i)); do
		gen_dir=$data_dir/${seq_a[i]}
		out_dir=$outputs/${seq_a[i]}
		logs_dir=$out_dir/logs
		mkdir -p $logs_dir/
		calib=$gen_dir/calib_${downsampling}.000000.txt
		times_dir="$HOME/datasets/kitti/sequences/${seq_a[i]}/times.txt"
	    echo -e "\n\n""Running sequence: $gen_dir"

		inlierdist=${inlier_dist_a[i]}
		while true
		do
			#out_name=$out_name_scale20
			if [[ ${1} == -1 ]]; then
				out_name=${group}_s${seq_a[i]}_d${downsampling}_i${inlierdist}_${odom_a[$odom_idx]}
			else
				out_name=${group}_s${seq_a[i]}_d${downsampling}_lc${1}_i${inlierdist}_${odom_a[$odom_idx]}
			fi
			find $out_dir -name "*$out_name*" -type f -delete
			log_path=$logs_dir/$out_name.txt
			echo -e "$PATH \n\n\n" > $log_path
			cat $script_path >> $log_path
			echo -e "\n\n\n" >> $log_path

			echo -e "\n""Trying inlier distance --> $inlierdist"
			echo -e "\n""${out_name}"

			srun -p gpi.develop --time=0:30:00 --mem=8GB -c4 ./png_dataset \
			--outdir $out_dir \
			--outname $out_name \
			--colorname "rgb"\
			--depthname "depth"\
			--calib $calib \
			--scale ${depth_scale} \
			--times ${times_dir} \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate $rate \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate $map_update \
			--Reg/Strategy $reg_strategy \
			--GFTT/QualityLevel $gftt_quality\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy $odom_idx \
			--OdomF2M/MaxSize $odom_vis_maxSize \
			--Kp/MaxFeatures $1 \
			--Kp/DetectorStrategy $kps \
			--Vis/FeatureType $features \
			--Vis/CorType $cor_type \
			--Vis/MaxFeatures $vis_maxFeatures \
			--Vis/EstimationType $vis_estimation \
			--Vis/InlierDistance $inlierdist \
            --Reg/Force3DoF $force3dof \
			$gen_dir \
			>> $log_path  2>&1 \

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
				rm -f $log_path

			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]] #Stop tunning (exceeds max)
			then
				rm -f $out_dir/*$out_name*
				break 
			fi
            break
		done
	done
}

reset_outputs(){
	for ((i=0;i<${#seq_a[@]};++i)); do
		rm -rf $outputs/${seq_a[i]}/
	done
}

main "$@"
