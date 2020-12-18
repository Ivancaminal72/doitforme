#!/bin/bash

usage()
{
    echo "Usage: ./$(basename $0) {group} {system} [--sub=Val] [--ate[=Val]] [--rec] [--dir[=Val]] [--odom=Val]"
    echo "Script to automate running the png_dataset (rtabmap tool) for different kitti sequences"
    echo ""
    echo "Mandatory"
    echo "       group          Name of the experiments group (scaled-n / modality)"
    echo "       system         Custom system folder name (like: r017k / r017m / r019m)"
    echo ""
    echo "Optional"
    echo "       --sub=Val      Make group become subgroup within a new group called as this parameter value"
    echo "       --ate[=Val]    Execute ATE evalutation script after running. In case of --sub argument will do individual subgroup mode with [Val] as the parent foldername (defalut: tmp)"
    echo "       --rec          Preserve rtabmap .db file to allow for exporting its pointcloud/mesh reconstruction"
    echo "       --dir=Val      Main directory for the data generated from the experiments  (defalut: $HOME)"
    echo ""
    echo "Rtabmap"
    echo '       --odom=Val     Odometry strategy idx (0=Frame-to-Map (F2M) 1=Frame-to-Frame (F2F) 2=Fovis 3=viso2 4=DVO-SLAM 5=ORB_SLAM2 6=OKVIS 7=LOAM 8=MSCKF_VIO 9=VINS-Fusion") (defalut: 0)'
    echo ""
    echo "       --help         Display this help and exit"
}

