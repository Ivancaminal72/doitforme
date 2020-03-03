#!/bin/bash
#Execution time (10 seq) ~7h
seq=0
downsampling=1
while [ "$seq" -lt 11 ]
do
    printf -v seq_f "%02d" $seq
    echo "Adapting sequence $seq_f"
	srun -p gpi.compute --time=10:00:00 -c1 --mem=8G --x11 $HOME/workspace/phd/adapt/kitti/kitti_to_png/build/kitti_to_png -r 120 -d $downsampling -i $HOME/datasets/kitti/ -o $HOME/datasets/kitti/generated/ -s $seq_f
    (( seq++ ))
done
echo all done!
