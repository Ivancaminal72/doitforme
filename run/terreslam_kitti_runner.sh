rosparam delete /terreslam/
rosparam load ~/workspace/ros_ddd/src/terreslam/config.yaml
rosrun terreslam rgb_depth_frontend &
rosrun terreslam dd_keypoint_frontend &
rosrun terreslam plane_detector_frontend &
rosrun terreslam ddd_keypoint_frontend &
rosrun terreslam blob_detector_frontend &
rosrun terreslam metric_alignment_frontend &
# sleep 3
# rosrun data_to_rosbag pcd_to_png -p 2 -r 0.1 &
# sleep 7
# rosrun data_to_rosbag kitti_live_node -s ~/datasetkitti/sequences/04 -r 0.1

# rosrun rviz rviz -d ~/workspace/ros_ddd/rviz/basic.rviz
