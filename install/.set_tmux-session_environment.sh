sess_name=`tmux display-message -p "#S"`
tmux setenv -t $sess_name CMAKE_PREFIX_PATH $CMAKE_PREFIX_PATH
tmux setenv -t $sess_name PATH $PATH
tmux setenv -t $sess_name CMAKE_INCLUDE_PATH $CMAKE_INCLUDE_PATH
tmux setenv -t $sess_name CPATH $CPATH
tmux setenv -t $sess_name LIBRARY_PATH $LIBRARY_PATH
tmux setenv -t $sess_name LD_LIBRARY_PATH $LD_LIBRARY_PATH
tmux setenv -t $sess_name CMAKE_LIBRARY_PATH $CMAKE_LIBRARY_PATH
tmux setenv -t $sess_name CMAKE_MODULE_PATH $CMAKE_MODULE_PATH
tmux setenv -t $sess_name PKG_CONFIG_PATH $PKG_CONFIG_PATH
tmux setenv -t $sess_name PYTHONPATH $PYTHONPATH
tmux setenv -t $sess_name MANPATH $MANPATH