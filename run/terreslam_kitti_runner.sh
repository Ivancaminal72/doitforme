rosparam delete /terreslam/
rosparam load ~/workspace/ros_ddd/src/terreslam/config/global_general.yaml
rosrun terreslam rgb_depth_nodelet &
rosrun terreslam dd_keypoint_nodelet &
rosrun terreslam plane_detector_nodelet &
rosrun terreslam ddd_keypoint_nodelet &
rosrun terreslam blob_detector_nodelet &
rosrun terreslam metric_alignment_nodelet &
# sleep 3
# rosrun data_to_rosbag pcd_to_png -p 2 -r 0.1 &
# sleep 7
# rosrun data_to_rosbag kitti_live_node -s ~/datasetkitti/sequences/04 -r 0.1

# rosrun rviz rviz -d ~/workspace/ros_ddd/rviz/basic.rviz