#Arg parser
if [[ "$#" -gt 7 ]] || [[ "$#" -lt 2 ]] || [[ $1 == --help ]]; then usage; exit; fi
args_a=$@
script_path=$0
group=$1
system=$2
subgroup=""
evaluate_ate=false
ate_parent="tmp"
delete_db=true
exp_dir=$HOME
tmux=true
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
        --dir)
            exp_dir=$VAL
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
    # inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2") #FIX
    # inlier_dist_a=("0.4" "3.2" "0.6" "0.7" "0.7" "0.5" "6.0" "0.3" "1.3" "1.9" "0.4") #gftt/brief
	# inlier_dist_a=("0.4" "1.6" "0.5" "0.3" "1.2" "0.4" "1.3" "0.3" "0.6" "1.0" "0.4") #gftt/brief downsampling2
    
    
    #CUSTOMULTIPLE seq execution
	seq_a=("02" "05" "06")
    inlier_dist_a=("2" "2" "2") #FIX
	

	#SINGLE seq execution (override)
	# seq_a=("07")
    # inlier_dist_a=(2)

	#PARAMETERS
    data_dir="$HOME/datasets/kitti/sequences"
    if [[ $subgroup == "" ]];
    then outputs="$exp_dir/outputs/phd/kitti/$system/$group";
    else outputs="$exp_dir/outputs/phd/kitti/$system/$subgroup/$group"; fi;    
	max_inlierdist=6
    odom_a=("f2m" "f2f" "Fovis" "Viso2" "DVO-SLAM" "ORB_SLAM2" "OKVIS" "LOAM" "MSCKF_VIO" "VINS-Fusion") 
    # cor_type=0 #(0) Correspondences computation approach: 0=Features Matching, 1=Optical Flow
	# reg_strategy=0 #(0) 0=Vis, 1=Icp, 2=VisIcp
	# vis_estimation=0 #(1) Motion estimation approach: 0:3D->3D, 1:3D->2D (PnP), 2:2D->2D (Epipolar Geometry)
	# vis_maxFeatures=1000 #(1000) - 0 no limits
	# odom_vis_maxSize=2000 #(2000) Local map of X maximum visual words.
	# map_update=0.1 #(0.1) (m) Minimum linear displacement to update the map. Rehearsal is done prior to this, so weights are still updated.
	# rate=10 #(1) (Hz) Detection rate. RTAB-Map will filter input images to satisfy this rate.
    # force3dof=false #Force 3 degrees-of-freedom transform (3Dof: x,y and yaw). Parameters z, roll and pitch will be set to 0."

	#source ~/workspace/install/modules_rtabmap.sh #Not needed in "calcula.tsc.upc.edu" (current dependencies installed with puppet)
    source $HOME/.bashrc_custom
    roscd && cd ..
    
    rosmaster --core &
    PID_roscore=$!
    
	rm -rf /tmp/roslogs/* #Delete old logs
    reset_outputs #Delete old runs
	run 750 #With loop closure
	# run -1 #Without loop closure
    
    kill -s 9 $PID_roscore
    
    #Delete rtabmap db
    if $delete_db; then find $outputs -name *.db -type f -delete & fi
    
    #Evaluate ATE
    if $evaluate_ate && [[ $subgroup = "" ]]; then
        ~/workspace/doitforme/evaluate/ate_evaluator.sh $outputs &
    elif $evaluate_ate; then
        ~/workspace/doitforme/evaluate/ate_evaluator.sh $outputs --sub=$ate_parent &
    fi
}

reset_outputs(){
	for ((i=0;i<${#seq_a[@]};++i)); do
		rm -rf $outputs/${seq_a[i]}/
	done
}

run(){
	for ((i=0;i<${#seq_a[@]};++i)); do
		out_dir=$outputs/${seq_a[i]}
		logs_dir=$out_dir/logs
		mkdir -p $logs_dir/
	    echo -e "\n\n""Running kitti sequence: ${seq_a[i]}"

		inlierdist=${inlier_dist_a[i]}
		while true
		do
			#out_name=$out_name_scale20
			if [[ ${1} == -1 ]]; then
				out_name=${group}_s${seq_a[i]}_i${inlierdist}_${odom_a[$odom_idx]}
			else
				out_name=${group}_s${seq_a[i]}_lc${1}_i${inlierdist}_${odom_a[$odom_idx]}
			fi
			find $out_dir -name "*$out_name*" -type f -delete
            
            rtabmap_args="
            --delete_db_on_start
            --Rtabmap/PublishRAMUsage true
            --Rtabmap/DetectionRate 10
            --Rtabmap/CreateIntermediateNodes true
            --RGBD/LinearUpdate 0
            --Reg/Strategy 0
            --GFTT/QualityLevel 0.0005
            --GFTT/MinDistance 6
            --Odom/Strategy $odom_idx
            --OdomF2M/MaxSize 3000
            --Kp/MaxFeatures $1
            --Kp/DetectorStrategy 6
            --Vis/FeatureType 6
            --Vis/CorType 0
            --Vis/EstimationType 0
            --Vis/InlierDistance $inlierdist
            --Reg/Force3DoF false"
            
            # Logging
            log_path=$logs_dir/$out_name.txt
			echo -e "$PATH \n" > $log_path
            printf "%s\n" "${args_a[@]}" >> $log_path
            echo -e "" >> $log_path
            echo -e $rtabmap_args | sed 's/\s\-\-/\n\-\-/g' >> $log_path
            echo -e "\n\n\n" >> $log_path
			cat $script_path >> $log_path

			echo -e "\n""Trying inlier distance --> $inlierdist"
			echo -e "\n""${out_name}"

            rtabmap_cmd=(roslaunch rtabmap_ros rgbd_mapping.launch \
            rtabmapviz:=false \
            rviz:=false \
            rviz_cfg:=/home/icaminal/workspace/ros_ddd/rviz/rtabmap_kitti.rviz \
            rgb_topic:=/cam02 \
            depth_registered_topic:=/cam02_depth \
            camera_info_topic:=/camera_info \
            frame_id:=lidar \
            database_path:=$outputs/rtabmap.db \
            approx_sync:=false \
            rtabmap_args:="$rtabmap_args")
            
            #Loop closure other-possible-params:
    		#--Mem/STMSize 30 \ #def. 10
    		#--RGBD/OptimizeMaxError 2.0 \
    		#--RGBD/NeighborLinkRefining true \
    		# --Grid/FromDepth true \
    		# --Grid/DepthDecimation 1 \
    		# --Grid/RangeMax 20 \
    		# --Grid/3D true \
            
            if $tmux;
            then pane_id_rtabmap=$(tmux split-window -P -F "#{pane_id}" "${rtabmap_cmd[@]}");
            else "${rtabmap_cmd[@]} &"; fi
                
            sleep 7
            inter_cmd=(rosrun data_to_rosbag pcd_to_png 2)
            if $tmux;
            then pane_id_rtabmap=$(tmux split-window -P -F "#{pane_id}" "${inter_cmd[@]}");
            else "${rtabmap_cmd[@]} &"; fi
            
            sleep 3
            rosrun data_to_rosbag kitti_live_node /home/icaminal/datasets/kitti/sequences/${seq_a[i]}
            sleep 28
            rosservice call /rtabmap/get_trajectory_data true true "$out_dir/poses_$out_name.txt"

            rosnode kill -a
            sleep 3

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

main "$@"
