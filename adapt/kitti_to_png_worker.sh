#!/bin/bash
seq=0
downsampling=1
while [ "$seq" -lt 22 ]
do
    printf -v seq_f "%02d" $seq
    echo "Adapting sequence $seq_f"
	srun -p gpi.develop --time=0:30:00 -c1 --mem=8G $HOME/workspace/phd/adapt/kitti/kitti_to_png/build/kitti_to_png -r 120 -d $downsampling -i $HOME/datasets/kitti/ -o $HOME/datasets/kitti/generated/ -s $seq_f
    (( seq++ ))
done
echo all done!