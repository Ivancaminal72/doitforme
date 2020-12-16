#!/bin/bash
#Execution time (10 seq) ~7h
seq=0
while [ "$seq" -lt 11 ]
do
    printf -v seq_f "%02d" $seq
    echo "Converting groundtruth $seq_f"
    $HOME/workspace/phd/adapt/kitti/groundtruth_kitti_to_freiburg/build/groundtruth_kitti_to_freiburg -i ~/datasets/kitti/poses/$seq_f.txt -o ~/datasets/kitti/poses/${seq_f}_freiburg.txt -t ~/datasets/kitti/sequences/$seq_f/times.txt
    # srun -p gpi.compute --time=1:00:00 -c1 --mem=8G $HOME/workspace/phd/adapt/kitti/groundtruth_kitti_to_freiburg/build/groundtruth_kitti_to_freiburg -i ~/datasets/kitti/poses/$seq_f.txt -o ~/datasets/kitti/poses/${seq_f}_freiburg.txt -t ~/datasets/kitti/sequences/$seq_f/times.txt
    (( seq++ ))
done
echo all done!
