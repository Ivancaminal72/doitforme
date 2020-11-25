rosinstall_generator tf2_eigen --deps --wet-only > rosinstall_tf2_eigen.rosinstall
wstool merge -t src rosinstall_tf2_eigen.rosinstall
wstool update -t src
catkin_make --only-pkg-with-deps tf2_eigen -j$(nproc) | tee logs/tf2_eigen.txt